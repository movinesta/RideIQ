import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { adminUsersGrantSchema } from '../_shared/schemas.ts';
import { ZodError } from 'npm:zod@3.23.8';

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
    if (!isAdmin) {
      // AUDIT LOG: Failed admin access attempt
      console.warn(`[AUDIT] DENIED admin-users-grant by user=${user.id} (not admin)`);
      return errorJson('Forbidden', 403, 'FORBIDDEN', undefined, ctx.headers);
    }

    // Parse and validate input with Zod
    let input: ReturnType<typeof adminUsersGrantSchema.parse>;
    try {
      const rawBody = await req.json();
      input = adminUsersGrantSchema.parse(rawBody);
    } catch (e) {
      if (e instanceof ZodError) {
        const firstIssue = e.issues[0];
        const field = firstIssue?.path.join('.') || 'unknown';
        const message = firstIssue?.message || 'Validation failed';
        return errorJson(`${field}: ${message}`, 400, 'VALIDATION_ERROR', { issues: e.issues }, ctx.headers);
      }
      if (e instanceof SyntaxError) {
        return errorJson('Invalid JSON body', 400, 'INVALID_JSON', undefined, ctx.headers);
      }
      throw e;
    }

    // AUDIT LOG: Admin grant attempt
    console.log(`[AUDIT] admin-users-grant: admin=${user.id} target=${input.user_id} note="${input.note ?? ''}"`);

    const { error: grantErr } = await anon.rpc('admin_grant_user', {
      p_user: input.user_id,
      p_note: input.note,
    });
    if (grantErr) {
      console.error(`[AUDIT] admin-users-grant FAILED: admin=${user.id} target=${input.user_id} error=${grantErr.message}`);
      return errorJson(grantErr.message, 400, 'DB_ERROR', undefined, ctx.headers);
    }

    // AUDIT LOG: Success
    console.log(`[AUDIT] admin-users-grant SUCCESS: admin=${user.id} granted admin to target=${input.user_id}`);

    return json({ ok: true }, 200, ctx.headers);
  }),
);
