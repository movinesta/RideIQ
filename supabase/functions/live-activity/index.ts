import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { logAppEvent } from '../_shared/log.ts';

type RegisterBody = {
    trip_id: string;
    platform: 'ios' | 'android';
    token: string;
    show_full_addresses?: boolean;
};

type RevokeBody = {
    trip_id: string;
};

Deno.serve((req) => withRequestContext('live-activity', req, async (ctx) => {
    const preflight = handleOptions(req);
    if (preflight) return preflight;

    const { user, error: authError } = await requireUser(req, ctx);
    if (!user) {
        return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED', undefined, ctx.headers);
    }

    const service = createServiceClient();

    // POST = register, DELETE = revoke
    if (req.method === 'POST') {
        const body: RegisterBody = await req.json().catch(() => ({} as RegisterBody));

        if (!body.trip_id) {
            return errorJson('trip_id is required', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
        }
        if (!body.platform || !['ios', 'android'].includes(body.platform)) {
            return errorJson('platform must be ios or android', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
        }
        if (!body.token) {
            return errorJson('token is required', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
        }

        const { data, error } = await service.rpc('trip_live_activity_register', {
            p_trip_id: body.trip_id,
            p_platform: body.platform,
            p_token: body.token,
            p_show_full_addresses: body.show_full_addresses ?? false,
        });

        if (error) {
            await logAppEvent({
                event_type: 'live_activity_register_error',
                actor_id: user.id,
                actor_type: 'user',
                payload: { trip_id: body.trip_id, error: error.message },
            });
            return errorJson(error.message, 400, 'REGISTER_ERROR', undefined, ctx.headers);
        }

        await logAppEvent({
            event_type: 'live_activity_registered',
            actor_id: user.id,
            actor_type: 'user',
            payload: { trip_id: body.trip_id, platform: body.platform },
        });

        return json({ activity: data }, 201, ctx.headers);
    }

    if (req.method === 'DELETE') {
        const body: RevokeBody = await req.json().catch(() => ({} as RevokeBody));

        if (!body.trip_id) {
            return errorJson('trip_id is required', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
        }

        const { error } = await service.rpc('trip_live_activity_revoke', {
            p_trip_id: body.trip_id,
        });

        if (error) {
            return errorJson(error.message, 400, 'REVOKE_ERROR', undefined, ctx.headers);
        }

        await logAppEvent({
            event_type: 'live_activity_revoked',
            actor_id: user.id,
            actor_type: 'user',
            payload: { trip_id: body.trip_id },
        });

        return json({ success: true }, 200, ctx.headers);
    }

    return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED', undefined, ctx.headers);
}));
