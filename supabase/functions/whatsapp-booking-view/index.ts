import { handleOptions } from '../_shared/cors.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { createServiceClient } from '../_shared/supabase.ts';

Deno.serve((req) =>
  withRequestContext('whatsapp-booking-view', req, async () => {
    if (req.method === 'OPTIONS') return handleOptions(req);
    if (req.method !== 'GET') return errorJson('method_not_allowed', 405, 'METHOD_NOT_ALLOWED');

    const url = new URL(req.url);
    const token = (url.searchParams.get('token') ?? '').trim();
    if (!token) return errorJson('missing_token', 400, 'BAD_REQUEST');

    const svc = createServiceClient();
    const { data, error } = await svc.rpc('whatsapp_booking_token_view_v1', { p_token: token });
    if (error) return errorJson(error.message, 500, 'INTERNAL');

    const row = Array.isArray(data) ? data[0] : data;
    if (!row) return errorJson('not_found', 404, 'NOT_FOUND');

    return json({
      booking: {
        pickup: {
          lat: row.pickup_lat,
          lng: row.pickup_lng,
          address: row.pickup_address ?? null,
        },
        dropoff: {
          lat: row.dropoff_lat,
          lng: row.dropoff_lng,
          address: row.dropoff_address ?? null,
        },
        expires_at: row.expires_at,
      },
    });
  }),
);
