import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.92.0?target=deno';
import { SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY, SUPABASE_URL } from './config.ts';

export function createAnonClient(req: Request) {
  const authHeader = req.headers.get('Authorization') ?? '';
  return createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: {
      headers: {
        Authorization: authHeader,
      },
    },
  });
}

export function createServiceClient() {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
}

export async function requireUser(req: Request) {
  const authHeader = req.headers.get('Authorization') ?? '';
  const token = authHeader.toLowerCase().startsWith('bearer ')
    ? authHeader.slice('bearer '.length).trim()
    : authHeader.trim();
  if (!token) {
    return { user: null, error: 'Missing authorization token' } as const;
  }

  // Validate JWT using the anon client (least-privilege).
  // This avoids using the service role key for a user-auth check.
  const anon = createAnonClient(req);
  const { data, error } = await anon.auth.getUser(token);
  if (error || !data?.user) {
    return { user: null, error: error?.message ?? 'Unauthorized' } as const;
  }
  return { user: data.user, error: null } as const;
}
