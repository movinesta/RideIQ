import { envTrim } from "./config.ts";

/**
 * CORS helper for Supabase Edge Functions.
 *
 * Key points:
 * - Always respond to OPTIONS preflight.
 * - For credentialed requests (credentials: "include"), the allow-origin must NOT be "*".
 * - We prefer an allowlist derived from env, and we echo the request origin if it is allowed.
 *
 * Env:
 * - CORS_ALLOW_ORIGINS: comma-separated list of allowed origins (recommended)
 * - APP_ORIGIN: single origin (fallback)
 * - APP_BASE_URL: may include path; we use URL(base).origin (fallback)
 */
function parseAllowList(): string[] {
  const csv = envTrim("CORS_ALLOW_ORIGINS");
  if (csv) {
    return csv
      .split(",")
      .map((s) => s.trim())
      .filter(Boolean);
  }

  const explicit = envTrim("APP_ORIGIN");
  if (explicit) return [explicit];

  const base = envTrim("APP_BASE_URL");
  if (base) {
    try {
      return [new URL(base).origin];
    } catch {
      // ignore
    }
  }

  // Dev fallback: allow any origin (non-credentialed).
  return ["*"];
}

function pickAllowOrigin(reqOrigin: string | null, allowList: string[]): string {
  if (!reqOrigin) return allowList[0] ?? "*";

  // If the allowlist is wildcard-only, be dev-friendly but avoid credentialed '*'.
  // We reflect localhost and GitHub Pages origins; otherwise keep '*'.
  if (allowList.includes("*")) {
    const o = reqOrigin.toLowerCase();
    if (o.startsWith("http://localhost") || o.startsWith("https://localhost") || o.endsWith(".github.io")) {
      return reqOrigin;
    }
    return "*";
  }

  return allowList.includes(reqOrigin) ? reqOrigin : (allowList[0] ?? reqOrigin);
}

export function getCorsHeaders(req?: Request): Record<string, string> {
  const allowList = parseAllowList();
  const reqOrigin = req?.headers?.get("origin") ?? null;
  const allowOrigin = pickAllowOrigin(reqOrigin, allowList);

  // Echo requested headers when possible to avoid future preflight surprises.
  const requestedHeaders = req?.headers?.get("access-control-request-headers")?.trim();
  const allowHeaders =
    requestedHeaders && requestedHeaders.length > 0
      ? requestedHeaders
      : "authorization, x-client-info, apikey, content-type, accept, x-request-id";

  const headers: Record<string, string> = {
    "Access-Control-Allow-Origin": allowOrigin,
    "Access-Control-Allow-Headers": allowHeaders,
    "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
    "Access-Control-Expose-Headers": "x-request-id",
    "Access-Control-Max-Age": "86400",
    Vary: "Origin",
  };

  // Only set credentials when not using '*'.
  if (allowOrigin !== "*") {
    headers["Access-Control-Allow-Credentials"] = "true";
  }

  return headers;
}

// Back-compat: some modules import `corsHeaders` as a constant.
export const corsHeaders: Record<string, string> = getCorsHeaders();

export function handleOptions(req: Request): Response | null {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: getCorsHeaders(req) });
  }
  return null;
}
