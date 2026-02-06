import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { logAppEvent } from '../_shared/log.ts';

type CreateFamilyBody = {
  name?: string;
};

Deno.serve((req) => withRequestContext('family-create', req, async (ctx) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  if (req.method !== 'POST') {
    return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED', undefined, ctx.headers);
  }

  const { user, error: authError } = await requireUser(req, ctx);
  if (!user) {
    return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED', undefined, ctx.headers);
  }

  const body: CreateFamilyBody = await req.json().catch(() => ({}));

  const service = createServiceClient();

  const { data, error } = await service.rpc('family_create', {
    p_name: body.name ?? null,
  });

  if (error) {
    await logAppEvent({
      event_type: 'family_create_error',
      actor_id: user.id,
      actor_type: 'user',
      payload: { error: error.message },
    });
    return errorJson(error.message, 400, 'FAMILY_CREATE_ERROR', undefined, ctx.headers);
  }

  await logAppEvent({
    event_type: 'family_created',
    actor_id: user.id,
    actor_type: 'user',
    payload: { family_id: data?.id },
  });

  return json({ family: data }, 201, ctx.headers);
}));
