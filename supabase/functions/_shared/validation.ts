// OWASP A03: Injection / A04: Insecure Design — schema-based input validation.
// All public-facing functions must validate and sanitize before touching the DB or Stripe.

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
const MAX_BODY_BYTES = 10_240  // 10 KB — enough for any legitimate RePlate payload

export class ValidationError extends Error {
  readonly statusCode = 400
  readonly field?: string

  constructor(message: string, field?: string) {
    super(message)
    this.name  = "ValidationError"
    this.field = field
  }

  toResponse(corsHeaders: Record<string, string>): Response {
    return new Response(
      JSON.stringify({ error: this.message, field: this.field }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    )
  }
}

/**
 * Parse and size-limit the JSON request body.
 * Throws ValidationError for bad Content-Type, oversized body, or malformed JSON.
 */
export async function parseBody(req: Request): Promise<Record<string, unknown>> {
  const contentType = req.headers.get("content-type") ?? ""
  if (!contentType.includes("application/json")) {
    throw new ValidationError("Content-Type must be application/json")
  }

  // Read as text first so we can enforce a size limit before parsing
  const text = await req.text()
  if (new TextEncoder().encode(text).byteLength > MAX_BODY_BYTES) {
    throw new ValidationError("Request body too large")
  }

  try {
    const parsed = JSON.parse(text)
    if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
      throw new ValidationError("Request body must be a JSON object")
    }
    return parsed as Record<string, unknown>
  } catch (e) {
    if (e instanceof ValidationError) throw e
    throw new ValidationError("Invalid JSON in request body")
  }
}

/** Validate that a value is a properly-formatted UUID v4. */
export function requireUUID(value: unknown, field: string): string {
  if (typeof value !== "string") {
    throw new ValidationError(`${field} must be a string`, field)
  }
  if (!UUID_RE.test(value)) {
    throw new ValidationError(`${field} must be a valid UUID v4`, field)
  }
  return value
}

/** Validate and trim a required string field. */
export function requireString(
  value: unknown,
  field: string,
  { minLen = 1, maxLen = 1_000 }: { minLen?: number; maxLen?: number } = {},
): string {
  if (typeof value !== "string") {
    throw new ValidationError(`${field} must be a string`, field)
  }
  const trimmed = value.trim()
  // Strip null bytes (OWASP injection hardening)
  const sanitized = trimmed.replace(/\0/g, "")
  if (sanitized.length < minLen) {
    throw new ValidationError(`${field} is required`, field)
  }
  if (sanitized.length > maxLen) {
    throw new ValidationError(`${field} exceeds maximum length of ${maxLen}`, field)
  }
  return sanitized
}

/** Remove any fields not in the allowed list before passing to downstream services. */
export function stripUnknown(
  body: Record<string, unknown>,
  allowed: string[],
): Record<string, unknown> {
  const out: Record<string, unknown> = {}
  for (const key of allowed) {
    if (key in body) out[key] = body[key]
  }
  return out
}
