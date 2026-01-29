import { createServiceClient } from './supabase.ts';

export type RateLimitResult = {
  allowed: boolean;
  remaining: number;
  resetAt: string;
};

export async function consumeRateLimit(params: {
  key: string;
  windowSeconds: number;
  limit: number;
}): Promise<RateLimitResult> {
  const service = createServiceClient();

  const { data, error } = await service.rpc('rate_limit_consume', {
    p_key: params.key,
    p_window_seconds: params.windowSeconds,
    p_limit: params.limit,
  });

  if (error) {
    // Fail open: rate limiting must never take down core flows.
    return { allowed: true, remaining: 0, resetAt: new Date(Date.now() + params.windowSeconds * 1000).toISOString() };
  }

  const row = Array.isArray(data) ? data[0] : data;
  return {
    allowed: !!row?.allowed,
    remaining: Number(row?.remaining ?? 0),
    resetAt: String(row?.reset_at ?? new Date(Date.now() + params.windowSeconds * 1000).toISOString()),
  };
}

export function getClientIp(req: Request): string | null {
  const xff = req.headers.get('x-forwarded-for');
  if (xff) {
    const first = xff.split(',')[0]?.trim();
    return first || null;
  }
  return null;
}


function secondsUntilReset(resetAt: string): number {
  const ms = new Date(resetAt).getTime() - Date.now();
  // At least 1 second to avoid "0" which can cause retry loops.
  return Math.max(1, Math.ceil(ms / 1000));
}

/**
 * Standard rate limit headers for 429 responses.
 * - Retry-After: RFC 9110 (used widely by clients/proxies)
 * - RateLimit-Limit/Remaining/Reset: commonly used draft headers (delta seconds reset)
 * - X-RateLimit-*: de-facto compatibility with many clients (epoch reset)
 */
export function buildRateLimitHeaders(params: { limit: number; remaining: number; resetAt: string }): Record<string, string> {
  const retryAfter = secondsUntilReset(params.resetAt);
  const resetEpoch = Math.floor(new Date(params.resetAt).getTime() / 1000);

  return {
    'Retry-After': String(retryAfter),
    'RateLimit-Limit': String(params.limit),
    'RateLimit-Remaining': String(Math.max(0, params.remaining)),
    'RateLimit-Reset': String(retryAfter),

    'X-RateLimit-Limit': String(params.limit),
    'X-RateLimit-Remaining': String(Math.max(0, params.remaining)),
    'X-RateLimit-Reset': String(resetEpoch),
  };
}
