// supabase/functions/create-payment-intent/index.ts
// Deno Deploy — Supabase Edge Function
// Creates a Stripe PaymentIntent for a RePlate order.
//
// OWASP A05 Security Misconfiguration  — rate limiting (IP + user), CORS restricted
// OWASP A03 Injection                  — schema-based body validation, UUID enforcement
// OWASP A02 Cryptographic Failures     — no secrets in code; all keys from env vars
// OWASP A01 Broken Access Control      — JWT required; ownership check before charge

import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { checkIPLimit, checkUserLimit } from "../_shared/rate-limit.ts"
import { parseBody, requireUUID, ValidationError } from "../_shared/validation.ts"

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
  httpClient: Stripe.createFetchHttpClient(),
})

// OWASP A05: restrict CORS to known origins so browsers can't be tricked into
// calling this endpoint from arbitrary websites.
// Native iOS clients don't send Origin, so this only affects web-based callers.
const ALLOWED_ORIGINS = new Set([
  Deno.env.get("APP_ORIGIN") ?? "",   // set via: supabase secrets set APP_ORIGIN=https://yourapp.com
  "https://app.replate.com",           // production web client (if any)
  "http://localhost:3000",             // local dev web client
])

function corsHeaders(origin: string | null): Record<string, string> {
  // Reflect exact origin back for known callers; deny unknown browser origins.
  // Native iOS sends no Origin header, so origin is null → we return "*" (safe for native).
  const allowed = !origin || ALLOWED_ORIGINS.has(origin) ? (origin ?? "*") : "null"
  return {
    "Access-Control-Allow-Origin":  allowed,
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Vary": "Origin",
  }
}

serve(async (req) => {
  const origin = req.headers.get("origin")

  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders(origin) })
  }

  const cors = corsHeaders(origin)

  // OWASP A05: IP-based rate limit (60 req/min) — first line of defence
  const ipLimitHit = checkIPLimit(req)
  if (ipLimitHit) return ipLimitHit

  try {
    // OWASP A01: require a valid Supabase JWT before any processing
    const authHeader = req.headers.get("Authorization")
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401, headers: { ...cors, "Content-Type": "application/json" },
      })
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    )

    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401, headers: { ...cors, "Content-Type": "application/json" },
      })
    }

    // OWASP A05: per-user rate limit (20 req/min) — checked after auth to avoid timing oracle
    const userLimitHit = checkUserLimit(user.id)
    if (userLimitHit) return userLimitHit

    // OWASP A03: parse body with size cap; validate orderId is a real UUID v4
    const body = await parseBody(req)
    const orderId = requireUUID(body.orderId, "orderId")

    // OWASP A01: fetch order server-side — never trust client-supplied amount
    const { data: order, error: orderError } = await supabase
      .from("orders")
      .select("id, customer_id, restaurant_id, quantity, total_amount, status, listings(discounted_price, is_free, title)")
      .eq("id", orderId)
      .single()

    if (orderError || !order) {
      return new Response(JSON.stringify({ error: "Order not found" }), {
        status: 404, headers: { ...cors, "Content-Type": "application/json" },
      })
    }

    // OWASP A01: verify caller owns this order before revealing payment info
    if (order.customer_id !== user.id) {
      return new Response(JSON.stringify({ error: "Forbidden" }), {
        status: 403, headers: { ...cors, "Content-Type": "application/json" },
      })
    }

    if (order.listings?.is_free) {
      return new Response(JSON.stringify({ free: true }), {
        headers: { ...cors, "Content-Type": "application/json" },
      })
    }

    // OWASP A04: recompute amount from listing × quantity — any client total is ignored
    const unitPriceDollars: number = order.listings?.discounted_price ?? 0
    const amountCents = Math.round(unitPriceDollars * order.quantity * 100)

    if (amountCents <= 0) {
      return new Response(JSON.stringify({ error: "Invalid order amount" }), {
        status: 400, headers: { ...cors, "Content-Type": "application/json" },
      })
    }

    // Guard against DB corruption or misconfiguration producing an absurd charge
    if (amountCents > 100_000_00) { // $100,000 hard cap
      console.error(`Suspicious charge amount ${amountCents} for order ${orderId}`)
      return new Response(JSON.stringify({ error: "Charge amount out of range" }), {
        status: 400, headers: { ...cors, "Content-Type": "application/json" },
      })
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountCents,
      currency: "usd",
      automatic_payment_methods: { enabled: true },
      metadata: {
        orderId: order.id,
        customerId: order.customer_id,
        restaurantId: order.restaurant_id,
      },
    })

    await supabase
      .from("orders")
      .update({ payment_id: paymentIntent.id })
      .eq("id", orderId)

    // OWASP A02: publishable key loaded from env — never hardcoded
    // Set via: supabase secrets set STRIPE_PUBLISHABLE_KEY=pk_test_...
    const publishableKey = Deno.env.get("STRIPE_PUBLISHABLE_KEY") ?? ""

    return new Response(
      JSON.stringify({ clientSecret: paymentIntent.client_secret, publishableKey, amountCents }),
      { headers: { ...cors, "Content-Type": "application/json" } },
    )
  } catch (err) {
    if (err instanceof ValidationError) {
      return err.toResponse(cors)
    }
    console.error("create-payment-intent error:", err)
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500, headers: { ...cors, "Content-Type": "application/json" },
    })
  }
})
