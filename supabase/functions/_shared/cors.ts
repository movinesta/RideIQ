function deriveAllowOrigin(): string {
  // Prefer explicit origin (useful when APP_BASE_URL contains a path).
  const explicit = (Deno.env.get('APP_ORIGIN') ?? '').trim();
  if (explicit) return explicit;

  // Common: set APP_BASE_URL to your web app (e.g. http://localhost:5173 or
  // https://<user>.github.io/<repo>/). We convert to URL.origin.
  const base = (Deno.env.get('APP_BASE_URL') ?? '').trim();
  if (base) {
    try {
      return new URL(base).origin;
    } catch {
      // fall through
    }
  }

  // Dev-friendly fallback.
  return '*';
}

export function getCorsHeaders(): Record<string, string> {
  const allowOrigin = deriveAllowOrigin();
  return {
    // If allowOrigin is '*', browsers will not send credentials anyway.
    // We deliberately do not set Access-Control-Allow-Credentials.
    'Access-Control-Allow-Origin': allowOrigin,
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-request-id',
    // Some endpoints use non-POST verbs (admin tools, cancellations, etc.)
    'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    // Allow the client to read request correlation ids.
    'Access-Control-Expose-Headers': 'x-request-id',
    // Cache preflight for a day (browser may clamp).
    'Access-Control-Max-Age': '86400',
    // Helps proxies/browsers cache correctly when not using '*'.
    Vary: 'Origin',
  };
}

// Back-compat: other modules import `corsHeaders`.
export const corsHeaders: Record<string, string> = getCorsHeaders();

export function handleOptions(req: Request): Response | null {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: getCorsHeaders() });
  }
  return null;
}
