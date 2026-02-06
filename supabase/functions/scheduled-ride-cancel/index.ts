import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import {
  expiresIso,
  fraudEnforceActionBestEffort,
  fraudGetActiveActionBestEffort,
  fraudLogEventBestEffort,
  fraudOpenCaseBestEffort,
} from '../_shared/fraud.ts';

type Body = { id?: string };

const ACTION_BLOCK = 'block_scheduled_cancel';

Deno.serve((req) =>
  withRequestContext('scheduled-ride-cancel', req, async (ctx) => {
    const preflight = handleOptions(req);
    if (preflight) return preflight;

    const { user, error } = await requireUser(req);
    if (error || !user) return errorJson('Unauthorized', 401, 'UNAUTHORIZED', undefined, ctx.headers);

    ctx.setUserId(user.id);

    const active = await fraudGetActiveActionBestEffort({ actionType: ACTION_BLOCK, subjectKind: 'user', subjectId: user.id });
    if (active) {
      await fraudLogEventBestEffort({
        reason: 'cancel_abuse_blocked',
        subjectKind: 'user',
        subjectId: user.id,
        severity: 2,
        score: 20,
        metadata: { action_type: ACTION_BLOCK, action_id: active.id, expires_at: active.expires_at },
        req,
      });
      return json(
        { error: 'Temporarily blocked', code: 'BLOCKED', retry_at: active.expires_at ?? null },
        429,
        {
          ...ctx.headers,
          ...(active.expires_at
            ? {
                'Retry-After': String(
                  Math.max(1, Math.ceil((new Date(active.expires_at).getTime() - Date.now()) / 1000)),
                ),
              }
            : {}),
        },
      );
    }

    const ip = getClientIp(req);
    const limit = 8;
    const rl = await consumeRateLimit({ key: `scheduled_cancel:${user.id}:${ip ?? 'noip'}`, windowSeconds: 300, limit });
    if (!rl.allowed) {
      const expiresAt = expiresIso(120);
      await fraudLogEventBestEffort({
        reason: 'cancel_abuse_velocity',
        subjectKind: 'user',
        subjectId: user.id,
        severity: 3,
        score: 40,
        metadata: { limit, window_seconds: 300 },
        req,
      });
      await fraudOpenCaseBestEffort({
        reason: 'cancel_abuse_scheduled',
        subjectKind: 'user',
        subjectId: user.id,
        severity: 2,
        metadata: { source: 'scheduled-ride-cancel', limit, window_seconds: 300 },
      });
      await fraudEnforceActionBestEffort({
        actionType: ACTION_BLOCK,
        reason: 'velocity',
        subjectKind: 'user',
        subjectId: user.id,
        severity: 2,
        expiresAt,
        metadata: { limit, window_seconds: 300 },
      });

      return json(
        { error: 'Rate limit exceeded', code: 'RATE_LIMITED', remaining: rl.remaining, reset_at: rl.resetAt },
        429,
        { ...ctx.headers, ...buildRateLimitHeaders({ limit, remaining: rl.remaining, resetAt: rl.resetAt }) },
      );
    }

    let body: Body;
    try {
      body = (await req.json()) as Body;
    } catch {
      return errorJson('Invalid JSON body', 400, 'INVALID_JSON', undefined, ctx.headers);
    }
    if (!body.id || typeof body.id !== 'string') {
      return errorJson('Missing id', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }

    const supa = createAnonClient(req);

    const { data, error: dbErr } = await supa
      .from('scheduled_rides')
      .update({ status: 'cancelled', cancelled_at: new Date().toISOString() })
      .eq('id', body.id)
      .eq('rider_id', user.id)
      .eq('status', 'pending')
      .select('*')
      .single();

    if (dbErr) {
      ctx.error('db.update_failed', { err: dbErr.message });
      return errorJson('Failed to cancel scheduled ride', 500, 'DB_ERROR', undefined, ctx.headers);
    }

    return json({ scheduled_ride: data }, 200, ctx.headers);
  }),
);
