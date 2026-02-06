import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { logAppEvent } from '../_shared/log.ts';

type AcceptInviteBody = {
    invite_token: string;
};

Deno.serve((req) => withRequestContext('family-accept-invite', req, async (ctx) => {
    const preflight = handleOptions(req);
    if (preflight) return preflight;

    if (req.method !== 'POST') {
        return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED', undefined, ctx.headers);
    }

    const { user, error: authError } = await requireUser(req, ctx);
    if (!user) {
        return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED', undefined, ctx.headers);
    }

    const body: AcceptInviteBody = await req.json().catch(() => ({} as AcceptInviteBody));

    if (!body.invite_token) {
        return errorJson('invite_token is required', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }

    const service = createServiceClient();

    const { data, error } = await service.rpc('family_accept_invite', {
        p_invite_token: body.invite_token,
    });

    if (error) {
        if (error.message?.includes('invite_not_found_or_expired')) {
            return errorJson('Invite not found or expired', 404, 'INVITE_NOT_FOUND', undefined, ctx.headers);
        }
        await logAppEvent({
            event_type: 'family_accept_invite_error',
            actor_id: user.id,
            actor_type: 'user',
            payload: { error: error.message },
        });
        return errorJson(error.message, 400, 'ACCEPT_INVITE_ERROR', undefined, ctx.headers);
    }

    await logAppEvent({
        event_type: 'family_invite_accepted',
        actor_id: user.id,
        actor_type: 'user',
        payload: { family_id: data?.family_id },
    });

    return json({ member: data }, 200, ctx.headers);
}));
