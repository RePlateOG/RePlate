// supabase/functions/stripe-webhook/index.ts
// Verifies Stripe signature → updates order status in Supabase.
// Register this URL in Stripe Dashboard: Settings → Webhooks → Add endpoint
// Events: payment_intent.succeeded, payment_intent.payment_failed

import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
  httpClient: Stripe.createFetchHttpClient(),
})

// Use the service_role key here — webhook runs without a user session
const supabaseAdmin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
)

serve(async (req) => {
  const signature = req.headers.get("stripe-signature")
  if (!signature) {
    return new Response("Missing stripe-signature", { status: 400 })
  }

  const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!
  const body = await req.text()

  let event: Stripe.Event
  try {
    event = await stripe.webhooks.constructEventAsync(body, signature, webhookSecret)
  } catch (err) {
    console.error("Webhook signature verification failed:", err)
    return new Response(`Webhook error: ${err}`, { status: 400 })
  }

  const paymentIntent = event.data.object as Stripe.PaymentIntent
  const orderId = paymentIntent.metadata?.orderId

  if (!orderId) {
    return new Response("No orderId in metadata", { status: 400 })
  }

  if (event.type === "payment_intent.succeeded") {
    // SECURITY: this is the source of truth — not the client-side result
    const { error } = await supabaseAdmin
      .from("orders")
      .update({ status: "confirmed", payment_id: paymentIntent.id })
      .eq("id", orderId)

    if (error) {
      console.error("Failed to update order:", error)
      return new Response("DB update failed", { status: 500 })
    }
    console.log(`Order ${orderId} confirmed via webhook`)
  } else if (event.type === "payment_intent.payment_failed") {
    await supabaseAdmin
      .from("orders")
      .update({ status: "pending" })  // revert to pending so user can retry
      .eq("id", orderId)

    console.log(`Order ${orderId} payment failed`)
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { "Content-Type": "application/json" },
  })
})
