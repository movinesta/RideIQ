import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { logAppEvent } from '../_shared/log.ts';

type UpdatePolicyBody = {
    family_id: string;
    teen_user_id: string;
    destination_lock_enabled?: boolean;
    pickup_pin_enabled?: boolean;
    allowed_hours?: Record<string, unknown>;
    geofence_allowlist?: unknown[];
    spend_cap_daily?: number;
};

Deno.serve((req) => withRequestContext('family-policy-update', req, async (ctx) => {
    const preflight = handleOptions(req);
    if (preflight) return preflight;

    if (req.method !== 'POST') {
        return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED', undefined, ctx.headers);
    }

    const { user, error: authError } = await requireUser(req, ctx);
    if (!user) {
        return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED', undefined, ctx.headers);
    }

    const body: UpdatePolicyBody = await req.json().catch(() => ({} as UpdatePolicyBody));

    if (!body.family_id) {
        return errorJson('family_id is required', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }
    if (!body.teen_user_id) {
        return errorJson('teen_user_id is required', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }

    const service = createServiceClient();

    const { data, error } = await service.rpc('family_update_policy', {
        p_family_id: body.family_id,
        p_teen_user_id: body.teen_user_id,
        p_destination_lock_enabled: body.destination_lock_enabled ?? null,
        p_pickup_pin_enabled: body.pickup_pin_enabled ?? null,
        p_allowed_hours: body.allowed_hours ?? null,
        p_geofence_allowlist: body.geofence_allowlist ?? null,
        p_spend_cap_daily: body.spend_cap_daily ?? null,
    });

    if (error) {
        if (error.message?.includes('forbidden')) {
            return errorJson('You are not authorized to update policies for this family', 403, 'FORBIDDEN', undefined, ctx.headers);
        }
        if (error.message?.includes('policy_not_found')) {
            return errorJson('Policy not found for this teen', 404, 'POLICY_NOT_FOUND', undefined, ctx.headers);
        }
        await logAppEvent({
            event_type: 'family_policy_update_error',
            actor_id: user.id,
            actor_type: 'user',
            payload: { family_id: body.family_id, teen_user_id: body.teen_user_id, error: error.message },
        });
        return errorJson(error.message, 400, 'POLICY_UPDATE_ERROR', undefined, ctx.headers);
    }

    await logAppEvent({
        event_type: 'family_policy_updated',
        actor_id: user.id,
        actor_type: 'user',
        payload: { family_id: body.family_id, teen_user_id: body.teen_user_id },
    });

    return json({ policy: data }, 200, ctx.headers);
}));
