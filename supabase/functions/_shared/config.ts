const envPermission = 'permissions' in Deno
  ? await Deno.permissions.query({ name: 'env' })
  : { state: 'granted' as const };

const readEnv = (key: string) => (envPermission.state === 'granted' ? Deno.env.get(key) ?? '' : '');

export const SUPABASE_URL = readEnv('SUPABASE_URL');
export const SUPABASE_ANON_KEY = readEnv('SUPABASE_ANON_KEY');
export const SUPABASE_SERVICE_ROLE_KEY = readEnv('SUPABASE_SERVICE_ROLE_KEY');

if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY) {
  console.warn('[config] Missing one or more required env vars: SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY');
}
