// connect-products/index.ts
//
// Manages Stripe Products on behalf of connected accounts.
//
//   POST → Create a product (restaurant listing) on a connected account.
//   GET  → List active products for a connected account (used by the customer storefront).
//
// Products represent food listings. Each product has a default price (the discounted
// amount customers pay). Using Stripe Products means prices and descriptions are
// stored in Stripe and don't require a separate database table for the MVP.
//
// SETUP:
//   supabase secrets set STRIPE_SECRET_KEY=sk_live_...
//   supabase secrets set APP_ORIGIN=https://your-domain.com

import Stripe from "npm:stripe";
import { checkIPLimit, checkUserLimit } from "../_shared/rate-limit.ts";
import {
  parseBody,
  requireString,
  requireUUID,
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
  console.error("[connect-products] MISSING: STRIPE_SECRET_KEY");
}

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

  // GET requests (storefront) don't require auth — customers can browse without logging in.
  // POST requests (create product) require a JWT.
  const jwt = req.headers.get("authorization")?.replace("Bearer ", "") ?? "";

  try {
    // ── GET: List products for a connected account (public storefront) ─────
    if (req.method === "GET") {
      const url = new URL(req.url);
      const accountId = url.searchParams.get("accountId");

      if (!accountId || !accountId.startsWith("acct_")) {
        return new Response(
          JSON.stringify({ error: "accountId query param is required (acct_xxx)" }),
          { status: 400, headers: cors },
        );
      }

      // List up to 20 active products with their default prices expanded.
      // The `stripeAccount` option adds the `Stripe-Account: acct_xxx` header,
      // which scopes the request to that connected account's data.
      const products = await stripeClient.v1.products.list(
        {
          limit: 20,
          active: true,
          expand: ["data.default_price"], // include price in the same API call
        },
        {
          stripeAccount: accountId, // Stripe-Account header — reads from the connected account
        },
      );

      // Shape the response for the storefront frontend
      const items = products.data.map((p) => {
        const price = p.default_price as Stripe.Price | null;
        return {
          id: p.id,
          name: p.name,
          description: p.description ?? "",
          imageUrl: p.images?.[0] ?? null,
          priceId: price?.id ?? null,
          amountCents: price?.unit_amount ?? null,
          currency: price?.currency ?? "usd",
        };
      });

      return new Response(JSON.stringify({ products: items }), {
        status: 200,
        headers: cors,
      });
    }

    // ── POST: Create a product on a connected account (restaurant only) ────
    if (req.method === "POST") {
      if (!jwt) {
        return new Response(JSON.stringify({ error: "Unauthorized" }), {
          status: 401,
          headers: cors,
        });
      }

      const payload = JSON.parse(atob(jwt.split(".")[1]));
      const userId: string = payload.sub;

      const userBlock = checkUserLimit(userId);
      if (userBlock) return userBlock;

      const raw = await parseBody(req);
      const body = stripUnknown(raw, [
        "accountId",
        "name",
        "description",
        "priceInCents",
        "currency",
        "imageUrl",
      ]);

      const accountId = requireString(body.accountId, "accountId", {
        minLen: 5,
        maxLen: 64,
      });
      const name = requireString(body.name, "name", { minLen: 1, maxLen: 200 });
      const description = body.description
        ? requireString(body.description, "description", { maxLen: 500 })
        : undefined;

      // Validate price — must be a positive integer (cents)
      const priceInCents = Number(body.priceInCents);
      if (!Number.isInteger(priceInCents) || priceInCents < 50 || priceInCents > 999999) {
        return new Response(
          JSON.stringify({ error: "priceInCents must be between 50 and 999999 (cents)" }),
          { status: 400, headers: cors },
        );
      }

      const currency = body.currency
        ? requireString(body.currency, "currency", { minLen: 3, maxLen: 3 })
        : "usd";

      // TODO: Verify that `accountId` belongs to the authenticated `userId` in your DB.
      // Without this check, any authenticated user could create products on any account.
      // Example:
      //   const { data } = await supabase.from("restaurants")
      //     .select("stripe_account_id").eq("user_id", userId).single();
      //   if (data?.stripe_account_id !== accountId) {
      //     return new Response(JSON.stringify({ error: "Forbidden" }), { status: 403, headers: cors });
      //   }

      // Create the product on the connected account.
      // `default_price_data` creates a one-time price in the same API call.
      // For recurring/subscription prices, use `stripeClient.v1.prices.create()` separately.
      const product = await stripeClient.v1.products.create(
        {
          name,
          description,
          default_price_data: {
            unit_amount: priceInCents,   // amount in smallest currency unit (cents for USD)
            currency,
          },
          images: body.imageUrl ? [body.imageUrl] : [],
          metadata: {
            created_by_user: userId,     // audit trail — who created this product
          },
        },
        {
          stripeAccount: accountId,      // Stripe-Account header — creates on the connected account
        },
      );

      console.log(
        `[connect-products] Created product ${product.id} on account ${accountId}`,
      );

      return new Response(
        JSON.stringify({
          productId: product.id,
          priceId: (product.default_price as Stripe.Price)?.id,
          name: product.name,
        }),
        { status: 201, headers: cors },
      );
    }

    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: cors,
    });
  } catch (err) {
    if (err instanceof ValidationError) return err.toResponse(cors);
    console.error("[connect-products]", err);
    return new Response(
      JSON.stringify({ error: "Product operation failed" }),
      { status: 500, headers: cors },
    );
  }
});
