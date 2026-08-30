// connect-onboarding/index.ts
//
// Two operations in one function:
//   GET  ?accountId=acct_xxx  → Returns the current onboarding status for the account.
//   POST { accountId, refreshUrl, returnUrl } → Creates an Account Link URL for onboarding.
//
// The iOS app polls GET to show onboarding status, and opens the POST-returned URL in
// SafariServices/ASWebAuthenticationSession so the restaurant owner can complete KYC.
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
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization, apikey",
    "Content-Type": "application/json",
  };
}

const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
if (!STRIPE_SECRET_KEY) {
  console.error("[connect-onboarding] MISSING: STRIPE_SECRET_KEY");
}

const stripeClient = new Stripe(STRIPE_SECRET_KEY ?? "");

// ─── Account status helper ────────────────────────────────────────────────────

// Derives a simple status string from the V2 account object.
// Always fetch fresh from Stripe — do not cache this; requirements can change.
async function getAccountStatus(accountId: string) {
  // Retrieve with the fields we need to determine status.
  // `include` asks Stripe to expand nested objects that are not returned by default.
  const account = await stripeClient.v2.core.accounts.retrieve(accountId, {
    include: ["configuration.merchant", "requirements"],
  });

  // `card_payments.status === "active"` means the account can process live payments.
  const readyToProcessPayments =
    account?.configuration?.merchant?.capabilities?.card_payments?.status ===
    "active";

  // Check requirements deadline — if "currently_due" or "past_due", the restaurant
  // must provide more information (e.g. identity documents, bank account).
  const requirementsStatus =
    account.requirements?.summary?.minimum_deadline?.status;

  // Onboarding is considered complete when there are no outstanding requirements.
  const onboardingComplete =
    requirementsStatus !== "currently_due" &&
    requirementsStatus !== "past_due";

  return {
    accountId: account.id,
    displayName: account.display_name,
    readyToProcessPayments,
    onboardingComplete,
    requirementsStatus: requirementsStatus ?? "none",
    // Raw capabilities for the iOS UI to decide what badges to show
    cardPaymentsStatus:
      account?.configuration?.merchant?.capabilities?.card_payments?.status ??
      "inactive",
  };
}

// ─── Handler ─────────────────────────────────────────────────────────────────

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("origin");
  const cors = corsHeaders(origin);

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }

  const ipBlock = checkIPLimit(req);
  if (ipBlock) return ipBlock;

  // Require authentication
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

    // ── GET: Return current account status ────────────────────────────────
    if (req.method === "GET") {
      const url = new URL(req.url);
      const accountId = url.searchParams.get("accountId");

      if (!accountId || !accountId.startsWith("acct_")) {
        return new Response(
          JSON.stringify({ error: "accountId query param is required (acct_xxx)" }),
          { status: 400, headers: cors },
        );
      }

      const status = await getAccountStatus(accountId);
      return new Response(JSON.stringify(status), { status: 200, headers: cors });
    }

    // ── POST: Create an Account Link for onboarding/re-onboarding ─────────
    if (req.method === "POST") {
      const raw = await parseBody(req);
      const body = stripUnknown(raw, ["accountId", "refreshUrl", "returnUrl"]);

      const accountId = requireString(body.accountId, "accountId", {
        minLen: 5,
        maxLen: 64,
      });
      const refreshUrl = requireString(body.refreshUrl, "refreshUrl", {
        minLen: 10,
        maxLen: 512,
      });
      const returnUrl = requireString(body.returnUrl, "returnUrl", {
        minLen: 10,
        maxLen: 512,
      });

      // Create a V2 Account Link — the URL returned is single-use and expires in ~5 minutes.
      // The restaurant owner opens this URL in a browser to complete KYC / identity verification.
      // `configurations: ["merchant", "customer"]` ensures both the payment-processing and
      // subscription-customer configurations are collected in a single onboarding session.
      const accountLink = await stripeClient.v2.core.accountLinks.create({
        account: accountId,
        use_case: {
          type: "account_onboarding",
          account_onboarding: {
            configurations: ["merchant", "customer"],
            refresh_url: refreshUrl, // redirect here if the link expires before completion
            return_url: returnUrl,   // redirect here after the user finishes (or skips)
          },
        },
      });

      return new Response(
        JSON.stringify({
          url: accountLink.url,
          expiresAt: accountLink.expires_at,
        }),
        { status: 200, headers: cors },
      );
    }

    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: cors,
    });
  } catch (err) {
    if (err instanceof ValidationError) return err.toResponse(cors);
    console.error("[connect-onboarding]", err);
    return new Response(
      JSON.stringify({ error: "Onboarding request failed" }),
      { status: 500, headers: cors },
    );
  }
});
