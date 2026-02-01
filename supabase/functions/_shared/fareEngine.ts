import { handleOptions } from './cors.ts';
import { errorJson, json } from './json.ts';
import type { RequestContext } from './requestContext.ts';
import { createAnonClient, requireUser } from './supabase.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from './rateLimit.ts';
import { fareQuoteSchema, type FareQuoteInput } from './schemas.ts';
import { FareEngineError, quoteAndStoreFare } from './fareQuoteCore.ts';

/**
 * Shared fare-engine handler.
 *
 * Computes a route-based, audit-logged fare quote.
 * The deterministic baseline is computed in fareQuoteCore; this handler enforces auth + rate limiting.
 */
export async function fareEngine(req: Request, ctx: RequestContext, engineName: string): Promise<Response> {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  if (req.method !== 'POST') {
    return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED', undefined, ctx.headers);
  }

  // Auth required (we store the quote for auditability).
  const { user, error: authError } = await requireUser(req);
  if (!user) {
    return errorJson('Unauthorized', 401, 'UNAUTHORIZED', authError ? { detail: authError } : undefined, ctx.headers);
  }
  ctx.setUserId(user.id);

  // Lightweight rate limiting (protects external API calls).
  const ip = getClientIp(req) ?? 'unknown';
  const rl = await consumeRateLimit({
    key: `${engineName}:${user.id}:${ip}`,
    windowSeconds: 60,
    limit: 60,
    failOpen: true,
  });
  const rateHeaders = buildRateLimitHeaders({ limit: 60, remaining: rl.remaining, resetAt: rl.resetAt });
  if (!rl.allowed) {
    return errorJson('Too many requests', 429, 'RATE_LIMITED', { resetAt: rl.resetAt }, { ...ctx.headers, ...rateHeaders });
  }

  let raw: unknown;
  try {
    raw = await req.json();
  } catch {
    return errorJson('Invalid JSON body', 400, 'INVALID_JSON', undefined, { ...ctx.headers, ...rateHeaders });
  }

  const parsed = fareQuoteSchema.safeParse(raw);
  if (!parsed.success) {
    return errorJson('Invalid request', 400, 'VALIDATION_ERROR', { issues: parsed.error.issues }, { ...ctx.headers, ...rateHeaders });
  }

  const input: FareQuoteInput = parsed.data;
  const supabase = createAnonClient(req);

  try {
    const result = await quoteAndStoreFare({ supabase, riderId: user.id, input, engineName, ctx });
    return json(result, 200, { ...ctx.headers, ...rateHeaders });
  } catch (e) {
    if (e instanceof FareEngineError) {
      return errorJson(e.message, e.status, e.code, e.details, { ...ctx.headers, ...rateHeaders });
    }
    ctx.error('fare_engine.unhandled', { error: String(e) });
    return errorJson('Internal error', 500, 'INTERNAL_ERROR', undefined, { ...ctx.headers, ...rateHeaders });
  }
}
