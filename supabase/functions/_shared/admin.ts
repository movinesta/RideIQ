import type { RequestContext } from './requestContext.ts';
import { errorJson } from './json.ts';
import { createUserClient, requireUserStrict } from './supabase.ts';

export async function requireAdmin(
  req: Request,
  ctx: RequestContext,
): Promise<{ user: any } | { res: Response }> {
  const { user, error } = await requireUserStrict(req, ctx);
  if (!user) {
    return { res: errorJson(String(error ?? 'Unauthorized'), 401, 'UNAUTHORIZED', undefined, ctx.headers) };
  }

  const authed = createUserClient(req);
  const { data, error: rpcErr } = await authed.rpc('is_admin');
  if (rpcErr) {
    ctx.warn('admin.check_failed', { error: rpcErr.message });
    return { res: errorJson('Forbidden', 403, 'FORBIDDEN', undefined, ctx.headers) };
  }

  if (!data) {
    return { res: errorJson('Forbidden', 403, 'FORBIDDEN', undefined, ctx.headers) };
  }

  return { user };
}
