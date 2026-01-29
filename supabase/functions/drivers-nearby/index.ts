// supabase/functions/drivers-nearby/index.ts
// Nearby-drivers endpoint for browser maps (rider/admin).
//
// Why this exists:
// - GitHub Pages (movinesta.github.io) will send a CORS preflight OPTIONS request.
// - If the function doesn't exist / isn't deployed, preflight returns 404 and the browser blocks the POST.
// - We must explicitly handle OPTIONS and return CORS headers.

import { handleOptions } from "../_shared/cors.ts";
import { errorJson, json } from "../_shared/json.ts";
import { createServiceClient, requireUser } from "../_shared/supabase.ts";

type NearbyDriversBody = {
  pickup_lat: number;
  pickup_lng: number;
  radius_m?: number;
  limit_n?: number;
  stale_after_seconds?: number;
  required_capacity?: number;
};

function toNumber(v: unknown): number | null {
  const n = typeof v === "string" ? Number(v) : typeof v === "number" ? v : NaN;
  return Number.isFinite(n) ? n : null;
}

function clamp(n: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, n));
}

function hexToBytes(hex: string): Uint8Array {
  const clean = hex
    .trim()
    .replace(/^\\x/i, "")
    .replace(/^0x/i, "")
    .replace(/\s+/g, "");
  if (clean.length % 2 !== 0) throw new Error("Invalid hex length");
  const out = new Uint8Array(clean.length / 2);
  for (let i = 0; i < clean.length; i += 2) {
    out[i / 2] = parseInt(clean.slice(i, i + 2), 16);
  }
  return out;
}

// Decodes EWKB POINT hex like: 0101000020E6100000....
// EWKB layout: [byteOrder:1][type:uint32][srid?:uint32][x:float64][y:float64]
function decodeEwkbPointHex(hex: string): { lat: number; lng: number } {
  const bytes = hexToBytes(hex);
  const dv = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  const le = dv.getUint8(0) === 1;
  const type = dv.getUint32(1, le);
  let offset = 1 + 4;

  // SRID flag in EWKB
  const hasSrid = (type & 0x20000000) !== 0;
  if (hasSrid) offset += 4;

  const x = dv.getFloat64(offset, le);
  const y = dv.getFloat64(offset + 8, le);
  return { lng: x, lat: y };
}

function haversineMeters(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number,
): number {
  const R = 6371000; // meters
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
      Math.sin(dLng / 2) * Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

Deno.serve(async (req) => {
  const opt = handleOptions(req);
  if (opt) return opt;

  if (req.method !== "POST") {
    return errorJson("Method not allowed", 405, "METHOD_NOT_ALLOWED");
  }

  // Auth: require a real user (rider/admin). Preflight is allowed via OPTIONS.
  const { user, error: authError } = await requireUser(req);
  if (!user) {
    return errorJson(authError ?? "Unauthorized", 401, "UNAUTHORIZED");
  }

  let body: NearbyDriversBody;
  try {
    body = await req.json();
  } catch {
    return errorJson("Invalid JSON body", 400, "BAD_REQUEST");
  }

  const pickup_lat = toNumber(body?.pickup_lat);
  const pickup_lng = toNumber(body?.pickup_lng);
  if (pickup_lat === null || pickup_lng === null) {
    return errorJson("pickup_lat/pickup_lng are required", 400, "BAD_REQUEST");
  }

  const radius_m = clamp(toNumber(body?.radius_m) ?? 5000, 100, 50000);
  const limit_n = clamp(Math.trunc(toNumber(body?.limit_n) ?? 25), 1, 200);
  const stale_after_seconds = clamp(
    Math.trunc(toNumber(body?.stale_after_seconds) ?? 120),
    10,
    3600,
  );
  const required_capacity = clamp(
    Math.trunc(toNumber(body?.required_capacity) ?? 4),
    1,
    8,
  );

  const service = createServiceClient();

  // 1) Busy drivers (has an active ride)
  const busy = new Set<string>();
  {
    const { data, error } = await service
      .from("rides")
      .select("driver_id")
      .in("status", ["assigned", "arrived", "in_progress"]);
    if (error) {
      return errorJson(`Failed to load rides: ${error.message}`, 500, "DB_ERROR");
    }
    for (const r of data ?? []) {
      if (r?.driver_id) busy.add(String(r.driver_id));
    }
  }

  // 2) Recent driver locations (small/medium scale implementation)
  // NOTE: For very large fleets, replace with a PostGIS RPC for server-side radius filtering.
  const since = new Date(Date.now() - stale_after_seconds * 1000).toISOString();
  const { data: rows, error: locErr } = await service
    .from("driver_locations")
    .select(
      "driver_id, updated_at, loc, drivers(status, driver_vehicles(vehicle_type, capacity, is_active))",
    )
    .gte("updated_at", since)
    .limit(2000);

  if (locErr) {
    return errorJson(
      `Failed to load driver locations: ${locErr.message}`,
      500,
      "DB_ERROR",
    );
  }

  const candidates: Array<{
    id: string;
    lat: number;
    lng: number;
    dist_m: number;
    updated_at: string;
    vehicle_type: string;
  }> = [];

  for (const row of rows ?? []) {
    const driverId = String(row?.driver_id ?? "");
    if (!driverId) continue;
    if (busy.has(driverId)) continue;

    const driverObj = Array.isArray(row?.drivers) ? row.drivers[0] : row?.drivers;
    const status = driverObj?.status;
    if (status !== "available") continue;

    const vehicles = Array.isArray(driverObj?.driver_vehicles)
      ? driverObj.driver_vehicles
      : [];
    const activeVehicle = vehicles.find((v: any) => {
      const isActive = v?.is_active ?? true;
      const cap = typeof v?.capacity === "number" ? v.capacity : 4;
      return !!isActive && cap >= required_capacity;
    });
    if (!activeVehicle) continue;

    const locHex = row?.loc;
    if (typeof locHex !== "string" || locHex.length < 10) continue;

    let lat: number;
    let lng: number;
    try {
      ({ lat, lng } = decodeEwkbPointHex(locHex));
    } catch {
      continue;
    }

    const dist_m = haversineMeters(pickup_lat, pickup_lng, lat, lng);
    if (dist_m > radius_m) continue;

    candidates.push({
      id: driverId,
      lat,
      lng,
      dist_m,
      updated_at: row.updated_at,
      vehicle_type: String(activeVehicle?.vehicle_type ?? "car_taxi"),
    });
  }

  candidates.sort((a, b) => a.dist_m - b.dist_m);
  const drivers = candidates.slice(0, limit_n);

  return json({
    ok: true,
    request: {
      user_id: user.id,
      pickup_lat,
      pickup_lng,
      radius_m,
      limit_n,
      stale_after_seconds,
      required_capacity,
    },
    stats: {
      scanned_locations: rows?.length ?? 0,
      busy_drivers: busy.size,
      matched: drivers.length,
    },
    drivers,
  });
});
