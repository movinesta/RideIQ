-- RideIQ Squashed Migrations: 01_ops_pricing_dispatch.sql
-- Generated: 2026-01-25T21:51:19.003119Z
-- Notes:
-- - This squashed set EXCLUDES 20260124_000001_init.sql (already applied).
-- - Source migrations merged here: 20260124_000004_scheduled_rides.sql (without cron schedule), 20260125_000006_service_areas.sql, 20260125_000007_service_area_admin_rpcs.sql, 20260125_000008_ride_intents_and_pricing_override.sql, 20260125_000009_women_family_prefs_and_kyc_gating.sql, 20260125_000011_user_notifications_unread_index.sql, 20260125_000012_pricing_fairness_surge_caps.sql, 20260124_000005_scheduled_rides_cron_fix.sql (index only)
-- - Run files in order: 01 -> 02 -> 03 -> 04 -> 05

-- Session 3: Scheduled rides (minimal, isolated addition)
-- Design goals:
-- - No changes to existing ride flow.
-- - Store future rides separately and materialize them into ride_requests when due.
-- - Use pg_cron to run a small DB function every minute.
--
-- Supabase recommends pg_cron for scheduling recurring jobs. See docs.

DO $$
BEGIN
  -- Create enum only if it doesn't exist
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'scheduled_ride_status') THEN
    CREATE TYPE public.scheduled_ride_status AS ENUM ('pending', 'cancelled', 'executed', 'failed');
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.scheduled_rides (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  rider_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,

  pickup_lat double precision NOT NULL,
  pickup_lng double precision NOT NULL,
  dropoff_lat double precision NOT NULL,
  dropoff_lng double precision NOT NULL,
  pickup_address text,
  dropoff_address text,

  product_code text NOT NULL DEFAULT 'standard',
  scheduled_at timestamptz NOT NULL,

  status public.scheduled_ride_status NOT NULL DEFAULT 'pending',

  ride_request_id uuid REFERENCES public.ride_requests(id) ON DELETE SET NULL,
  executed_at timestamptz,
  cancelled_at timestamptz,
  failure_reason text,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Indexes (keep it simple + fast for the runner and user listing)
CREATE INDEX IF NOT EXISTS idx_scheduled_rides_rider_time ON public.scheduled_rides (rider_id, scheduled_at DESC);
CREATE INDEX IF NOT EXISTS idx_scheduled_rides_due ON public.scheduled_rides (scheduled_at) WHERE status = 'pending';
CREATE UNIQUE INDEX IF NOT EXISTS idx_scheduled_rides_request_id ON public.scheduled_rides (ride_request_id) WHERE ride_request_id IS NOT NULL;

-- updated_at trigger
DROP TRIGGER IF EXISTS scheduled_rides_set_updated_at ON public.scheduled_rides;
CREATE TRIGGER scheduled_rides_set_updated_at
BEFORE UPDATE ON public.scheduled_rides
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- RLS
ALTER TABLE public.scheduled_rides ENABLE ROW LEVEL SECURITY;

-- Service role bypass (common pattern in this repo)
DROP POLICY IF EXISTS rls_service_role_all ON public.scheduled_rides;
CREATE POLICY rls_service_role_all ON public.scheduled_rides
TO service_role
USING (true) WITH CHECK (true);

-- Riders: CRUD their own scheduled rides (cancel/update only while pending)
DROP POLICY IF EXISTS scheduled_rides_select_own_or_admin ON public.scheduled_rides;
CREATE POLICY scheduled_rides_select_own_or_admin ON public.scheduled_rides
FOR SELECT TO authenticated
USING (
  rider_id = (SELECT auth.uid())
  OR (SELECT public.is_admin())
);

DROP POLICY IF EXISTS scheduled_rides_insert_own ON public.scheduled_rides;
CREATE POLICY scheduled_rides_insert_own ON public.scheduled_rides
FOR INSERT TO authenticated
WITH CHECK (rider_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS scheduled_rides_update_own_pending ON public.scheduled_rides;
CREATE POLICY scheduled_rides_update_own_pending ON public.scheduled_rides
FOR UPDATE TO authenticated
USING (
  rider_id = (SELECT auth.uid())
  AND status = 'pending'
)
WITH CHECK (rider_id = (SELECT auth.uid()));

-- Runner: materialize due scheduled rides into ride_requests and attempt matching via dispatch_match_ride
CREATE OR REPLACE FUNCTION public.scheduled_rides_execute_due(p_limit integer DEFAULT 50)
RETURNS integer
LANGUAGE plpgsql
AS $$
DECLARE
  r record;
  v_request_id uuid;
  v_count integer := 0;
BEGIN
  FOR r IN
    SELECT *
    FROM public.scheduled_rides
    WHERE status = 'pending'
      AND scheduled_at <= now()
    ORDER BY scheduled_at ASC
    LIMIT p_limit
    FOR UPDATE SKIP LOCKED
  LOOP
    BEGIN
      INSERT INTO public.ride_requests (
        rider_id,
        pickup_lat,
        pickup_lng,
        dropoff_lat,
        dropoff_lng,
        pickup_address,
        dropoff_address,
        product_code
      )
      VALUES (
        r.rider_id,
        r.pickup_lat,
        r.pickup_lng,
        r.dropoff_lat,
        r.dropoff_lng,
        r.pickup_address,
        r.dropoff_address,
        r.product_code
      )
      RETURNING id INTO v_request_id;

      -- Attempt matching using the existing dispatch function (keeps behavior consistent).
      PERFORM 1 FROM public.dispatch_match_ride(v_request_id, r.rider_id);

      UPDATE public.scheduled_rides
      SET
        status = 'executed',
        executed_at = now(),
        ride_request_id = v_request_id,
        failure_reason = NULL
      WHERE id = r.id;

      v_count := v_count + 1;
    EXCEPTION WHEN OTHERS THEN
      UPDATE public.scheduled_rides
      SET
        status = 'failed',
        failure_reason = SQLERRM
      WHERE id = r.id;
    END;
  END LOOP;

  RETURN v_count;
END;
$$;


-- Session 5: Service areas (multi-city readiness) - minimal, clean addition
-- Goals:
-- - Define active operating areas (polygons) per governorate/city.
-- - Allow app to resolve pickup point -> service_area.
-- - Store service_area_id on ride_requests and scheduled_rides (nullable for backward compatibility).
-- - Provide a simple seed "Baghdad" area for local testing / default demo coords.

-- Requires PostGIS (already enabled in init schema). See Supabase docs for PostGIS usage.

CREATE TABLE IF NOT EXISTS public.service_areas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  governorate text,
  is_active boolean NOT NULL DEFAULT true,
  priority integer NOT NULL DEFAULT 0,
  pricing_config_id uuid REFERENCES public.pricing_configs(id) ON DELETE SET NULL,
  geom geometry(MULTIPOLYGON, 4326) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT service_areas_name_governorate_key UNIQUE (name, governorate)
);

-- Keep updated_at consistent with the rest of the schema
DROP TRIGGER IF EXISTS trg_service_areas_set_updated_at ON public.service_areas;
CREATE TRIGGER trg_service_areas_set_updated_at
BEFORE UPDATE ON public.service_areas
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Indexes for fast area lookup
CREATE INDEX IF NOT EXISTS idx_service_areas_active_priority ON public.service_areas (is_active, priority DESC);
CREATE INDEX IF NOT EXISTS idx_service_areas_geom_gist ON public.service_areas USING GIST (geom);

-- Add nullable FK columns (backward compatible)
ALTER TABLE public.ride_requests
  ADD COLUMN IF NOT EXISTS service_area_id uuid REFERENCES public.service_areas(id) ON DELETE SET NULL;

ALTER TABLE public.scheduled_rides
  ADD COLUMN IF NOT EXISTS service_area_id uuid REFERENCES public.service_areas(id) ON DELETE SET NULL;

-- Resolver: pickup point -> best matching active service area
CREATE OR REPLACE FUNCTION public.resolve_service_area(
  p_lat double precision,
  p_lng double precision
)
RETURNS TABLE (
  id uuid,
  name text,
  governorate text,
  pricing_config_id uuid
)
LANGUAGE sql
STABLE
AS $$
  SELECT sa.id, sa.name, sa.governorate, sa.pricing_config_id
  FROM public.service_areas sa
  WHERE sa.is_active
    AND ST_Contains(sa.geom, ST_SetSRID(ST_Point(p_lng, p_lat), 4326))
  ORDER BY sa.priority DESC, sa.created_at DESC
  LIMIT 1;
$$;

-- Auto-populate service_area_id on inserts/updates when missing
CREATE OR REPLACE FUNCTION public.set_service_area_id_from_pickup()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_area uuid;
BEGIN
  IF NEW.service_area_id IS NULL THEN
    SELECT id INTO v_area FROM public.resolve_service_area(NEW.pickup_lat, NEW.pickup_lng);
    NEW.service_area_id := v_area;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_ride_requests_set_service_area ON public.ride_requests;
CREATE TRIGGER trg_ride_requests_set_service_area
BEFORE INSERT OR UPDATE OF pickup_lat, pickup_lng ON public.ride_requests
FOR EACH ROW
EXECUTE FUNCTION public.set_service_area_id_from_pickup();

DROP TRIGGER IF EXISTS trg_scheduled_rides_set_service_area ON public.scheduled_rides;
CREATE TRIGGER trg_scheduled_rides_set_service_area
BEFORE INSERT OR UPDATE OF pickup_lat, pickup_lng ON public.scheduled_rides
FOR EACH ROW
EXECUTE FUNCTION public.set_service_area_id_from_pickup();

-- RLS
ALTER TABLE public.service_areas ENABLE ROW LEVEL SECURITY;

-- One SELECT policy only (avoid multiple permissive select warnings)
DROP POLICY IF EXISTS service_areas_select_active_or_admin ON public.service_areas;
CREATE POLICY service_areas_select_active_or_admin
ON public.service_areas
FOR SELECT
TO authenticated
USING (is_active = true OR (SELECT public.is_admin()));

-- Admin write policy (single)
DROP POLICY IF EXISTS service_areas_admin_write ON public.service_areas;
CREATE POLICY service_areas_admin_write
ON public.service_areas
FOR ALL
TO authenticated
USING ((SELECT public.is_admin()))
WITH CHECK ((SELECT public.is_admin()));

-- Seed: Baghdad demo polygon (bbox) for default coords (33.31, 44.36)
INSERT INTO public.service_areas (name, governorate, is_active, priority, geom)
VALUES (
  'Baghdad (Demo)',
  'Baghdad',
  true,
  10,
  ST_Multi(ST_MakeEnvelope(44.05, 33.05, 44.75, 33.55, 4326))
)
ON CONFLICT (name, governorate) DO NOTHING;

-- Session 5: Admin helper RPCs for service areas
-- Keep UI simple: create areas from bounding boxes (no map editor yet).

CREATE OR REPLACE FUNCTION public.admin_create_service_area_bbox(
  p_name text,
  p_governorate text,
  p_min_lat double precision,
  p_min_lng double precision,
  p_max_lat double precision,
  p_max_lng double precision,
  p_priority integer DEFAULT 0,
  p_is_active boolean DEFAULT true,
  p_pricing_config_id uuid DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id uuid;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not authorized' USING ERRCODE = '42501';
  END IF;

  INSERT INTO public.service_areas (
    name, governorate, is_active, priority, pricing_config_id, geom
  )
  VALUES (
    p_name,
    p_governorate,
    COALESCE(p_is_active, true),
    COALESCE(p_priority, 0),
    p_pricing_config_id,
    ST_Multi(ST_MakeEnvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326))
  )
  ON CONFLICT (name, governorate) DO UPDATE
    SET is_active = EXCLUDED.is_active,
        priority = EXCLUDED.priority,
        pricing_config_id = EXCLUDED.pricing_config_id,
        geom = EXCLUDED.geom,
        updated_at = now()
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_create_service_area_bbox(
  text, text, double precision, double precision, double precision, double precision, integer, boolean, uuid
) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.admin_create_service_area_bbox(
  text, text, double precision, double precision, double precision, double precision, integer, boolean, uuid
) TO authenticated;

-- Session 6: Iraq market ops additions (minimal, clean)
-- 1) Fallback booking via WhatsApp (ride_intents)
-- 2) Service-area pricing override (use service_areas.pricing_config_id when present)

-- =========================
-- 1) ride_intents (lead capture + admin conversion)
-- =========================

CREATE TABLE IF NOT EXISTS public.ride_intents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  rider_id uuid NOT NULL,

  pickup_lat double precision NOT NULL,
  pickup_lng double precision NOT NULL,
  pickup_loc extensions.geography(Point,4326)
    GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(pickup_lng, pickup_lat), 4326))::extensions.geography) STORED,
  dropoff_lat double precision NOT NULL,
  dropoff_lng double precision NOT NULL,
  dropoff_loc extensions.geography(Point,4326)
    GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(dropoff_lng, dropoff_lat), 4326))::extensions.geography) STORED,

  pickup_address text,
  dropoff_address text,

  service_area_id uuid REFERENCES public.service_areas(id) ON DELETE SET NULL,
  product_code text NOT NULL DEFAULT 'standard',
  scheduled_at timestamptz,

  source text NOT NULL DEFAULT 'whatsapp',
  status text NOT NULL DEFAULT 'new',
  converted_request_id uuid REFERENCES public.ride_requests(id) ON DELETE SET NULL,
  notes text,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT ride_intents_status_check CHECK (status IN ('new','converted','closed')),
  CONSTRAINT ride_intents_pickup_lat_check CHECK (pickup_lat >= -90 AND pickup_lat <= 90),
  CONSTRAINT ride_intents_pickup_lng_check CHECK (pickup_lng >= -180 AND pickup_lng <= 180),
  CONSTRAINT ride_intents_dropoff_lat_check CHECK (dropoff_lat >= -90 AND dropoff_lat <= 90),
  CONSTRAINT ride_intents_dropoff_lng_check CHECK (dropoff_lng >= -180 AND dropoff_lng <= 180)
);

-- Keep updated_at consistent with the rest of the schema
DROP TRIGGER IF EXISTS trg_ride_intents_set_updated_at ON public.ride_intents;
CREATE TRIGGER trg_ride_intents_set_updated_at
BEFORE UPDATE ON public.ride_intents
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Indexes
CREATE INDEX IF NOT EXISTS idx_ride_intents_rider_created_at ON public.ride_intents (rider_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ride_intents_status_created_at ON public.ride_intents (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ride_intents_service_area ON public.ride_intents (service_area_id);
CREATE INDEX IF NOT EXISTS idx_ride_intents_pickup_loc_gist ON public.ride_intents USING GIST (pickup_loc);

-- RLS
ALTER TABLE public.ride_intents ENABLE ROW LEVEL SECURITY;

-- Riders can see their own intents; admins can see all.
DROP POLICY IF EXISTS ride_intents_select_self_or_admin ON public.ride_intents;
CREATE POLICY ride_intents_select_self_or_admin
ON public.ride_intents
FOR SELECT
TO authenticated
USING (
  rider_id = (SELECT auth.uid())
  OR (SELECT public.is_admin())
);

-- Riders can insert their own intents (status fixed to 'new'); admins can insert for ops.
DROP POLICY IF EXISTS ride_intents_insert_self_or_admin ON public.ride_intents;
CREATE POLICY ride_intents_insert_self_or_admin
ON public.ride_intents
FOR INSERT
TO authenticated
WITH CHECK (
  (
    rider_id = (SELECT auth.uid())
    AND status = 'new'
  )
  OR (SELECT public.is_admin())
);

-- Only admins can update/delete (conversion workflow)
-- Keep policies granular to avoid "multiple permissive" linter warnings.

DROP POLICY IF EXISTS ride_intents_update_admin ON public.ride_intents;
CREATE POLICY ride_intents_update_admin
ON public.ride_intents
FOR UPDATE
TO authenticated
USING ((SELECT public.is_admin()))
WITH CHECK ((SELECT public.is_admin()));

DROP POLICY IF EXISTS ride_intents_delete_admin ON public.ride_intents;
CREATE POLICY ride_intents_delete_admin
ON public.ride_intents
FOR DELETE
TO authenticated
USING ((SELECT public.is_admin()));


-- =========================
-- 2) Pricing override per service area
-- =========================

-- For backward compatibility, keep function signatures the same.
-- If service_areas.pricing_config_id is set for the pickup point's area, use it.
-- Otherwise, fall back to the latest active pricing config.

CREATE OR REPLACE FUNCTION public.estimate_ride_quote_iqd(
  _pickup extensions.geography,
  _dropoff extensions.geography
) RETURNS integer
LANGUAGE plpgsql STABLE
SET search_path TO 'pg_catalog, extensions'
AS $$
declare
  cfg record;
  dist_m double precision;
  dist_km numeric;
  quote integer;
  pickup_lat double precision;
  pickup_lng double precision;
  area_id uuid;
  area_pricing_id uuid;
begin
  pickup_lat := extensions.st_y(_pickup::extensions.geometry);
  pickup_lng := extensions.st_x(_pickup::extensions.geometry);

  select id, pricing_config_id
    into area_id, area_pricing_id
  from public.resolve_service_area(pickup_lat, pickup_lng);

  -- Prefer a service-area override (if present) but safely fall back to the latest active config.
  select currency, base_fare_iqd, per_km_iqd, per_min_iqd, minimum_fare_iqd
    into cfg
  from (
    select pc.currency, pc.base_fare_iqd, pc.per_km_iqd, pc.per_min_iqd, pc.minimum_fare_iqd, 1 as precedence, pc.created_at
    from public.pricing_configs pc
    where pc.id = area_pricing_id

    union all

    select pc.currency, pc.base_fare_iqd, pc.per_km_iqd, pc.per_min_iqd, pc.minimum_fare_iqd, 2 as precedence, pc.created_at
    from public.pricing_configs pc
    where pc.active = true
  ) s
  order by s.precedence asc, s.created_at desc
  limit 1;

  dist_m := extensions.st_distance(_pickup::extensions.geometry, _dropoff::extensions.geometry);
  dist_km := greatest(0, dist_m / 1000.0);

  -- MVP: base + per_km, ignore duration for now
  quote := (cfg.base_fare_iqd + ceil(dist_km * cfg.per_km_iqd))::integer;
  quote := greatest(quote, cfg.minimum_fare_iqd);
  return quote;
end;
$$;


CREATE OR REPLACE FUNCTION public.estimate_ride_quote_iqd_v2(
  _pickup extensions.geography,
  _dropoff extensions.geography,
  _product_code text DEFAULT 'standard'
) RETURNS integer
LANGUAGE plpgsql STABLE
SET search_path TO 'pg_catalog, extensions'
AS $$
declare
  cfg record;
  dist_m double precision;
  dist_km numeric;
  quote integer;
  mult numeric;
  pickup_lat double precision;
  pickup_lng double precision;
  area_id uuid;
  area_pricing_id uuid;
begin
  pickup_lat := extensions.st_y(_pickup::extensions.geometry);
  pickup_lng := extensions.st_x(_pickup::extensions.geometry);

  select id, pricing_config_id
    into area_id, area_pricing_id
  from public.resolve_service_area(pickup_lat, pickup_lng);

  -- Prefer a service-area override (if present) but safely fall back to the latest active config.
  select currency, base_fare_iqd, per_km_iqd, per_min_iqd, minimum_fare_iqd
    into cfg
  from (
    select pc.currency, pc.base_fare_iqd, pc.per_km_iqd, pc.per_min_iqd, pc.minimum_fare_iqd, 1 as precedence, pc.created_at
    from public.pricing_configs pc
    where pc.id = area_pricing_id

    union all

    select pc.currency, pc.base_fare_iqd, pc.per_km_iqd, pc.per_min_iqd, pc.minimum_fare_iqd, 2 as precedence, pc.created_at
    from public.pricing_configs pc
    where pc.active = true
  ) s
  order by s.precedence asc, s.created_at desc
  limit 1;

  select coalesce((select rp.price_multiplier from public.ride_products rp where rp.code = _product_code), 1)
    into mult;

  dist_m := extensions.st_distance(_pickup::extensions.geometry, _dropoff::extensions.geometry);
  dist_km := greatest(0, dist_m / 1000.0);

  quote := (cfg.base_fare_iqd + ceil(dist_km * cfg.per_km_iqd))::integer;
  quote := greatest(quote, cfg.minimum_fare_iqd);
  quote := ceil(quote * mult)::integer;

  return quote;
end;
$$;

-- Session 7: Women/Family preferences + KYC gating (minimal, production-safe)
-- Notes:
-- - Adds preferences JSONB for ride_requests / scheduled_rides / ride_intents
-- - Adds profiles.gender for women-only matching
-- - Locks down profile_kyc and kyc_submissions so users cannot self-verify
-- - Requires driver KYC verified to go online (available)
-- - Updates dispatch_match_ride to enforce verified drivers + women preference matching
--
-- Best-practice reminder: wrap auth.* calls with (select ...) in RLS to enable initPlan caching.

begin;

-- ---------------------------------------------------------------------------
-- 1) Minimal schema additions
-- ---------------------------------------------------------------------------

alter table public.profiles
  add column if not exists gender text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'profiles_gender_check'
      and conrelid = 'public.profiles'::regclass
  ) then
    alter table public.profiles
      add constraint profiles_gender_check
      check (gender is null or gender in ('male','female','unknown'));
  end if;
end$$;

alter table public.ride_requests
  add column if not exists preferences jsonb not null default '{}'::jsonb;

alter table public.scheduled_rides
  add column if not exists preferences jsonb not null default '{}'::jsonb;

alter table public.ride_intents
  add column if not exists preferences jsonb not null default '{}'::jsonb;

-- ---------------------------------------------------------------------------
-- 2) Ride products: ensure "family" + "women_only" exist (idempotent)
-- ---------------------------------------------------------------------------

insert into public.ride_products (code, name, description, capacity_min, price_multiplier, sort_order, is_active)
values
  ('family', 'Family', 'Larger vehicle for families (min 5 seats)', 5, 1.150, 20, true),
  ('women_only', 'Women Only', 'Female driver preference', 4, 1.080, 30, true)
on conflict (code) do update
set
  name = excluded.name,
  description = excluded.description,
  capacity_min = excluded.capacity_min,
  price_multiplier = excluded.price_multiplier,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active,
  updated_at = now();

-- ---------------------------------------------------------------------------
-- 3) KYC security: lock down profile_kyc (users should NOT be able to update it)
-- ---------------------------------------------------------------------------

drop policy if exists rls_insert on public.profile_kyc;
drop policy if exists rls_update on public.profile_kyc;
drop policy if exists rls_delete on public.profile_kyc;

-- Keep existing rls_select (own) + service_role_all, and add admin-only write policies.
drop policy if exists profile_kyc_admin_update on public.profile_kyc;
drop policy if exists profile_kyc_admin_delete on public.profile_kyc;

create policy profile_kyc_admin_update
on public.profile_kyc
for update
to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

create policy profile_kyc_admin_delete
on public.profile_kyc
for delete
to authenticated
using ((select public.is_admin()));

-- ---------------------------------------------------------------------------
-- 4) KYC submissions: owners can edit only draft/submitted; admins can review
-- ---------------------------------------------------------------------------

drop policy if exists kyc_submissions_update_owner_or_admin on public.kyc_submissions;
drop policy if exists kyc_submissions_update_owner_draft_or_submitted on public.kyc_submissions;
drop policy if exists kyc_submissions_update_admin on public.kyc_submissions;

create policy kyc_submissions_update_owner_draft_or_submitted
on public.kyc_submissions
for update
to authenticated
using (
  (
    (user_id = (select auth.uid()) or profile_id = (select auth.uid()))
    and status in ('draft','submitted')
  )
)
with check (
  -- Owner can only keep it in draft/submitted and cannot set reviewer fields.
  (user_id = (select auth.uid()) or profile_id = (select auth.uid()))
  and status in ('draft','submitted')
  and reviewer_id is null
  and reviewed_at is null
);

create policy kyc_submissions_update_admin
on public.kyc_submissions
for update
to authenticated
using ((select public.is_admin()))
with check ((select public.is_admin()));

-- Ensure submission trigger can update profile_kyc under the new policy.
alter function public.sync_profile_kyc_from_submission() security definer;

-- ---------------------------------------------------------------------------
-- 5) Driver KYC gating: cannot go 'available' unless verified
-- ---------------------------------------------------------------------------

drop policy if exists drivers_update_self on public.drivers;

create policy drivers_update_self
on public.drivers
for update
to authenticated
using (id = (select auth.uid()))
with check (
  id = (select auth.uid())
  and (
    status <> 'available'::public.driver_status
    or exists (
      select 1
      from public.profile_kyc pk
      where pk.user_id = (select auth.uid())
        and pk.status = 'verified'::public.kyc_status
    )
  )
);

-- ---------------------------------------------------------------------------
-- 6) Matching: enforce verified drivers and women-only preference
-- ---------------------------------------------------------------------------

create or replace function public.dispatch_match_ride(
  p_request_id uuid,
  p_rider_id uuid,
  p_radius_m numeric default 5000,
  p_limit_n integer default 20,
  p_match_ttl_seconds integer default 120,
  p_stale_after_seconds integer default 30
) returns table(
  id uuid,
  status public.ride_request_status,
  assigned_driver_id uuid,
  match_deadline timestamp with time zone,
  match_attempts integer,
  matched_at timestamp with time zone
)
language plpgsql
security definer
set search_path = 'pg_catalog, public, auth, extensions'
as $$
#variable_conflict use_column
declare
  rr record;
  candidate uuid;
  up record;
  tried uuid[] := '{}'::uuid[];
  v_balance bigint;
  v_held bigint;
  v_available bigint;
  v_quote bigint;
  v_req_capacity int := 4;
  v_need_female boolean := false;
begin
  select * into rr
  from public.ride_requests as req
  where req.id = p_request_id
  for update;

  if not found then
    raise exception 'ride_request_not_found';
  end if;

  if rr.rider_id <> p_rider_id then
    raise exception 'forbidden';
  end if;

  if rr.status = 'accepted' then
    return query select rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
    return;
  end if;

  if rr.status = 'matched' and rr.match_deadline is not null and rr.match_deadline <= now() then
    update public.drivers
      set status = 'available'
      where id = rr.assigned_driver_id and status = 'assigned';
    update public.ride_requests
      set status = 'requested',
          assigned_driver_id = null,
          match_deadline = null
      where id = rr.id;
    rr.status := 'requested';
    rr.assigned_driver_id := null;
    rr.match_deadline := null;
  end if;

  select capacity_min into v_req_capacity
  from public.ride_products
  where code = rr.product_code;

  v_req_capacity := coalesce(v_req_capacity, 4);

  -- Women-only requirements (minimal):
  -- - product_code='women_only' OR preferences.preferred_driver_gender='female'
  v_need_female :=
    (rr.product_code = 'women_only')
    or (coalesce(rr.preferences->>'preferred_driver_gender','') = 'female');

  -- Ensure wallet balance covers quote (existing logic)
  v_quote := coalesce(rr.quote_amount_iqd, 0)::bigint;

  select wa.balance_iqd into v_balance
  from public.wallet_accounts wa
  where wa.user_id = rr.rider_id;

  v_balance := coalesce(v_balance, 0);

  select coalesce(sum(h.amount_iqd), 0)::bigint into v_held
  from public.wallet_holds h
  where h.user_id = rr.rider_id
    and h.status = 'held';

  v_available := v_balance - v_held;

  if v_available < v_quote then
    raise exception 'insufficient_balance';
  end if;

  -- Try matching until we find a lockable candidate.
  loop
    with pickup as (
      select req.pickup_loc as pickup
      from public.ride_requests req
      where req.id = rr.id
    ),
    candidates as (
      select d.id as driver_id
      from public.drivers d
      join public.driver_locations dl on dl.driver_id = d.id
      cross join pickup
      -- Verified driver check
      join public.profile_kyc pk on pk.user_id = d.id and pk.status = 'verified'::public.kyc_status
      -- Gender check (only when needed)
      left join public.profiles pr on pr.id = d.id
      where d.status = 'available'
        and (array_length(tried, 1) is null or d.id <> all(tried))
        and dl.updated_at >= now() - make_interval(secs => p_stale_after_seconds)
        and extensions.st_dwithin(dl.loc, pickup.pickup, (p_radius_m)::double precision, true)
        and exists (
          select 1 from public.driver_vehicles v
          where v.driver_id = d.id
            and coalesce(v.is_active, true) = true
            and coalesce(v.capacity, 4) >= v_req_capacity
        )
        and not exists (
          select 1 from public.rides r
          where r.driver_id = d.id
            and r.status in ('assigned','arrived','in_progress')
        )
        and (
          not v_need_female
          or coalesce(pr.gender,'unknown') = 'female'
        )
      order by extensions.st_distance(dl.loc, pickup.pickup)
      limit p_limit_n
    ),
    locked as (
      select c.driver_id
      from candidates c
      join public.drivers d on d.id = c.driver_id
      where d.status = 'available'
      for update of d skip locked
      limit 1
    )
    select driver_id into candidate from locked;

    exit when candidate is null;

    -- Mark driver as assigned
    update public.drivers
      set status = 'assigned'
      where id = candidate
        and status = 'available';

    if found then
      update public.ride_requests
        set status = 'matched',
            assigned_driver_id = candidate,
            match_deadline = now() + make_interval(secs => p_match_ttl_seconds),
            matched_at = now(),
            match_attempts = coalesce(match_attempts, 0) + 1
        where id = rr.id;

      return query
        select rr.id, 'matched'::public.ride_request_status, candidate,
               now() + make_interval(secs => p_match_ttl_seconds),
               coalesce(rr.match_attempts, 0) + 1,
               now();
      return;
    end if;

    tried := array_append(tried, candidate);
    candidate := null;
  end loop;

  -- If no candidate, keep requested state but bump match attempts and deadline
  update public.ride_requests
    set match_attempts = coalesce(match_attempts, 0) + 1
    where id = rr.id;

  return query
    select rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
end;
$$;

commit;

-- Session 9
-- Improve unread notifications performance and remove a redundant index.

-- Fast unread-count queries: WHERE user_id = ? AND read_at IS NULL
CREATE INDEX IF NOT EXISTS ix_user_notifications_unread
  ON public.user_notifications (user_id)
  WHERE read_at IS NULL;

-- Redundant index (user_id alone) - covered by ix_user_notifications_user_created (user_id, created_at DESC)
DROP INDEX IF EXISTS public.ix_user_notifications_user_notifications_user_id_fkey_fkey;

-- Session 11: Pricing fairness (transparent quoting) + surge caps (minimal, backward-compatible)
--
-- Adds:
-- - pricing_configs.max_surge_multiplier (caps surge multiplier only; product multipliers remain unchanged)
-- - service_areas.min_base_fare_iqd (optional) + service_areas.surge_multiplier (ops-controlled)
-- - JSON quote breakdown RPC for the frontend
--
-- Notes:
-- - Existing integer quote functions keep their signatures.
-- - Triggers that fill ride_requests.quote_amount_iqd are updated to use product_code.

-- =========================
-- 1) Columns
-- =========================

ALTER TABLE public.pricing_configs
  ADD COLUMN IF NOT EXISTS max_surge_multiplier numeric NOT NULL DEFAULT 1.5;

COMMENT ON COLUMN public.pricing_configs.max_surge_multiplier
  IS 'Maximum allowed surge multiplier (demand-based). Does not cap product multipliers.';

ALTER TABLE public.service_areas
  ADD COLUMN IF NOT EXISTS min_base_fare_iqd integer,
  ADD COLUMN IF NOT EXISTS surge_multiplier numeric NOT NULL DEFAULT 1.0,
  ADD COLUMN IF NOT EXISTS surge_reason text;

COMMENT ON COLUMN public.service_areas.min_base_fare_iqd
  IS 'Optional minimum base fare override (IQD) for rides in this service area.';

COMMENT ON COLUMN public.service_areas.surge_multiplier
  IS 'Ops-controlled raw surge multiplier for this service area (>= 1.0). Capped by pricing_configs.max_surge_multiplier.';

-- Keep values sane
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'service_areas' AND column_name = 'surge_multiplier'
  ) THEN
    ALTER TABLE public.service_areas
      DROP CONSTRAINT IF EXISTS service_areas_surge_multiplier_check;
    ALTER TABLE public.service_areas
      ADD CONSTRAINT service_areas_surge_multiplier_check CHECK (surge_multiplier >= 1.0);
  END IF;
END $$;

-- =========================
-- 2) Quote breakdown (JSON)
-- =========================

CREATE OR REPLACE FUNCTION public.estimate_ride_quote_breakdown_iqd_v1(
  _pickup extensions.geography,
  _dropoff extensions.geography,
  _product_code text DEFAULT 'standard'
) RETURNS jsonb
LANGUAGE plpgsql STABLE
SET search_path TO 'pg_catalog, extensions'
AS $$
DECLARE
  cfg record;
  dist_m double precision;
  dist_km numeric;
  base_fare_iqd integer;
  per_km_iqd integer;
  minimum_fare_iqd integer;

  pickup_lat double precision;
  pickup_lng double precision;
  area_id uuid;
  area_pricing_id uuid;
  area_min_base integer;
  area_surge_raw numeric;
  area_surge_reason text;

  product_mult numeric;
  surge_cap numeric;
  surge_applied numeric;

  base_plus_dist integer;
  distance_fare_iqd integer;
  subtotal_iqd integer;
  total_iqd integer;
BEGIN
  pickup_lat := extensions.st_y(_pickup::extensions.geometry);
  pickup_lng := extensions.st_x(_pickup::extensions.geometry);

  SELECT id, pricing_config_id
    INTO area_id, area_pricing_id
  FROM public.resolve_service_area(pickup_lat, pickup_lng);

  -- Fetch service-area overrides (may be null if out-of-area)
  SELECT sa.min_base_fare_iqd, COALESCE(sa.surge_multiplier, 1.0), sa.surge_reason
    INTO area_min_base, area_surge_raw, area_surge_reason
  FROM public.service_areas sa
  WHERE sa.id = area_id;

  -- Prefer a service-area override pricing config (if present) but safely fall back to the latest active config.
  SELECT currency, base_fare_iqd, per_km_iqd, per_min_iqd, minimum_fare_iqd, max_surge_multiplier
    INTO cfg
  FROM (
    SELECT pc.currency, pc.base_fare_iqd, pc.per_km_iqd, pc.per_min_iqd, pc.minimum_fare_iqd, pc.max_surge_multiplier,
           1 AS precedence, pc.created_at
    FROM public.pricing_configs pc
    WHERE pc.id = area_pricing_id

    UNION ALL

    SELECT pc.currency, pc.base_fare_iqd, pc.per_km_iqd, pc.per_min_iqd, pc.minimum_fare_iqd, pc.max_surge_multiplier,
           2 AS precedence, pc.created_at
    FROM public.pricing_configs pc
    WHERE pc.active = true
  ) s
  ORDER BY s.precedence ASC, s.created_at DESC
  LIMIT 1;

  base_fare_iqd := COALESCE(cfg.base_fare_iqd, 0);
  per_km_iqd := COALESCE(cfg.per_km_iqd, 0);
  minimum_fare_iqd := COALESCE(cfg.minimum_fare_iqd, 0);
  surge_cap := COALESCE(cfg.max_surge_multiplier, 1.5);

  IF area_min_base IS NOT NULL THEN
    base_fare_iqd := GREATEST(base_fare_iqd, area_min_base);
  END IF;

  -- Product multiplier
  SELECT COALESCE((SELECT rp.price_multiplier FROM public.ride_products rp WHERE rp.code = _product_code), 1)
    INTO product_mult;

  dist_m := extensions.st_distance(_pickup::extensions.geometry, _dropoff::extensions.geometry);
  dist_km := GREATEST(0, dist_m / 1000.0);

  -- Core fare (duration ignored in MVP)
  distance_fare_iqd := CEIL(dist_km * per_km_iqd)::integer;
  base_plus_dist := (base_fare_iqd + distance_fare_iqd)::integer;

  -- Enforce minimum before multipliers (matches previous behavior)
  subtotal_iqd := GREATEST(base_plus_dist, minimum_fare_iqd);

  -- Surge: clamp to >= 1 and apply cap
  area_surge_raw := GREATEST(COALESCE(area_surge_raw, 1.0), 1.0);
  surge_applied := LEAST(area_surge_raw, GREATEST(surge_cap, 1.0));

  total_iqd := CEIL(subtotal_iqd * product_mult * surge_applied)::integer;

  RETURN jsonb_build_object(
    'currency', 'IQD',
    'service_area_id', area_id,
    'product_code', _product_code,
    'distance_km', dist_km,
    'base_fare_iqd', base_fare_iqd,
    'distance_fare_iqd', distance_fare_iqd,
    'minimum_fare_iqd', minimum_fare_iqd,
    'subtotal_iqd', subtotal_iqd,
    'product_multiplier', product_mult,
    'surge_multiplier_raw', area_surge_raw,
    'max_surge_multiplier', surge_cap,
    'surge_multiplier_applied', surge_applied,
    'surge_reason', area_surge_reason,
    'total_iqd', total_iqd
  );
END;
$$;

-- RPC wrapper that accepts plain lat/lng from the frontend.
CREATE OR REPLACE FUNCTION public.quote_breakdown_iqd(
  p_pickup_lat double precision,
  p_pickup_lng double precision,
  p_dropoff_lat double precision,
  p_dropoff_lng double precision,
  p_product_code text DEFAULT 'standard'
) RETURNS jsonb
LANGUAGE sql STABLE
SET search_path TO 'pg_catalog, extensions'
AS $$
  SELECT public.estimate_ride_quote_breakdown_iqd_v1(
    (extensions.st_setsrid(extensions.st_makepoint(p_pickup_lng, p_pickup_lat), 4326))::extensions.geography,
    (extensions.st_setsrid(extensions.st_makepoint(p_dropoff_lng, p_dropoff_lat), 4326))::extensions.geography,
    p_product_code
  );
$$;

-- =========================
-- 3) Backward-compatible integer quote functions now use breakdown
-- =========================

CREATE OR REPLACE FUNCTION public.estimate_ride_quote_iqd(
  _pickup extensions.geography,
  _dropoff extensions.geography
) RETURNS integer
LANGUAGE plpgsql STABLE
SET search_path TO 'pg_catalog, extensions'
AS $$
DECLARE
  b jsonb;
BEGIN
  b := public.estimate_ride_quote_breakdown_iqd_v1(_pickup, _dropoff, 'standard');
  RETURN COALESCE((b->>'total_iqd')::int, 0);
END;
$$;

CREATE OR REPLACE FUNCTION public.estimate_ride_quote_iqd_v2(
  _pickup extensions.geography,
  _dropoff extensions.geography,
  _product_code text DEFAULT 'standard'
) RETURNS integer
LANGUAGE plpgsql STABLE
SET search_path TO 'pg_catalog, extensions'
AS $$
DECLARE
  b jsonb;
BEGIN
  b := public.estimate_ride_quote_breakdown_iqd_v1(_pickup, _dropoff, _product_code);
  RETURN COALESCE((b->>'total_iqd')::int, 0);
END;
$$;

-- =========================
-- 4) Ensure ride_requests.quote_amount_iqd uses product_code
-- =========================

CREATE OR REPLACE FUNCTION public.ride_requests_set_quote() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog, extensions'
AS $$
DECLARE
  cfg record;
  v_product text;
BEGIN
  SELECT currency
    INTO cfg
  FROM public.pricing_configs
  WHERE active = true
  ORDER BY created_at DESC
  LIMIT 1;

  IF NEW.currency IS NULL THEN
    NEW.currency := COALESCE(cfg.currency, 'IQD');
  END IF;

  v_product := COALESCE(NEW.product_code, 'standard');

  IF NEW.quote_amount_iqd IS NULL THEN
    NEW.quote_amount_iqd := public.estimate_ride_quote_iqd_v2(NEW.pickup_loc, NEW.dropoff_loc, v_product);
  END IF;

  RETURN NEW;
END;
$$;

-- =========================
-- 5) Admin helper RPC for pricing caps (pricing_configs is not writable by admin in RLS)
-- =========================

CREATE OR REPLACE FUNCTION public.admin_update_pricing_config_caps(
  p_id uuid,
  p_max_surge_multiplier numeric
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not authorized' USING ERRCODE = '42501';
  END IF;

  UPDATE public.pricing_configs
  SET max_surge_multiplier = GREATEST(COALESCE(p_max_surge_multiplier, 1.0), 1.0),
      updated_at = now()
  WHERE id = p_id;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_update_pricing_config_caps(uuid, numeric) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_update_pricing_config_caps(uuid, numeric) TO authenticated;

-- =========================
-- 6) Admin helper RPC v2 for service areas (optional extra fields)
-- =========================

CREATE OR REPLACE FUNCTION public.admin_create_service_area_bbox_v2(
  p_name text,
  p_governorate text,
  p_min_lat double precision,
  p_min_lng double precision,
  p_max_lat double precision,
  p_max_lng double precision,
  p_priority integer DEFAULT 0,
  p_is_active boolean DEFAULT true,
  p_pricing_config_id uuid DEFAULT NULL,
  p_notes text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id uuid;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not authorized' USING ERRCODE = '42501';
  END IF;

  INSERT INTO public.service_areas (
    name, governorate, is_active, priority, pricing_config_id, min_base_fare_iqd, surge_multiplier, surge_reason, geom
  )
  VALUES (
    p_name,
    p_governorate,
    COALESCE(p_is_active, true),
    COALESCE(p_priority, 0),
    p_pricing_config_id,
    p_min_base_fare_iqd,
    GREATEST(COALESCE(p_surge_multiplier, 1.0), 1.0),
    p_surge_reason,
    ST_Multi(ST_MakeEnvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326))
  )
  ON CONFLICT (name, governorate) DO UPDATE
    SET is_active = EXCLUDED.is_active,
        priority = EXCLUDED.priority,
        pricing_config_id = EXCLUDED.pricing_config_id,
        min_base_fare_iqd = EXCLUDED.min_base_fare_iqd,
        surge_multiplier = EXCLUDED.surge_multiplier,
        surge_reason = EXCLUDED.surge_reason,
        geom = EXCLUDED.geom,
        updated_at = now()
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_create_service_area_bbox_v2(
  text, text, double precision, double precision, double precision, double precision, integer, boolean, uuid, text
) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_create_service_area_bbox_v2(
  text, text, double precision, double precision, double precision, double precision, integer, boolean, uuid, text
) TO authenticated;

-- Session 4: Scheduled rides runner hardening (pg_cron compatibility + admin query index)
-- Goals:
-- - Ensure pg_cron is enabled when possible.
-- - Schedule the runner idempotently across pg_cron versions (with/without jobname support).
-- - Add an index useful for admin monitoring (status, scheduled_at).
--
-- References:
-- - Supabase Cron / pg_cron: https://supabase.com/docs/guides/database/extensions/pg_cron
-- - Supabase Cron module: https://supabase.com/docs/guides/cron

-- Helpful for admin monitoring queries
CREATE INDEX IF NOT EXISTS idx_scheduled_rides_status_time ON public.scheduled_rides (status, scheduled_at DESC);
