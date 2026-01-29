import { handleOptions } from '../_shared/cors.ts';
import { envTrim } from '../_shared/config.ts';
import { errorJson, json } from '../_shared/json.ts';

// Returns the Google Maps browser key for the web client.
// This endpoint must be callable by unauthenticated users because
// the /share/<token> page is public.
// Note: this key will be visible to end-users in the browser regardless.
// Security must be enforced via Google Cloud key restrictions
// (HTTP referrers, API restrictions) rather than trying to hide it.

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  if (req.method !== 'GET' && req.method !== 'POST') {
    return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED');
  }

  // Do NOT require an authenticated JWT here.
  // Some clients send the anon key as `Authorization: Bearer <anon-jwt>`,
  // which fails user validation (missing `sub`). That is expected for public usage.

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
      // Explicitly indicate this endpoint is public.
      public: true,
    },
    200,
    { 'cache-control': 'private, max-age=300' },
  );
});
