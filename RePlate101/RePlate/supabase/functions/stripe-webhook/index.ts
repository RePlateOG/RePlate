// supabase/functions/stripe-webhook/index.ts
// Verifies Stripe signature → updates order status in Supabase.
//
// OWASP A03 Injection          — orderId UUID validated before DB update
// OWASP A01 Broken Access Control — Stripe signature is the auth layer; no JWT here
// OWASP A05 Security Misconfiguration — rate limit prevents replay-flood abuse
//
// Register this URL in Stripe Dashboard: Settings → Webhooks → Add endpoint
// Events: payment_intent.succeeded, payment_intent.payment_failed

import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { checkIPLimit } from "../_shared/rate-limit.ts"

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
  httpClient: Stripe.createFetchHttpClient(),
})

// Service-role key is correct here: webhook runs server-to-server, not from a browser.
// All keys are loaded from env — never committed to source control (OWASP A02).
const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
)

// OWASP A03: UUID v4 pattern — validated before any DB interaction
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i

serve(async (req) => {
  // OWASP A05: IP-based rate limit prevents replay floods from a single source.
  // Stripe's infrastructure distributes retries across IPs, so legit retries aren't blocked.
  const ipLimitHit = checkIPLimit(req)
  if (ipLimitHit) return ipLimitHit

  const signature = req.headers.get("stripe-signature")
  if (!signature) {
    return new Response("Missing stripe-signature header", { status: 400 })
  }

  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!
  const body = await req.text()

  let event: Stripe.Event
  try {
    // OWASP A02: cryptographic signature check — rejects any tampered payload
    event = await stripe.webhooks.constructEventAsync(body, signature, webhookSecret)
  } catch (err) {
    console.error("Webhook signature verification failed:", err)
    return new Response("Webhook signature invalid", { status: 400 })
  }

  const paymentIntent = event.data.object as Stripe.PaymentIntent
  const orderId = paymentIntent.metadata?.orderId

  // OWASP A03: validate UUID format before any DB interaction
  if (!orderId || !UUID_RE.test(orderId)) {
    console.error("Webhook event has missing or malformed orderId:", orderId)
    // Return 200 so Stripe doesn't retry an event we can never process
    return new Response(JSON.stringify({ received: true, skipped: true }), {
      headers: { "Content-Type": "application/json" },
    })
  }

  if (event.type === "payment_intent.succeeded") {
    // OWASP A01: this webhook is the authoritative success signal — not the client result
    const { error } = await supabaseAdmin
      .from("orders")
      .update({ status: "confirmed", payment_id: paymentIntent.id })
      .eq("id", orderId)

    if (error) {
      console.error(`Failed to confirm order ${orderId}:`, error)
      // Return 500 so Stripe retries — the event was valid but our DB write failed
      return new Response("DB update failed", { status: 500 })
    }
    console.log(`Order ${orderId} confirmed via webhook`)

  } else if (event.type === "payment_intent.payment_failed") {
    const { error } = await supabaseAdmin
      .from("orders")
      .update({ status: "pending" })  // revert so user can retry payment
      .eq("id", orderId)

    if (error) {
      console.error(`Failed to revert order ${orderId} to pending:`, error)
      return new Response("DB update failed", { status: 500 })
    }
    console.log(`Order ${orderId} payment failed — reverted to pending`)
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { "Content-Type": "application/json" },
  })
})
