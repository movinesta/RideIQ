# Ably + Redis (Realtime Invalidation + Geo Cache)

## Ably (Nearby Drivers: Invalidate -> Refetch)

**Goal:** rider clients do not receive continuous driver location streams. Instead, the backend publishes tiny `invalidate` events to an area channel, and the rider refetches `drivers_nearby_user_v1`.

Channel naming:
- `nearby:gh6:<geohash6>`

Publishing behavior:
- `supabase/functions/driver-location-update` publishes `{ name: "invalidate", data: { t: <ms> } }`
- Message id is bucketed for idempotency: `inv:<geohash6>:<bucket>` where `bucket = floor(now / 2000)`

Token issuance:
- Riders call `supabase/functions/ably-token` (requires user JWT)
- The token capability is subscribe-only, scoped to exactly the requested channels.

Edge env vars:
- `ABLY_API_KEY=<appId>.<keyId>:<secret>`

Web env vars:
- None (web obtains tokens via `ably-token`)

Failure mode:
- If Ably is not configured or unavailable, the rider UI falls back to low-frequency polling.

## Redis (Geo Cache)

**Goal:** move geo cache reads/writes out of Postgres into Redis (JSON + TTL), with Postgres RPC as a fallback.

Redis key format:
- `geo:v1:<cacheKey>`

Edge env vars:
- `REDIS_URL=rediss://default:<password>@<host>:<port>`

Failure mode:
- If Redis is not configured or unavailable, `supabase/functions/geo` falls back to `geo_cache_get_v1` / `geo_cache_put_v1`.

