import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';

type Body = { id?: string };

Deno.serve((req) =>
  withRequestContext('scheduled-ride-cancel', req, async (ctx) => {
    const preflight = handleOptions(req);
    if (preflight) return preflight;

    const { user, error } = await requireUser(req);
    if (error || !user) return errorJson('Unauthorized', 401, 'UNAUTHORIZED', undefined, ctx.headers);

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
