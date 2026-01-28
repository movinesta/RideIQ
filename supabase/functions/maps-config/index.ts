import { handleOptions } from '../_shared/cors.ts';
import { envTrim } from '../_shared/config.ts';
import { errorJson, json } from '../_shared/json.ts';
import { requireUser } from '../_shared/supabase.ts';

// Returns the Google Maps browser key for the web client.
// Note: this key will be visible to end-users in the browser regardless.
// Security should be enforced via Google Cloud key restrictions
// (HTTP referrers, API restrictions) rather than by trying to hide it.

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  if (req.method !== 'GET') {
    return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED');
  }

  const { user, error } = await requireUser(req);
  if (!user) {
    return errorJson(error ?? 'Unauthorized', 401, 'UNAUTHORIZED');
  }

  const apiKey = envTrim('MAPS_API_KEY');
  if (!apiKey) {
    return errorJson('MAPS_API_KEY is not configured', 500, 'MISCONFIGURED');
  }

  // Keep response cacheable by the browser (short), but do not cache by shared proxies.
  return json(
    {
      // Backwards compatible contract:
      // - Older web clients expect `google_maps_api_key`.
      // - Newer clients can read `apiKey`.
      google_maps_api_key: apiKey,
      apiKey,
      // Optional: allow wiring a Map ID later without changing the contract.
      mapId: envTrim('MAPS_MAP_ID') || undefined,
    },
    200,
    { 'cache-control': 'private, max-age=300' },
  );
});
