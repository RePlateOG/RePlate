// OWASP A05: Security Misconfiguration — rate limiting to prevent brute-force and DoS.
// Sliding-window counters live in module-level Maps; they reset on cold start,
// which is acceptable for MVP: a single instance handles most traffic.
// For multi-instance deployments, swap the Map for Upstash Redis or Supabase KV.

interface WindowEntry {
  timestamps: number[]
}

// Separate stores prevent a single abusive IP from burning a user's quota, and vice-versa.
const ipWindows  = new Map<string, WindowEntry>()
const userWindows = new Map<string, WindowEntry>()

const WINDOW_MS    = 60_000  // 1-minute sliding window
const IP_LIMIT     = 60      // 60 req/min per IP  (covers normal household NATs)
const USER_LIMIT   = 20      // 20 req/min per authenticated user (tighter)
const MAX_STORE_SIZE = 10_000 // evict oldest entries to prevent unbounded memory growth

function checkWindow(
  store: Map<string, WindowEntry>,
  key: string,
  limit: number,
): { allowed: boolean; remaining: number; resetAt: number } {
  const now  = Date.now()
  const cutoff = now - WINDOW_MS
  const entry = store.get(key) ?? { timestamps: [] }

  // Drop timestamps outside the current window
  entry.timestamps = entry.timestamps.filter(t => t > cutoff)

  const count = entry.timestamps.length
  const resetAt = count > 0 ? entry.timestamps[0] + WINDOW_MS : now + WINDOW_MS

  if (count >= limit) {
    store.set(key, entry)
    return { allowed: false, remaining: 0, resetAt }
  }

  entry.timestamps.push(now)
  store.set(key, entry)

  // Evict oldest 20 % when the store grows too large
  if (store.size > MAX_STORE_SIZE) {
    const evict = Math.floor(MAX_STORE_SIZE * 0.2)
    let i = 0
    for (const k of store.keys()) {
      if (i++ >= evict) break
      store.delete(k)
    }
  }

  return { allowed: true, remaining: limit - count - 1, resetAt }
}

function limitExceededResponse(resetAt: number, limit: number): Response {
  const retryAfterSec = Math.ceil((resetAt - Date.now()) / 1000)
  return new Response(
    JSON.stringify({ error: "Too many requests. Please try again later.", code: "RATE_LIMIT_EXCEEDED" }),
    {
      status: 429,
      headers: {
        "Content-Type": "application/json",
        // Standard headers that well-behaved clients respect
        "Retry-After":          String(retryAfterSec),
        "X-RateLimit-Limit":    String(limit),
        "X-RateLimit-Remaining": "0",
        "X-RateLimit-Reset":    String(Math.ceil(resetAt / 1000)),
      },
    },
  )
}

/** Check the IP-based rate limit. Returns a 429 Response if exceeded, otherwise null. */
export function checkIPLimit(req: Request): Response | null {
  // x-forwarded-for is set by Supabase's edge network; take only the first (client) IP
  const ip =
    req.headers.get("x-forwarded-for")?.split(",")[0].trim() ??
    req.headers.get("x-real-ip") ??
    "unknown"

  const { allowed, resetAt } = checkWindow(ipWindows, ip, IP_LIMIT)
  return allowed ? null : limitExceededResponse(resetAt, IP_LIMIT)
}

/** Check the per-user rate limit. Returns a 429 Response if exceeded, otherwise null. */
export function checkUserLimit(userId: string): Response | null {
  const { allowed, resetAt } = checkWindow(userWindows, userId, USER_LIMIT)
  return allowed ? null : limitExceededResponse(resetAt, USER_LIMIT)
}
