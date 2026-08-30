// connect-subscriptions/index.ts
//
// Manages platform-level subscriptions that restaurants pay to RePlate.
//
// RePlate charges restaurants a monthly/annual subscription fee for platform access.
// These subscriptions are at the PLATFORM level (not the connected account level),
// using the connected account's `customer_account` field as the customer identifier.
//
// Two operations:
//   POST /subscribe   → Creates a Checkout Session for a subscription.
//   POST /portal      → Creates a Billing Portal session for subscription management.
//
// SETUP:
//   supabase secrets set STRIPE_SECRET_KEY=sk_live_...
//   supabase secrets set SUBSCRIPTION_PRICE_ID=price_xxx  ← create this in your Stripe Dashboard
//   supabase secrets set APP_ORIGIN=https://your-domain.com
//
//   To create the subscription price in your Stripe Dashboard:
//   Stripe Dashboard → Products → Add Product → Add Price (recurring, monthly)
//   Then set: supabase secrets set SUBSCRIPTION_PRICE_ID=price_xxx

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
  console.error("[connect-subscriptions] MISSING: STRIPE_SECRET_KEY");
}

// PLACEHOLDER: Set this in Supabase secrets after creating the plan in the Stripe Dashboard.
// Dashboard path: Products → Add Product → Name "RePlate Platform Access" → Add Recurring Price
const SUBSCRIPTION_PRICE_ID =
  Deno.env.get("SUBSCRIPTION_PRICE_ID") ??
  "price_PLACEHOLDER_set_SUBSCRIPTION_PRICE_ID_secret";

if (SUBSCRIPTION_PRICE_ID.startsWith("price_PLACEHOLDER")) {
  console.warn(
    "[connect-subscriptions] SUBSCRIPTION_PRICE_ID is not configured. " +
    "Create a recurring price in the Stripe Dashboard and set it via: " +
    "`supabase secrets set SUBSCRIPTION_PRICE_ID=price_xxx`",
  );
}

// Platform-level stripe client — subscriptions are charged TO the platform account
// (RePlate), not to/from the connected account.
const stripeClient = new Stripe(STRIPE_SECRET_KEY ?? "");

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

    const url = new URL(req.url);
    const operation = url.pathname.split("/").pop(); // "subscribe" or "portal"

    const raw = await parseBody(req);

    // ── POST /subscribe: Create subscription checkout ─────────────────────
    if (operation === "subscribe") {
      const body = stripUnknown(raw, ["accountId", "successUrl", "cancelUrl"]);

      const accountId = requireString(body.accountId, "accountId", {
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

      // For V2 accounts, use `customer_account` instead of `customer`.
      // This uses the connected account itself as the billing entity — Stripe can
      // charge the restaurant's saved payment method for the platform subscription.
      const session = await stripeClient.v1.checkout.sessions.create({
        customer_account: accountId, // the connected account pays the platform subscription
        mode: "subscription",
        line_items: [
          {
            price: SUBSCRIPTION_PRICE_ID,  // your "RePlate Platform Access" recurring price
            quantity: 1,
          },
        ],
        // {CHECKOUT_SESSION_ID} is replaced by Stripe with the actual session ID
        success_url: `${successUrl}?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: cancelUrl,
        metadata: {
          user_id: userId,        // audit trail
          account_id: accountId,
        },
      });

      console.log(
        `[connect-subscriptions] Created subscription session ${session.id} for account ${accountId}`,
      );

      return new Response(
        JSON.stringify({ sessionId: session.id, url: session.url }),
        { status: 200, headers: cors },
      );
    }

    // ── POST /portal: Create billing portal session ────────────────────────
    if (operation === "portal") {
      const body = stripUnknown(raw, ["accountId", "returnUrl"]);

      const accountId = requireString(body.accountId, "accountId", {
        minLen: 5,
        maxLen: 64,
      });
      const returnUrl = requireString(body.returnUrl, "returnUrl", {
        minLen: 10,
        maxLen: 512,
      });

      // The billing portal lets the restaurant manage their subscription:
      // upgrade, downgrade, cancel, update payment method, view invoices.
      // `customer_account` scopes the portal to this connected account's subscription.
      const portalSession = await stripeClient.v1.billingPortal.sessions.create({
        customer_account: accountId, // connected account's ID — NOT a cus_xxx customer ID
        return_url: returnUrl,       // redirect back to the restaurant dashboard after portal
      });

      console.log(
        `[connect-subscriptions] Created portal session for account ${accountId}`,
      );

      return new Response(
        JSON.stringify({ url: portalSession.url }),
        { status: 200, headers: cors },
      );
    }

    return new Response(
      JSON.stringify({
        error: "Unknown operation. Use /subscribe or /portal",
      }),
      { status: 400, headers: cors },
    );
  } catch (err) {
    if (err instanceof ValidationError) return err.toResponse(cors);
    console.error("[connect-subscriptions]", err);
    return new Response(
      JSON.stringify({ error: "Subscription operation failed" }),
      { status: 500, headers: cors },
    );
  }
});
