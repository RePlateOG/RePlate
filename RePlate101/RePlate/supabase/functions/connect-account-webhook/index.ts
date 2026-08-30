// connect-account-webhook/index.ts
//
// Handles Stripe V1 standard webhook events for connected account changes.
//
// Uses V1 standard events (account.updated, capability.updated) so the webhook
// can be fully managed via the Stripe API without needing the dashboard.
//
// SETUP (already done programmatically):
//   supabase secrets set STRIPE_SECRET_KEY=sk_live_...
//   supabase secrets set CONNECT_WEBHOOK_SECRET=whsec_...

import Stripe from "npm:stripe";

const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
const CONNECT_WEBHOOK_SECRET = Deno.env.get("CONNECT_WEBHOOK_SECRET");

if (!STRIPE_SECRET_KEY) console.error("[connect-account-webhook] MISSING: STRIPE_SECRET_KEY");
if (!CONNECT_WEBHOOK_SECRET) console.error("[connect-account-webhook] MISSING: CONNECT_WEBHOOK_SECRET");

const stripeClient = new Stripe(STRIPE_SECRET_KEY ?? "");

// ─── Handler ─────────────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }

  const body = await req.text();
  const sig = req.headers.get("stripe-signature") ?? "";

  // Verify signature using the standard V1 method
  let event: Stripe.Event;
  try {
    event = stripeClient.webhooks.constructEvent(body, sig, CONNECT_WEBHOOK_SECRET ?? "");
  } catch (err) {
    console.error("[connect-account-webhook] Signature verification failed:", err);
    return new Response(JSON.stringify({ error: "Invalid signature" }), {
      status: 400, headers: { "Content-Type": "application/json" },
    });
  }

  console.log(`[connect-account-webhook] Received: ${event.id} (${event.type})`);

  try {
    switch (event.type) {
      case "account.updated":
        await handleAccountUpdated(event.data.object as Stripe.Account);
        break;
      case "capability.updated":
        await handleCapabilityUpdated(event.data.object as Stripe.Capability);
        break;
      default:
        console.log(`[connect-account-webhook] Ignored: ${event.type}`);
    }

    return new Response(JSON.stringify({ received: true }), {
      status: 200, headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("[connect-account-webhook] Processing error:", err);
    return new Response(JSON.stringify({ error: "Event processing failed" }), {
      status: 500, headers: { "Content-Type": "application/json" },
    });
  }
});

// ─── Handlers ────────────────────────────────────────────────────────────────

// Fires when any field on a connected account changes, including requirements.
async function handleAccountUpdated(account: Stripe.Account) {
  const accountId = account.id;
  const requirements = account.requirements;
  const currentlyDue = requirements?.currently_due ?? [];
  const pastDue = requirements?.past_due ?? [];
  const hasRequirements = currentlyDue.length > 0 || pastDue.length > 0;

  console.log(
    `[connect-account-webhook] Account updated: ${accountId} — ` +
    `charges_enabled=${account.charges_enabled}, payouts_enabled=${account.payouts_enabled}, ` +
    `requirements_due=${currentlyDue.length + pastDue.length}`,
  );

  if (hasRequirements) {
    const status = pastDue.length > 0 ? "past_due" : "currently_due";
    console.log(`[connect-account-webhook] Account ${accountId} has ${status} requirements — notify owner`);

    // TODO: Update your database and notify the restaurant:
    //   await supabase.from("restaurants").update({
    //     stripe_onboarding_status: "action_required",
    //     stripe_requirements_status: status,
    //     can_accept_payments: account.charges_enabled,
    //   }).eq("stripe_account_id", accountId);
  } else if (account.charges_enabled) {
    console.log(`[connect-account-webhook] Account ${accountId} is fully enabled`);

    // TODO: Update your database:
    //   await supabase.from("restaurants").update({
    //     stripe_onboarding_status: "complete",
    //     stripe_requirements_status: "none",
    //     can_accept_payments: true,
    //   }).eq("stripe_account_id", accountId);
  }
}

// Fires when a specific capability's status changes (e.g. card_payments becomes active).
async function handleCapabilityUpdated(capability: Stripe.Capability) {
  const accountId = capability.account as string;
  const capabilityId = capability.id;
  const status = capability.status;

  console.log(
    `[connect-account-webhook] Capability updated: ${capabilityId} = ${status} on account ${accountId}`,
  );

  if (capabilityId === "card_payments" && status === "active") {
    console.log(`[connect-account-webhook] Account ${accountId} can now accept card payments`);

    // TODO: Update your database:
    //   await supabase.from("restaurants").update({
    //     stripe_card_payments_status: "active",
    //     can_accept_payments: true,
    //   }).eq("stripe_account_id", accountId);
  }
}
