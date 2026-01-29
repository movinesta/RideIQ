import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';

Deno.serve((req) =>
  withRequestContext('scheduled-ride-list', req, async (ctx) => {
    const preflight = handleOptions(req);
    if (preflight) return preflight;

    const { user, error } = await requireUser(req);
    if (error || !user) return errorJson('Unauthorized', 401, 'UNAUTHORIZED');

    const url = new URL(req.url);
    const limit = Math.min(200, Math.max(1, Number(url.searchParams.get('limit') ?? 50) || 50));

    const supa = createAnonClient(req);

    const { data, error: dbErr } = await supa
      .from('scheduled_rides')
      .select('*')
      .eq('rider_id', user.id)
      .order('scheduled_at', { ascending: true })
      .limit(limit);

    if (dbErr) {
      ctx.error('db.select_failed', { err: dbErr.message });
      return errorJson('Failed to fetch scheduled rides', 500, 'DB_ERROR');
    }

    return json({ scheduled_rides: data ?? [] }, 200, ctx.headers);
  }),
);
