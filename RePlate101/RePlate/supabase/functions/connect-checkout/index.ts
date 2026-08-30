// connect-checkout/index.ts
//
// Creates a Stripe Checkout Session for a direct charge to a connected account.
//
// Flow:
//   1. Customer taps "Buy" on a food listing.
//   2. The app calls this endpoint with the accountId, priceId, and quantity.
//   3. We create a Hosted Checkout Session on the connected account.
//   4. We return the session URL — the app opens it in SafariServices/WKWebView.
//   5. On success, Stripe redirects to success_url; on cancel, to cancel_url.
//
// MONETIZATION:
//   The `application_fee_amount` is RePlate's platform fee (e.g., 123 = $1.23).
//   This amount is automatically deducted from the connected account's payout.
//   Adjust APPLICATION_FEE_PERCENT to control what RePlate earns per transaction.
//
// SETUP:
//   supabase secrets set STRIPE_SECRET_KEY=sk_live_...
//   supabase secrets set APP_ORIGIN=https://your-domain.com

import Stripe from "npm:stripe";
import { checkIPLimit, checkUserLimit } from "../_shared/rate-limit.ts";
import {
  parseBody,
  requireString,
  stripUnknown,
  ValidationError,
} from "../_shared/validation.ts";

const ALLOWED_ORIGINS = new Set([
  Deno.env.get("APP_ORIGIN") ?? "",
  "http://localhost:3000",
]);

function corsHeaders(origin: string | null) {
  const allowed = origin && ALLOWED_ORIGINS.has(origin) ? origin : "";
  return {
    "Access-Control-Allow-Origin": allowed,
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey",
    "Content-Type": "application/json",
  };
}

const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
if (!STRIPE_SECRET_KEY) {
  console.error("[connect-checkout] MISSING: STRIPE_SECRET_KEY");
}

const stripeClient = new Stripe(STRIPE_SECRET_KEY ?? "");

// Platform fee percentage taken by RePlate on each transaction.
// Example: 0.10 = 10% platform fee.
// TODO: Move to environment variable or database config for per-restaurant negotiation.
const APPLICATION_FEE_PERCENT = 0.10;

// ─── Handler ─────────────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");
  const cors = corsHeaders(origin);

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }

  const ipBlock = checkIPLimit(req);
  if (ipBlock) return ipBlock;

  const jwt = req.headers.get("authorization")?.replace("Bearer ", "") ?? "";
  if (!jwt) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: cors,
    });
  }

  try {
    const payload = JSON.parse(atob(jwt.split(".")[1]));
    const userId: string = payload.sub;

    const userBlock = checkUserLimit(userId);
    if (userBlock) return userBlock;

    const raw = await parseBody(req);
    const body = stripUnknown(raw, [
      "accountId",
      "priceId",
      "quantity",
      "successUrl",
      "cancelUrl",
    ]);

    const accountId = requireString(body.accountId, "accountId", {
      minLen: 5,
      maxLen: 64,
    });
    const priceId = requireString(body.priceId, "priceId", {
      minLen: 5,
      maxLen: 64,
    });
    const successUrl = requireString(body.successUrl, "successUrl", {
      minLen: 10,
      maxLen: 512,
    });
    const cancelUrl = requireString(body.cancelUrl, "cancelUrl", {
      minLen: 10,
      maxLen: 512,
    });

    const quantity = Number(body.quantity ?? 1);
    if (!Number.isInteger(quantity) || quantity < 1 || quantity > 100) {
      return new Response(
        JSON.stringify({ error: "quantity must be between 1 and 100" }),
        { status: 400, headers: cors },
      );
    }

    // Look up the price to calculate the application fee.
    // We cannot trust a client-supplied amount, so we fetch the price from Stripe.
    const price = await stripeClient.v1.prices.retrieve(priceId, {}, {
      stripeAccount: accountId,
    });

    if (!price.unit_amount) {
      return new Response(
        JSON.stringify({ error: "This price does not have a fixed amount" }),
        { status: 400, headers: cors },
      );
    }

    // Calculate RePlate's platform fee (cents, rounded down to avoid over-charging)
    const totalCents = price.unit_amount * quantity;
    const applicationFeeCents = Math.floor(totalCents * APPLICATION_FEE_PERCENT);

    // Create a Hosted Checkout Session on the connected account.
    // The session is scoped to `accountId` via the `stripeAccount` option, which sets
    // the `Stripe-Account: acct_xxx` HTTP header. The customer pays the connected account
    // directly; Stripe automatically routes the application fee to RePlate's platform account.
    const session = await stripeClient.v1.checkout.sessions.create(
      {
        mode: "payment",
        line_items: [
          {
            price: priceId,      // use the exact Stripe Price ID (not price_data) for simplicity
            quantity,
          },
        ],
        payment_intent_data: {
          // Application fee is deducted from the connected account's payout and
          // transferred to the RePlate platform account automatically.
          application_fee_amount: applicationFeeCents,
          metadata: {
            user_id: userId,     // store the buyer's Supabase user ID for order tracking
            account_id: accountId,
          },
        },
        // {CHECKOUT_SESSION_ID} is replaced by Stripe with the actual session ID
        success_url: `${successUrl}?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: cancelUrl,
      },
      {
        stripeAccount: accountId, // Stripe-Account header — charges go to this account
      },
    );

    console.log(
      `[connect-checkout] Created session ${session.id} on account ${accountId} ` +
      `(fee: $${(applicationFeeCents / 100).toFixed(2)})`,
    );

    return new Response(
      JSON.stringify({
        sessionId: session.id,
        url: session.url,               // open this URL in a browser to show the checkout UI
        applicationFeeCents,
        totalCents,
      }),
      { status: 200, headers: cors },
    );
  } catch (err) {
    if (err instanceof ValidationError) return err.toResponse(cors);
    console.error("[connect-checkout]", err);
    return new Response(
      JSON.stringify({ error: "Failed to create checkout session" }),
      { status: 500, headers: cors },
    );
  }
});
