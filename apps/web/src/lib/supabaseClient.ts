import { createClient } from '@supabase/supabase-js';

const url = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const anon = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

// Export raw config so other modules can call Supabase Edge Functions via fetch
// (needed for SSE streaming, which is not supported by supabase.functions.invoke).
export const SUPABASE_URL = url ?? '';
export const SUPABASE_ANON_KEY = anon ?? '';

// In GitHub Pages + Vite, env vars are injected at build time.
// We expose this flag so the UI can show a clear setup message instead of failing at runtime.
export const isSupabaseConfigured = Boolean(url && anon);

if (!isSupabaseConfigured) {
  console.warn('Missing VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY. The app cannot connect to Supabase.');
}

// Use a harmless placeholder when env is missing; the UI should prevent calls in that case.
export const supabase = createClient(url ?? 'https://example.supabase.co', anon ?? 'public-anon-key', {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
});
