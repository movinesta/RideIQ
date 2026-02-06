import { handleOptions } from '../_shared/cors.ts';
import { errorJson, json } from '../_shared/json.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import {
  expiresIso,
  fraudEnforceActionBestEffort,
  fraudGetActiveActionBestEffort,
  fraudLogEventBestEffort,
  fraudOpenCaseBestEffort,
} from '../_shared/fraud.ts';

type Body = {
  ride_id?: string;
  text?: string | null;
  kind?: 'text' | 'image' | 'system';
  attachment_key?: string | null; // path in chat-media bucket
  metadata?: Record<string, unknown> | null;
};

const ACTION_BLOCK = 'block_ride_chat_send';

Deno.serve((req) =>
  withRequestContext('ride-chat-send', req, async (ctx) => {
    const opt = handleOptions(req);
    if (opt) return opt;

    if (req.method !== 'POST') return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED', undefined, ctx.headers);

    const { user, error } = await requireUser(req, ctx);
    if (error || !user) return errorJson('Unauthorized', 401, 'UNAUTHORIZED', undefined, ctx.headers);
    ctx.setUserId(user.id);

    const active = await fraudGetActiveActionBestEffort({ actionType: ACTION_BLOCK, subjectKind: 'user', subjectId: user.id });
    if (active) {
      await fraudLogEventBestEffort({
        reason: 'harassment_blocked',
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

    // Rate limit: message velocity
    const ip = getClientIp(req);
    const limit = 30;
    const rl = await consumeRateLimit({ key: `chat_send:${user.id}:${ip ?? 'noip'}`, windowSeconds: 60, limit });
    if (!rl.allowed) {
      const expiresAt = expiresIso(60);
      await fraudLogEventBestEffort({
        reason: 'harassment_chat_velocity',
        subjectKind: 'user',
        subjectId: user.id,
        severity: 3,
        score: 40,
        metadata: { limit, window_seconds: 60 },
        req,
      });
      await fraudOpenCaseBestEffort({
        reason: 'harassment_chat_velocity',
        subjectKind: 'user',
        subjectId: user.id,
        severity: 2,
        metadata: { source: 'ride-chat-send', limit, window_seconds: 60 },
      });
      await fraudEnforceActionBestEffort({
        actionType: ACTION_BLOCK,
        reason: 'velocity',
        subjectKind: 'user',
        subjectId: user.id,
        severity: 2,
        expiresAt,
        metadata: { limit, window_seconds: 60 },
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
      return errorJson('Invalid JSON', 400, 'INVALID_JSON', undefined, ctx.headers);
    }

    const rideId = (body.ride_id ?? '').trim();
    if (!rideId) return errorJson('ride_id is required', 400, 'VALIDATION_ERROR', undefined, ctx.headers);

    const kind = body.kind ?? 'text';
    const text = (body.text ?? '').toString();
    const attachmentKey = body.attachment_key ?? null;

    if (kind === 'text' && !text.trim()) return errorJson('text is required', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    if (kind === 'image' && !attachmentKey) {
      return errorJson('attachment_key is required for image', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }

    const anon = createAnonClient(req);

    // Ensure the caller is a ride participant (RLS-protected read)
    const { data: ride, error: rideErr } = await anon
      .from('rides')
      .select('id,status,rider_id,driver_id')
      .eq('id', rideId)
      .maybeSingle();

    if (rideErr) return errorJson(rideErr.message, 400, 'DB_ERROR', undefined, ctx.headers);
    if (!ride) return errorJson('Ride not found', 404, 'RIDE_NOT_FOUND', undefined, ctx.headers);

    // Create / fetch chat thread (SECURITY DEFINER function enforces membership)
    const { data: threadId, error: thrErr } = await anon.rpc('ride_chat_get_or_create_thread', { p_ride_id: rideId });
    if (thrErr) return errorJson(thrErr.message, 400, 'DB_ERROR', undefined, ctx.headers);

    const payload = {
      thread_id: threadId as string,
      ride_id: rideId,
      sender_id: user.id,
      kind,
      body: kind === 'text' ? text.trim() : null,
      attachment_bucket: attachmentKey ? 'chat-media' : null,
      attachment_key: attachmentKey,
      metadata: body.metadata ?? {},
    };

    const { data: msg, error: msgErr } = await anon
      .from('ride_chat_messages')
      .insert(payload)
      .select('id,thread_id,ride_id,sender_id,kind,body,attachment_bucket,attachment_key,metadata,created_at')
      .single();

    if (msgErr) return errorJson(msgErr.message, 400, 'DB_ERROR', undefined, ctx.headers);

    return json({ ok: true, message: msg, rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt } }, 200, ctx.headers);
  }),
);
