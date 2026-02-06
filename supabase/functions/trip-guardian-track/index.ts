import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';

Deno.serve((req) => withRequestContext('trip-guardian-track', req, async (ctx) => {
    const preflight = handleOptions(req);
    if (preflight) return preflight;

    if (req.method !== 'GET') {
        return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED', undefined, ctx.headers);
    }

    const { user, error: authError } = await requireUser(req, ctx);
    if (!user) {
        return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED', undefined, ctx.headers);
    }

    const url = new URL(req.url);
    const tripId = url.searchParams.get('trip_id');

    if (!tripId) {
        return errorJson('trip_id query parameter is required', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }

    const service = createServiceClient();

    const { data, error } = await service.rpc('get_guardian_trip_info', {
        p_trip_id: tripId,
        p_guardian_id: user.id,
    });

    if (error) {
        if (error.message?.includes('forbidden')) {
            return errorJson('You are not authorized to track this trip', 403, 'FORBIDDEN', undefined, ctx.headers);
        }
        return errorJson(error.message, 400, 'TRACK_ERROR', undefined, ctx.headers);
    }

    // Redact sensitive info - only return what guardian needs for safety
    const tripInfo = Array.isArray(data) ? data[0] : data;

    if (!tripInfo) {
        return errorJson('Trip not found', 404, 'TRIP_NOT_FOUND', undefined, ctx.headers);
    }

    return json({
        trip: {
            id: tripInfo.trip_id,
            status: tripInfo.status,
            eta_minutes: tripInfo.eta_minutes,
            driver: {
                first_name: tripInfo.driver_first_name,
                vehicle: {
                    make: tripInfo.vehicle_make,
                    model: tripInfo.vehicle_model,
                    color: tripInfo.vehicle_color,
                },
            },
            location: {
                lat: tripInfo.current_lat,
                lng: tripInfo.current_lng,
            },
        },
    }, 200, ctx.headers);
}));
