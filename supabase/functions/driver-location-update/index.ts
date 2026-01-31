
import { handleOptions } from '../_shared/cors.ts';
import { errorJson, json } from '../_shared/json.ts';
import { consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { withRequestContext } from '../_shared/requestContext.ts';

type ValidVehicleType = 'car_private' | 'car_taxi' | 'motorcycle' | 'cargo';

type Body = {
    lat: number;
    lng: number;
    accuracy_m?: number;
    heading?: number;
    speed_mps?: number;
    vehicle_type: ValidVehicleType;
};

Deno.serve((req) => withRequestContext('driver-location-update', req, async (ctx) => {
    const preflight = handleOptions(req);
    if (preflight) return preflight;

    try {
        if (req.method !== 'POST') return errorJson('Method not allowed', 405);

        const { user, error: authErr } = await requireUser(req);
        if (authErr || !user) return errorJson('Unauthorized', 401, 'UNAUTHORIZED');

        const ip = getClientIp(req);

        // Rate Limit: 1 update per 3 seconds (approx 20 per minute)
        // This blocks DDOS attacks on the location table.
        const rl = await consumeRateLimit({
            key: `loc_up:${user.id}:${ip}`,
            windowSeconds: 60,
            limit: 20,
        });

        if (!rl.allowed) {
            // Just silently drop excess updates or return 429. 
            // For location tracking, 429 is fine as the client will just retry or send the next point later.
            return errorJson('Rate limit exceeded', 429, 'RATE_LIMIT');
        }

        const body = (await req.json().catch(() => ({}))) as Body;
        const { lat, lng, accuracy_m, heading, speed_mps, vehicle_type } = body;

        if (typeof lat !== 'number' || typeof lng !== 'number') {
            return errorJson('Invalid coordinates', 400, 'BAD_REQUEST');
        }

        const service = createServiceClient();

        // Perform the Upsert
        // We use the Service Client to bypass RLS policies if needed, 
        // or just to have a centralized writer role.
        const { error: dbErr } = await service.from('driver_locations').upsert({
            driver_id: user.id,
            vehicle_type: vehicle_type,
            lat,
            lng,
            accuracy_m,
            heading,
            speed_mps,
            updated_at: new Date().toISOString() // Force server time
        });

        if (dbErr) {
            ctx.log('DB Error', { error: dbErr });
            return errorJson('Database error', 500, 'DB_ERROR');
        }

        return json({ ok: true });

    } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        return errorJson(msg, 500, 'INTERNAL_ERROR');
    }
}));
