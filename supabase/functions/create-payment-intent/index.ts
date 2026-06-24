// supabase/functions/create-payment-intent/index.ts
// Deno Deploy — Supabase Edge Function
// Creates a Stripe PaymentIntent for a RePlate order.
// SECURITY: amount is recomputed server-side from the database; client value is ignored.

import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import Stripe from "https://esm.sh/stripe@14.21.0?target=deno"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2024-06-20",
  httpClient: Stripe.createFetchHttpClient(),
})

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    // Verify Supabase JWT
    const authHeader = req.headers.get("Authorization")
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    )

    const { data: { user }, error: userError } = await supabase.auth.getUser()
    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    const { orderId } = await req.json()
    if (!orderId) {
      return new Response(JSON.stringify({ error: "orderId required" }), {
        status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    // SECURITY: fetch order + listing from DB to recompute amount — never trust client
    const { data: order, error: orderError } = await supabase
      .from("orders")
      .select("id, customer_id, restaurant_id, quantity, total_amount, status, listings(discounted_price, is_free, title)")
      .eq("id", orderId)
      .single()

    if (orderError || !order) {
      return new Response(JSON.stringify({ error: "Order not found" }), {
        status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    // Verify the caller owns this order
    if (order.customer_id !== user.id) {
      return new Response(JSON.stringify({ error: "Forbidden" }), {
        status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    // Listing is free — no payment needed
    if (order.listings?.is_free) {
      return new Response(JSON.stringify({ free: true }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    // SECURITY: recompute amount from listing price × quantity — ignore any client total
    const unitPriceDollars: number = order.listings?.discounted_price ?? 0
    const amountCents = Math.round(unitPriceDollars * order.quantity * 100)

    if (amountCents <= 0) {
      return new Response(JSON.stringify({ error: "Invalid amount" }), {
        status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" },
      })
    }

    // Create Stripe PaymentIntent
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

    // Update order with payment intent id (pending)
    await supabase
      .from("orders")
      .update({ payment_id: paymentIntent.id })
      .eq("id", orderId)

    return new Response(
      JSON.stringify({
        clientSecret: paymentIntent.client_secret,
        publishableKey: "pk_test_YOUR_PUBLISHABLE_KEY", // NOTE: replace or use env var in production
        amountCents,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  } catch (err) {
    console.error("create-payment-intent error:", err)
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }
})
