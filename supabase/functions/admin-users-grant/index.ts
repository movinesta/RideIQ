import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';

type Body = {
  user_id?: string;
  note?: string;
};

function isUuid(v: unknown): v is string {
  return (
    typeof v === 'string' &&
    /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v)
  );
}

Deno.serve((req) =>
  withRequestContext('admin-users-grant', req, async (ctx) => {
    const opt = handleOptions(req);
    if (opt) return opt;

    if (req.method !== 'POST') {
      return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED', undefined, ctx.headers);
    }

    const { user, error: authErr } = await requireUser(req);
    if (!user) {
      return errorJson(String(authErr ?? 'Unauthorized'), 401, 'UNAUTHORIZED', undefined, ctx.headers);
    }

    const anon = createAnonClient(req);
    const { data: isAdmin, error: adminErr } = await anon.rpc('is_admin');
    if (adminErr) return errorJson(adminErr.message, 400, 'DB_ERROR', undefined, ctx.headers);
    if (!isAdmin) return errorJson('Forbidden', 403, 'FORBIDDEN', undefined, ctx.headers);

    let body: Body;
    try {
      body = (await req.json()) as Body;
    } catch {
      return errorJson('Invalid JSON body', 400, 'INVALID_JSON', undefined, ctx.headers);
    }

    if (!isUuid(body.user_id)) {
      return errorJson('user_id is required (uuid)', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }

    const note = typeof body.note === 'string' ? body.note.trim().slice(0, 400) : null;

    const { error: grantErr } = await anon.rpc('admin_grant_user', {
      p_user: body.user_id,
      p_note: note,
    });
    if (grantErr) return errorJson(grantErr.message, 400, 'DB_ERROR', undefined, ctx.headers);

    return json({ ok: true }, 200, ctx.headers);
  }),
);
