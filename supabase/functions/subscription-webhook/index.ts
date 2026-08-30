// subscription-webhook/index.ts
//
// Handles standard (V1) Stripe webhook events for restaurant subscription lifecycle.
// These are NOT thin events — use the standard `constructEvent` verification method.
//
// HOW TO CONFIGURE:
//   1. Stripe Dashboard → Developers → Webhooks → Add destination
//   2. Events from: "Your account" (platform-level events)
//   3. Payload style: "Standard" (NOT thin — subscriptions use standard events)
//   4. Events to listen for:
//      - customer.subscription.updated
//      - customer.subscription.deleted
//      - payment_method.attached
//      - payment_method.detached
//      - customer.updated
//   5. Endpoint URL: https://<project>.supabase.co/functions/v1/subscription-webhook
//   6. Copy the webhook signing secret → supabase secrets set SUBSCRIPTION_WEBHOOK_SECRET=whsec_...
//
// LOCAL TESTING:
//   stripe listen --events customer.subscription.updated,customer.subscription.deleted \
//     --forward-to http://localhost:54321/functions/v1/subscription-webhook
//
// SETUP:
//   supabase secrets set STRIPE_SECRET_KEY=sk_live_...
//   supabase secrets set SUBSCRIPTION_WEBHOOK_SECRET=whsec_...

import Stripe from "npm:stripe";

const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
const SUBSCRIPTION_WEBHOOK_SECRET = Deno.env.get("SUBSCRIPTION_WEBHOOK_SECRET");

if (!STRIPE_SECRET_KEY) {
  console.error("[subscription-webhook] MISSING: STRIPE_SECRET_KEY");
}
if (!SUBSCRIPTION_WEBHOOK_SECRET) {
  console.error("[subscription-webhook] MISSING: SUBSCRIPTION_WEBHOOK_SECRET");
}

const stripeClient = new Stripe(STRIPE_SECRET_KEY ?? "");

// ─── Handler ─────────────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  // Read the raw body BEFORE any parsing — the webhook signature covers raw bytes
  const body = await req.text();
  const sig = req.headers.get("stripe-signature") ?? "";

  // Verify the webhook signature using the standard V1 method (not thin events)
  let event: Stripe.Event;
  try {
    event = stripeClient.webhooks.constructEvent(
      body,
      sig,
      SUBSCRIPTION_WEBHOOK_SECRET ?? "",
    );
  } catch (err) {
    console.error("[subscription-webhook] Signature verification failed:", err);
    return new Response(
      JSON.stringify({ error: "Invalid signature" }),
      { status: 400, headers: { "Content-Type": "application/json" } },
    );
  }

  console.log(`[subscription-webhook] Received event: ${event.id} (${event.type})`);

  try {
    // Route to the appropriate handler
    switch (event.type) {
      case "customer.subscription.updated":
        await handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
        break;

      case "customer.subscription.deleted":
        await handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
        break;

      case "payment_method.attached":
        await handlePaymentMethodAttached(event.data.object as Stripe.PaymentMethod);
        break;

      case "payment_method.detached":
        await handlePaymentMethodDetached(event.data.object as Stripe.PaymentMethod);
        break;

      case "customer.updated":
        await handleCustomerUpdated(event.data.object as Stripe.Customer);
        break;

      default:
        console.log(`[subscription-webhook] Ignored unhandled event type: ${event.type}`);
    }

    // Return 200 to acknowledge receipt — always, even if we didn't handle the event.
    // If we return 4xx/5xx, Stripe will retry delivery repeatedly.
    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("[subscription-webhook] Processing error:", err);
    // 500 causes Stripe to retry — appropriate for transient DB errors
    return new Response(
      JSON.stringify({ error: "Failed to process event" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});

// ─── Subscription Event Handlers ──────────────────────────────────────────────

// Handles upgrades, downgrades, pauses, and cancellation scheduling.
async function handleSubscriptionUpdated(subscription: Stripe.Subscription) {
  // For V2 accounts, the customer identifier is on `customer_account` (shape: acct_xxx),
  // NOT `customer` (which would be a cus_xxx Customer object for V1 accounts).
  const accountId = (subscription as Stripe.Subscription & { customer_account?: string })
    .customer_account;

  if (!accountId) {
    console.warn("[subscription-webhook] subscription.updated: no customer_account found");
    return;
  }

  const status = subscription.status; // "active" | "past_due" | "canceled" | "paused" | ...
  const priceId = subscription.items.data[0]?.price.id;
  const quantity = subscription.items.data[0]?.quantity ?? 1;
  const cancelAtPeriodEnd = subscription.cancel_at_period_end;
  const currentPeriodEnd = new Date(subscription.current_period_end * 1000).toISOString();

  // Check if the customer paused their subscription via the billing portal
  const isPaused = subscription.pause_collection !== null;
  const pauseResumesAt = subscription.pause_collection?.resumes_at
    ? new Date(subscription.pause_collection.resumes_at * 1000).toISOString()
    : null;

  console.log(
    `[subscription-webhook] Subscription updated for account ${accountId}: ` +
    `status=${status}, priceId=${priceId}, quantity=${quantity}, ` +
    `cancelAtPeriodEnd=${cancelAtPeriodEnd}, paused=${isPaused}`,
  );

  // TODO: Update your database with the new subscription state.
  // Grant or revoke access to RePlate features based on subscription status.
  //
  //   await supabase.from("restaurants").update({
  //     subscription_status: status,
  //     subscription_price_id: priceId,
  //     subscription_quantity: quantity,
  //     subscription_cancel_at_period_end: cancelAtPeriodEnd,
  //     subscription_period_end: currentPeriodEnd,
  //     subscription_paused: isPaused,
  //     subscription_resumes_at: pauseResumesAt,
  //     // Only grant full access when subscription is active and not scheduled to cancel
  //     has_platform_access: status === "active" && !cancelAtPeriodEnd && !isPaused,
  //   }).eq("stripe_account_id", accountId);

  if (cancelAtPeriodEnd) {
    // The restaurant scheduled a cancellation — they will lose access at period end
    // TODO: Send a "We're sorry to see you go" email and optionally a win-back offer
    console.log(`[subscription-webhook] Account ${accountId} scheduled to cancel at period end`);
  }

  if (isPaused) {
    console.log(
      `[subscription-webhook] Account ${accountId} paused; resumes at ${pauseResumesAt}`,
    );
  }
}

// Fires when a subscription is canceled immediately (or at period end and period ends).
async function handleSubscriptionDeleted(subscription: Stripe.Subscription) {
  const accountId = (subscription as Stripe.Subscription & { customer_account?: string })
    .customer_account;

  if (!accountId) {
    console.warn("[subscription-webhook] subscription.deleted: no customer_account found");
    return;
  }

  console.log(`[subscription-webhook] Subscription canceled for account ${accountId}`);

  // TODO: Revoke access to paid features in your database.
  //
  //   await supabase.from("restaurants").update({
  //     subscription_status: "canceled",
  //     has_platform_access: false,
  //     subscription_canceled_at: new Date().toISOString(),
  //   }).eq("stripe_account_id", accountId);

  // TODO: Send a cancellation confirmation email and a win-back offer
}

// Fires when a customer adds a payment method
async function handlePaymentMethodAttached(paymentMethod: Stripe.PaymentMethod) {
  const customerId = paymentMethod.customer as string;
  const pmType = paymentMethod.type;
  const last4 = paymentMethod.card?.last4;
  const brand = paymentMethod.card?.brand;

  console.log(
    `[subscription-webhook] Payment method attached: ${pmType} ${brand} ****${last4} to customer ${customerId}`,
  );

  // TODO: Update your database with the new payment method details for display.
  //   await supabase.from("restaurants").update({
  //     payment_method_last4: last4,
  //     payment_method_brand: brand,
  //   }).eq("stripe_customer_id", customerId);
}

// Fires when a customer removes a payment method
async function handlePaymentMethodDetached(paymentMethod: Stripe.PaymentMethod) {
  const last4 = paymentMethod.card?.last4;
  console.log(`[subscription-webhook] Payment method detached: ****${last4}`);

  // TODO: Update your database to clear the removed payment method details.
}

// Fires when customer billing details change (e.g., new default payment method)
async function handleCustomerUpdated(customer: Stripe.Customer) {
  const defaultPaymentMethod = customer.invoice_settings?.default_payment_method;
  console.log(
    `[subscription-webhook] Customer updated: ${customer.id}, ` +
    `default_payment_method: ${defaultPaymentMethod}`,
  );

  // IMPORTANT: Do NOT use the customer's email from this event as a login credential.
  // This is billing information only.

  // TODO: Update payment method display in your database:
  //   if (typeof defaultPaymentMethod === "string") {
  //     await supabase.from("restaurants").update({
  //       stripe_default_payment_method: defaultPaymentMethod,
  //     }).eq("stripe_customer_id", customer.id);
  //   }
}
