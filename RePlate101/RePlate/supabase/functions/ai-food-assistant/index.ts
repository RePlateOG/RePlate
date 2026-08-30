import Anthropic from "npm:@anthropic-ai/sdk@0.27.0";
import { createClient } from "npm:@supabase/supabase-js@2";

const anthropic = new Anthropic({ apiKey: Deno.env.get("ANTHROPIC_API_KEY")! });

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey, x-client-info",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get("authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const body = await req.json();
    const { query } = body as { query: string };

    if (!query || query.trim().length === 0) {
      return new Response(JSON.stringify({ error: "Query is required" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Fetch user preferences
    const { data: prefs } = await supabase
      .from("user_preferences")
      .select("dietary_restrictions, favorite_categories, max_budget")
      .eq("id", user.id)
      .single();

    // Fetch active listings (up to 30 for context)
    const now = new Date().toISOString();
    const { data: listings } = await supabase
      .from("food_listings")
      .select(
        "id, title, description, category, discounted_price, is_free, quantity_remaining, pickup_start, pickup_end, dietary_info, address"
      )
      .eq("status", "active")
      .gte("pickup_end", now)
      .gt("quantity_remaining", 0)
      .order("created_at", { ascending: false })
      .limit(30);

    // Format listings for the prompt
    const listingsText = listings && listings.length > 0
      ? listings.map((l, i) => {
          const price = l.is_free ? "FREE" : `$${l.discounted_price?.toFixed(2) ?? "?"}`;
          const pickupEnd = new Date(l.pickup_end).toLocaleTimeString("en-US", {
            hour: "numeric",
            minute: "2-digit",
            hour12: true,
          });
          const dietary = l.dietary_info?.join(", ") || "none listed";
          return `${i + 1}. [ID: ${l.id}] "${l.title}" — ${price} | ${l.category} | Pickup by ${pickupEnd} | Dietary: ${dietary} | ${l.description?.slice(0, 80) ?? ""}`;
        }).join("\n")
      : "No active listings available right now.";

    // Build user context
    const userContext = prefs
      ? [
          prefs.dietary_restrictions?.length
            ? `Dietary restrictions: ${prefs.dietary_restrictions.join(", ")}`
            : null,
          prefs.favorite_categories?.length
            ? `Favourite categories: ${prefs.favorite_categories.join(", ")}`
            : null,
          prefs.max_budget != null ? `Budget: up to $${prefs.max_budget}` : null,
        ]
          .filter(Boolean)
          .join("\n") || "No preferences saved."
      : "No preferences saved.";

    const systemPrompt = `You are RePlate's AI food assistant — friendly, helpful, and knowledgeable about surplus food. RePlate connects customers with restaurants offering discounted or free surplus food to reduce waste.

Your job: read the user's query, consider their preferences, and recommend the best matching listings from what's available right now. Be conversational and warm, like a knowledgeable friend who knows all the food spots.

RULES:
- Only recommend listings from the provided list. Do not invent items.
- If nothing matches well, say so honestly and suggest they check back later.
- Keep the greeting to 1 short sentence.
- Give 1–4 recommendations. For each, explain WHY it fits the request in one concise sentence.
- End with a brief 1-sentence summary.
- Respond ONLY with valid JSON in this exact shape:
{
  "greeting": "<1-sentence greeting>",
  "recommendations": [
    {
      "id": "<listing UUID>",
      "title": "<listing title>",
      "price_label": "<FREE or $X.XX>",
      "reason": "<1-sentence why this fits>"
    }
  ],
  "summary": "<1-sentence summary>"
}`;

    const userMessage = `User preferences:\n${userContext}\n\nAvailable listings:\n${listingsText}\n\nUser query: "${query}"`;

    const response = await anthropic.messages.create({
      model: "claude-sonnet-5-20251101",
      max_tokens: 1024,
      messages: [{ role: "user", content: userMessage }],
      system: systemPrompt,
    });

    const rawText = response.content[0].type === "text" ? response.content[0].text : "";

    // Parse Claude's JSON response
    let parsed: { greeting: string; recommendations: unknown[]; summary: string };
    try {
      // Strip any markdown fences if present
      const jsonStr = rawText.replace(/^```json?\s*/i, "").replace(/```\s*$/i, "").trim();
      parsed = JSON.parse(jsonStr);
    } catch {
      parsed = {
        greeting: "Here's what I found for you!",
        recommendations: [],
        summary: rawText.slice(0, 200),
      };
    }

    return new Response(JSON.stringify(parsed), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("ai-food-assistant error:", err);
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
