// keep-alive/index.ts
// Pinged daily by an external cron to prevent Supabase free-tier auto-pause.
Deno.serve(() => new Response(JSON.stringify({ ok: true, ts: new Date().toISOString() }), {
  headers: { "Content-Type": "application/json" },
}));
