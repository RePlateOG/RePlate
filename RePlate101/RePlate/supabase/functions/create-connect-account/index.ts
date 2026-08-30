// create-connect-account/index.ts
//
// Creates a Stripe Connect V2 account for a restaurant and returns the account ID.
// The account ID is stored in your DB to link this Supabase user → Stripe account.
//
// SETUP (run once):
//   supabase secrets set STRIPE_SECRET_KEY=sk_live_...
//   supabase secrets set APP_ORIGIN=https://your-domain.com
//
// HTTP: POST /functions/v1/create-connect-account
//   Authorization: Bearer <supabase-jwt>
//   Body: { "displayName": "Verde Bistro", "email": "owner@verde.com" }
//
// RESPONSE: { "accountId": "acct_xxx", "alreadyExists": false }

import Stripe from "npm:stripe";
import { checkIPLimit, checkUserLimit } from "../_shared/rate-limit.ts";
import {
  parseBody,
  requireString,
  stripUnknown,
  ValidationError,
} from "../_shared/validation.ts";

// ─── Config ──────────────────────────────────────────────────────────────────

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

// SECURITY: The secret key lives only in Supabase secrets — never in committed code.
// If this env var is missing the function will log an error on every request.
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
if (!STRIPE_SECRET_KEY) {
  console.error(
    "[create-connect-account] MISSING: set STRIPE_SECRET_KEY via `supabase secrets set`",
  );
}

// Use the new StripeClient constructor (Stripe SDK v16+). API version is set
// automatically to the latest stable version — no need to pin it here.
const stripeClient = new Stripe(STRIPE_SECRET_KEY ?? "");

// ─── Handler ─────────────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");
  const cors = corsHeaders(origin);

  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }

  // Step 1 — IP-level rate limit (60 req/min)
  const ipBlock = checkIPLimit(req);
  if (ipBlock) return ipBlock;

  // Step 2 — Require Supabase JWT so only authenticated restaurant users can
  // create connected accounts. Extract the user ID from the JWT payload.
  const jwt = req.headers.get("authorization")?.replace("Bearer ", "") ?? "";
  if (!jwt) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: cors,
    });
  }

  try {
    // Decode the JWT (Supabase JWTs are not encrypted, just signed). The `sub`
    // claim is the Supabase user UUID — use it as the platform-side user identifier.
    const payload = JSON.parse(atob(jwt.split(".")[1]));
    const userId: string = payload.sub;

    // Step 3 — Per-user rate limit (20 req/min)
    const userBlock = checkUserLimit(userId);
    if (userBlock) return userBlock;

    // Step 4 — Parse and validate request body
    const raw = await parseBody(req);
    const body = stripUnknown(raw, ["displayName", "email"]);
    const displayName = requireString(body.displayName, "displayName", {
      minLen: 2,
      maxLen: 100,
    });
    const email = requireString(body.email, "email", { minLen: 5, maxLen: 254 });

    // Step 5 — Check if this user already has a connected account (optional DB lookup)
    // TODO: Query your database to avoid creating duplicate accounts.
    // Example with supabase-js:
    //
    //   const { data } = await supabase
    //     .from("restaurants")
    //     .select("stripe_account_id")
    //     .eq("user_id", userId)
    //     .single();
    //
    //   if (data?.stripe_account_id) {
    //     return new Response(
    //       JSON.stringify({ accountId: data.stripe_account_id, alreadyExists: true }),
    //       { status: 200, headers: cors },
    //     );
    //   }

    // Step 6 — Create the Stripe Connect V2 account
    //
    // Key decisions:
    //   - No `type` at the top level — the V2 API replaces type with `configuration`
    //   - `fees_collector: "stripe"` → Stripe handles compliance fees (not RePlate)
    //   - `losses_collector: "stripe"` → Stripe absorbs fraud losses (not RePlate)
    //   - `dashboard: "full"` → restaurant gets a full Stripe dashboard login
    //   - `customer: {}` → allows this account to be used as a Stripe Customer for
    //     platform-level subscriptions (restaurant pays RePlate)
    //   - `card_payments.requested: true` → request card-processing capability;
    //     Stripe may ask for additional identity documents before activating it
    const account = await stripeClient.v2.core.accounts.create({
      display_name: displayName,
      contact_email: email,
      identity: {
        country: "us", // TODO: make this dynamic based on the restaurant's address
      },
      dashboard: "full",
      defaults: {
        responsibilities: {
          fees_collector: "stripe",
          losses_collector: "stripe",
        },
      },
      configuration: {
        customer: {},
        merchant: {
          capabilities: {
            card_payments: {
              requested: true,
            },
          },
        },
      },
    });

    // Step 7 — Persist the mapping: Supabase user → Stripe account ID
    // TODO: Save to your database so future requests can look up the account ID.
    //
    //   await supabase
    //     .from("restaurants")
    //     .update({
    //       stripe_account_id: account.id,
    //       stripe_onboarding_status: "pending",
    //     })
    //     .eq("user_id", userId);

    console.log(
      `[create-connect-account] Created account ${account.id} for user ${userId}`,
    );

    return new Response(
      JSON.stringify({ accountId: account.id, alreadyExists: false }),
      { status: 201, headers: cors },
    );
  } catch (err) {
    if (err instanceof ValidationError) return err.toResponse(cors);
    console.error("[create-connect-account]", err);
    return new Response(
      JSON.stringify({ error: "Failed to create connected account" }),
      { status: 500, headers: cors },
    );
  }
});
