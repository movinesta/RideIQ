-- RideIQ Squashed Migrations: 02_support_safety_ridecheck.sql
-- Generated: 2026-01-25T21:51:19.003277Z
-- Notes:
-- - This squashed set EXCLUDES 20260124_000001_init.sql (already applied).
-- - Source migrations merged here: 20260124_000002_support_and_sos.sql, 20260125_000016_safety_settings_and_audit.sql, 20260125_000017_pickup_pin_verification.sql, 20260125_000018_ridecheck.sql (without cron schedule), 20260125_000020_ridecheck_admin_rpcs.sql
-- - Run files in order: 01 -> 02 -> 03 -> 04 -> 05

-- RideIQ Session 1 patch: add missing relations/RPCs referenced by edge functions.
-- Keep this migration minimal and focused.

-- =========================
-- 1) SOS events (Safety)
-- =========================

CREATE TABLE IF NOT EXISTS public.sos_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  ride_id uuid REFERENCES public.rides(id) ON DELETE SET NULL,
  lat double precision,
  lng double precision,
  status text NOT NULL DEFAULT 'triggered',
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  resolved_at timestamp with time zone
);

ALTER TABLE public.sos_events ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS ix_sos_events_user_created ON public.sos_events (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_sos_events_ride_created ON public.sos_events (ride_id, created_at DESC);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'sos_events'
  ) THEN
    CREATE POLICY sos_events_select_own ON public.sos_events
      FOR SELECT TO authenticated
      USING (user_id = (SELECT auth.uid()) OR (SELECT public.is_admin()));

    CREATE POLICY sos_events_insert_own ON public.sos_events
      FOR INSERT TO authenticated
      WITH CHECK (user_id = (SELECT auth.uid()) OR (SELECT public.is_admin()));

    CREATE POLICY sos_events_update_admin ON public.sos_events
      FOR UPDATE TO authenticated
      USING ((SELECT public.is_admin()))
      WITH CHECK ((SELECT public.is_admin()));

    CREATE POLICY sos_events_delete_admin ON public.sos_events
      FOR DELETE TO authenticated
      USING ((SELECT public.is_admin()));
  END IF;
END$$;

GRANT ALL ON TABLE public.sos_events TO authenticated;
GRANT ALL ON TABLE public.sos_events TO service_role;

-- =========================
-- 2) Support Help Center (Public read)
-- =========================

CREATE TABLE IF NOT EXISTS public.support_sections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  key text NOT NULL UNIQUE,
  title text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  enabled boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.support_articles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id uuid REFERENCES public.support_sections(id) ON DELETE SET NULL,
  slug text NOT NULL UNIQUE,
  title text NOT NULL,
  summary text,
  body_md text NOT NULL DEFAULT '',
  tags text[] NOT NULL DEFAULT ARRAY[]::text[],
  enabled boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now()
);

ALTER TABLE public.support_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_articles ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS ix_support_sections_sort ON public.support_sections (enabled, sort_order, key);
CREATE INDEX IF NOT EXISTS ix_support_articles_enabled_updated ON public.support_articles (enabled, updated_at DESC);
CREATE INDEX IF NOT EXISTS ix_support_articles_section ON public.support_articles (section_id, enabled, updated_at DESC);

-- updated_at triggers (reuse existing public.set_updated_at())
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'support_sections_set_updated_at'
  ) THEN
    CREATE TRIGGER support_sections_set_updated_at
      BEFORE UPDATE ON public.support_sections
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'support_articles_set_updated_at'
  ) THEN
    CREATE TRIGGER support_articles_set_updated_at
      BEFORE UPDATE ON public.support_articles
      FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
  END IF;
END$$;

-- RLS policies (create only once)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'support_sections'
  ) THEN
    -- public read of enabled content
    CREATE POLICY support_sections_select_public ON public.support_sections
      FOR SELECT TO anon, authenticated
      USING (enabled = true);

    -- admin write
    CREATE POLICY support_sections_admin_write ON public.support_sections
      FOR ALL TO authenticated
      USING ((SELECT public.is_admin()))
      WITH CHECK ((SELECT public.is_admin()));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'support_articles'
  ) THEN
    CREATE POLICY support_articles_select_public ON public.support_articles
      FOR SELECT TO anon, authenticated
      USING (enabled = true);

    CREATE POLICY support_articles_admin_write ON public.support_articles
      FOR ALL TO authenticated
      USING ((SELECT public.is_admin()))
      WITH CHECK ((SELECT public.is_admin()));
  END IF;
END$$;

GRANT ALL ON TABLE public.support_sections TO anon, authenticated, service_role;
GRANT ALL ON TABLE public.support_articles TO anon, authenticated, service_role;

-- =========================
-- 3) Bulk notification RPC (service-role only)
-- =========================

CREATE OR REPLACE FUNCTION public.notify_users_bulk(
  p_user_ids uuid[],
  p_kind text,
  p_title text,
  p_body text DEFAULT NULL,
  p_data jsonb DEFAULT '{}'::jsonb
) RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count integer;
BEGIN
  INSERT INTO public.user_notifications (user_id, kind, title, body, data)
  SELECT u, p_kind, p_title, p_body, COALESCE(p_data, '{}'::jsonb)
  FROM unnest(p_user_ids) AS u
  WHERE u IS NOT NULL;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

REVOKE ALL ON FUNCTION public.notify_users_bulk(uuid[], text, text, text, jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.notify_users_bulk(uuid[], text, text, text, jsonb) TO service_role;

-- Session 15: Safety settings + trusted contacts audit log
-- Minimal additive migration.

begin;

-- 1) Per-user safety preferences.
create table if not exists public.user_safety_settings (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  auto_share_on_trip_start boolean not null default false,
  auto_notify_on_sos boolean not null default true,
  default_share_ttl_minutes integer not null default 120,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint user_safety_settings_ttl_ck check (default_share_ttl_minutes between 5 and 1440)
);

alter table public.user_safety_settings enable row level security;

-- Avoid auth RLS initplan warnings.
create policy user_safety_settings_select_own_or_admin
  on public.user_safety_settings
  for select
  to authenticated
  using ((user_id = (select auth.uid())) or (select public.is_admin()));

create policy user_safety_settings_insert_own
  on public.user_safety_settings
  for insert
  to authenticated
  with check (user_id = (select auth.uid()));

create policy user_safety_settings_update_own_or_admin
  on public.user_safety_settings
  for update
  to authenticated
  using ((user_id = (select auth.uid())) or (select public.is_admin()))
  with check ((user_id = (select auth.uid())) or (select public.is_admin()));

drop trigger if exists trg_user_safety_settings_updated_at on public.user_safety_settings;
create trigger trg_user_safety_settings_updated_at
before update on public.user_safety_settings
for each row execute function public.set_updated_at();

grant select, insert, update on table public.user_safety_settings to authenticated;
grant all on table public.user_safety_settings to service_role;

-- 2) Trusted contact events audit log.
create table if not exists public.trusted_contact_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  contact_id uuid references public.trusted_contacts(id) on delete set null,
  ride_id uuid references public.rides(id) on delete set null,
  event_type text not null,
  status text not null default 'ok',
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists ix_trusted_contact_events_user_id_created_at
  on public.trusted_contact_events (user_id, created_at desc);

create index if not exists ix_trusted_contact_events_ride_id_created_at
  on public.trusted_contact_events (ride_id, created_at desc);

alter table public.trusted_contact_events enable row level security;

create policy trusted_contact_events_select_own_or_admin
  on public.trusted_contact_events
  for select
  to authenticated
  using ((user_id = (select auth.uid())) or (select public.is_admin()));

-- Intentionally do NOT add insert/update/delete policies for authenticated users.
-- Edge functions will write via service_role.

grant select on table public.trusted_contact_events to authenticated;
grant all on table public.trusted_contact_events to service_role;

-- 3) Enforce max active trusted contacts per user (5).
create or replace function public.trusted_contacts_enforce_active_limit()
returns trigger
language plpgsql
as $$
declare
  cnt integer;
begin
  if new.is_active is true then
    select count(*) into cnt
    from public.trusted_contacts tc
    where tc.user_id = new.user_id
      and tc.is_active is true
      and (tg_op <> 'UPDATE' or tc.id <> new.id);

    if cnt >= 5 then
      raise exception 'max_active_trusted_contacts' using errcode = 'P0001';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_trusted_contacts_active_limit on public.trusted_contacts;
create trigger trg_trusted_contacts_active_limit
before insert or update of is_active, user_id on public.trusted_contacts
for each row execute function public.trusted_contacts_enforce_active_limit();

commit;

-- Session 15: Safety settings (per-user preferences)
-- (Squashed) Ensure base table exists before later ALTERs (e.g., pickup PIN mode).

CREATE TABLE IF NOT EXISTS public.user_safety_settings (
  user_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  auto_share_on_trip_start boolean NOT NULL DEFAULT false,
  auto_notify_on_sos boolean NOT NULL DEFAULT true,
  default_share_ttl_minutes integer NOT NULL DEFAULT 120,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT user_safety_settings_ttl_ck CHECK (default_share_ttl_minutes BETWEEN 5 AND 1440)
);

ALTER TABLE public.user_safety_settings ENABLE ROW LEVEL SECURITY;

-- Avoid auth RLS initplan warnings (wrap auth.uid() in a subquery)
DROP POLICY IF EXISTS user_safety_settings_select_own_or_admin ON public.user_safety_settings;
CREATE POLICY user_safety_settings_select_own_or_admin
  ON public.user_safety_settings
  FOR SELECT
  TO authenticated
  USING ((user_id = (SELECT auth.uid())) OR (SELECT public.is_admin()));

DROP POLICY IF EXISTS user_safety_settings_insert_own ON public.user_safety_settings;
CREATE POLICY user_safety_settings_insert_own
  ON public.user_safety_settings
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS user_safety_settings_update_own_or_admin ON public.user_safety_settings;
CREATE POLICY user_safety_settings_update_own_or_admin
  ON public.user_safety_settings
  FOR UPDATE
  TO authenticated
  USING ((user_id = (SELECT auth.uid())) OR (SELECT public.is_admin()))
  WITH CHECK ((user_id = (SELECT auth.uid())) OR (SELECT public.is_admin()));

DROP TRIGGER IF EXISTS trg_user_safety_settings_updated_at ON public.user_safety_settings;
CREATE TRIGGER trg_user_safety_settings_updated_at
BEFORE UPDATE ON public.user_safety_settings
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

GRANT SELECT, INSERT, UPDATE ON TABLE public.user_safety_settings TO authenticated;
GRANT ALL ON TABLE public.user_safety_settings TO service_role;

-- Session 16: Pickup PIN verification (Verify My Ride)
-- Minimal, secure schema updates + DB enforcement.

-- 1) Rider safety setting: pin verification mode
ALTER TABLE public.user_safety_settings
  ADD COLUMN IF NOT EXISTS pin_verification_mode text NOT NULL DEFAULT 'off';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'user_safety_settings_pin_verification_mode_check'
  ) THEN
    EXECUTE $cmd$
      ALTER TABLE public.user_safety_settings
      ADD CONSTRAINT user_safety_settings_pin_verification_mode_check
      CHECK (pin_verification_mode IN ('off','every_ride','night_only'))
    $cmd$;
  END IF;
END $$;

-- 2) Driver toggle: require pickup PIN
ALTER TABLE public.drivers
  ADD COLUMN IF NOT EXISTS require_pickup_pin boolean NOT NULL DEFAULT false;

-- 3) Ride-level PIN gating + lockout metadata
ALTER TABLE public.rides
  ADD COLUMN IF NOT EXISTS pickup_pin_required boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS pickup_pin_verified_at timestamptz,
  ADD COLUMN IF NOT EXISTS pickup_pin_fail_count integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS pickup_pin_locked_until timestamptz,
  ADD COLUMN IF NOT EXISTS pickup_pin_last_attempt_at timestamptz;

CREATE INDEX IF NOT EXISTS ix_rides_pickup_pin_required_status
  ON public.rides (pickup_pin_required, status);

-- 4) Helper: should this ride require a PIN?
-- Baghdad "night" window: 21:00–06:00 local.
CREATE OR REPLACE FUNCTION public.is_pickup_pin_required_v1(p_rider_id uuid, p_driver_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
AS $$
  WITH s AS (
    SELECT
      COALESCE((SELECT require_pickup_pin FROM public.drivers WHERE id = p_driver_id), false) AS driver_requires,
      COALESCE((SELECT pin_verification_mode FROM public.user_safety_settings WHERE user_id = p_rider_id), 'off') AS rider_mode
  ), t AS (
    SELECT EXTRACT(HOUR FROM timezone('Asia/Baghdad', now()))::int AS baghdad_hour
  )
  SELECT
    (SELECT driver_requires FROM s)
    OR
    CASE (SELECT rider_mode FROM s)
      WHEN 'every_ride' THEN true
      WHEN 'night_only' THEN ((SELECT baghdad_hour FROM t) >= 21 OR (SELECT baghdad_hour FROM t) < 6)
      ELSE false
    END;
$$;

-- 5) Enforce PIN gating at the source of truth (DB): trip cannot start until PIN verified.
CREATE OR REPLACE FUNCTION public.transition_ride_v2(
  p_ride_id uuid,
  p_to_status public.ride_status,
  p_actor_id uuid,
  p_actor_type public.ride_actor_type,
  p_expected_version integer
) RETURNS public.rides
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, extensions'
AS $$
DECLARE
  r public.rides;
  v_from public.ride_status;
BEGIN
  SELECT * INTO r FROM public.rides WHERE id = p_ride_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'ride_not_found';
  END IF;

  IF r.version <> p_expected_version THEN
    RAISE EXCEPTION 'version_mismatch';
  END IF;

  v_from := r.status;

  -- Allowed transitions
  IF NOT (
    (v_from = 'assigned' AND p_to_status IN ('arrived','canceled')) OR
    (v_from = 'arrived' AND p_to_status IN ('in_progress','canceled')) OR
    (v_from = 'in_progress' AND p_to_status IN ('completed','canceled'))
  ) THEN
    RAISE EXCEPTION 'invalid_transition';
  END IF;

  -- PIN gate: prevent starting ride until verified when required.
  IF p_to_status = 'in_progress' THEN
    IF COALESCE(r.pickup_pin_required, false) AND r.pickup_pin_verified_at IS NULL THEN
      RAISE EXCEPTION 'pickup_pin_required';
    END IF;
  END IF;

  UPDATE public.rides
    SET status = p_to_status,
        version = version + 1,
        started_at = CASE WHEN p_to_status = 'in_progress' THEN COALESCE(started_at, now()) ELSE started_at END,
        completed_at = CASE WHEN p_to_status = 'completed' THEN COALESCE(completed_at, now()) ELSE completed_at END
  WHERE id = r.id
  RETURNING * INTO r;

  INSERT INTO public.ride_events (ride_id, actor_id, actor_type, event_type, payload)
  VALUES (r.id, p_actor_id, p_actor_type, 'ride_status_changed',
          jsonb_build_object('from', v_from, 'to', p_to_status));

  IF p_to_status IN ('completed','canceled') THEN
    UPDATE public.drivers
      SET status = 'available'
    WHERE id = r.driver_id;
  END IF;

  IF p_to_status = 'completed' THEN
    PERFORM public.wallet_capture_ride_hold(r.id);
    PERFORM public.on_ride_completed_v1(r.id);
  ELSIF p_to_status = 'canceled' THEN
    PERFORM public.wallet_release_ride_hold(r.id);
  END IF;

  RETURN r;
END;
$$;

-- 6) Ensure ride creation sets pickup_pin_required consistently.
CREATE OR REPLACE FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid)
RETURNS TABLE(
  ride_id uuid,
  ride_status public.ride_status,
  request_status public.ride_request_status,
  wallet_hold_id uuid,
  rider_id uuid,
  driver_id uuid,
  started_at timestamptz,
  completed_at timestamptz,
  fare_amount_iqd integer,
  currency text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, extensions'
AS $$
#variable_conflict use_column
DECLARE
  rr record;
  r record;
  v_hold_id uuid;
  v_quote bigint;
  v_pin_required boolean;
BEGIN
  SELECT * INTO rr
  FROM public.ride_requests req
  WHERE req.id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'ride_request_not_found';
  END IF;

  IF rr.assigned_driver_id IS DISTINCT FROM p_driver_id THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  IF rr.status <> 'matched' THEN
    RAISE EXCEPTION 'request_not_matched';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.drivers d WHERE d.id = p_driver_id AND d.status = 'reserved') THEN
    RAISE EXCEPTION 'driver_not_reserved';
  END IF;

  v_quote := COALESCE(rr.quote_amount_iqd, 0)::bigint;
  IF v_quote <= 0 THEN
    v_quote := public.estimate_ride_quote_iqd_v2(rr.pickup_loc, rr.dropoff_loc, rr.product_code)::bigint;
    IF v_quote <= 0 THEN
      RAISE EXCEPTION 'invalid_quote';
    END IF;
  END IF;

  UPDATE public.ride_requests
    SET status = 'accepted',
        quote_amount_iqd = v_quote::int
  WHERE id = rr.id AND status = 'matched';

  v_pin_required := public.is_pickup_pin_required_v1(rr.rider_id, p_driver_id);

  INSERT INTO public.rides (
    request_id, rider_id, driver_id, status, version,
    started_at, completed_at, fare_amount_iqd, currency, product_code,
    pickup_pin_required, pickup_pin_verified_at, pickup_pin_fail_count, pickup_pin_locked_until, pickup_pin_last_attempt_at
  )
  VALUES (
    rr.id, rr.rider_id, p_driver_id, 'assigned', 0,
    NULL, NULL, v_quote::int, rr.currency, rr.product_code,
    v_pin_required, NULL, 0, NULL, NULL
  )
  ON CONFLICT (request_id) DO UPDATE
    SET driver_id = EXCLUDED.driver_id,
        fare_amount_iqd = EXCLUDED.fare_amount_iqd,
        currency = EXCLUDED.currency,
        product_code = EXCLUDED.product_code,
        pickup_pin_required = public.is_pickup_pin_required_v1(rr.rider_id, EXCLUDED.driver_id),
        pickup_pin_verified_at = NULL,
        pickup_pin_fail_count = 0,
        pickup_pin_locked_until = NULL,
        pickup_pin_last_attempt_at = NULL
  RETURNING * INTO r;

  v_hold_id := public.wallet_hold_upsert_for_ride(r.rider_id, r.id, r.fare_amount_iqd::bigint);

  UPDATE public.drivers
    SET status = 'on_trip'
  WHERE id = p_driver_id;

  RETURN QUERY
    SELECT r.id, r.status, 'accepted'::public.ride_request_status, v_hold_id, r.rider_id, r.driver_id, r.started_at, r.completed_at, r.fare_amount_iqd, r.currency;
END;
$$;

-- 7) Security hardening: prevent clients from tampering with ride state.
DROP POLICY IF EXISTS rls_update ON public.rides;
REVOKE UPDATE ON TABLE public.rides FROM authenticated;

-- Session 17: RideCheck (safety prompts) — DB schema + cron runner
-- Detect anomalies during in-progress rides and open a RideCheck event for rider/driver.

-- 1) State table (per ride)
CREATE TABLE IF NOT EXISTS public.ridecheck_state (
  ride_id uuid PRIMARY KEY REFERENCES public.rides(id) ON DELETE CASCADE,
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  last_loc extensions.geography(Point,4326),
  last_distance_to_dropoff_m double precision,
  distance_increase_streak integer NOT NULL DEFAULT 0,
  last_move_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 2) Events & responses
CREATE TABLE IF NOT EXISTS public.ridecheck_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ride_id uuid NOT NULL REFERENCES public.rides(id) ON DELETE CASCADE,
  kind text NOT NULL,
  status text NOT NULL DEFAULT 'open',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb
);

ALTER TABLE public.ridecheck_events
  DROP CONSTRAINT IF EXISTS ridecheck_events_status_check,
  ADD CONSTRAINT ridecheck_events_status_check CHECK (status IN ('open','resolved','escalated'));

CREATE INDEX IF NOT EXISTS ix_ridecheck_events_ride_status_time
  ON public.ridecheck_events (ride_id, status, created_at DESC);

-- Ensure only one open event per kind per ride
CREATE UNIQUE INDEX IF NOT EXISTS ux_ridecheck_events_open_kind
  ON public.ridecheck_events (ride_id, kind) WHERE status = 'open';

CREATE TABLE IF NOT EXISTS public.ridecheck_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL REFERENCES public.ridecheck_events(id) ON DELETE CASCADE,
  ride_id uuid NOT NULL REFERENCES public.rides(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role text NOT NULL,
  response text NOT NULL,
  note text,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.ridecheck_responses
  DROP CONSTRAINT IF EXISTS ridecheck_responses_role_check,
  DROP CONSTRAINT IF EXISTS ridecheck_responses_response_check,
  ADD CONSTRAINT ridecheck_responses_role_check CHECK (role IN ('rider','driver')),
  ADD CONSTRAINT ridecheck_responses_response_check CHECK (response IN ('ok','false_alarm','need_help'));
CREATE INDEX IF NOT EXISTS ix_ridecheck_responses_event_created
  ON public.ridecheck_responses (event_id, created_at DESC);

-- Replica identity helps Realtime deliver UPDATE payloads reliably.
ALTER TABLE public.ridecheck_events REPLICA IDENTITY FULL;
ALTER TABLE public.ridecheck_responses REPLICA IDENTITY FULL;

-- 3) RLS
ALTER TABLE public.ridecheck_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ridecheck_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ridecheck_responses ENABLE ROW LEVEL SECURITY;

-- Service role: full access (no RLS blocks)
DROP POLICY IF EXISTS rls_service_role_all ON public.ridecheck_events;
CREATE POLICY rls_service_role_all ON public.ridecheck_events
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS rls_service_role_all ON public.ridecheck_responses;
CREATE POLICY rls_service_role_all ON public.ridecheck_responses
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS rls_service_role_all ON public.ridecheck_state;
CREATE POLICY rls_service_role_all ON public.ridecheck_state
  FOR ALL TO service_role
  USING (true) WITH CHECK (true);

-- Participants can read
DROP POLICY IF EXISTS ridecheck_events_select_participants ON public.ridecheck_events;
CREATE POLICY ridecheck_events_select_participants ON public.ridecheck_events
  FOR SELECT TO authenticated
  USING (
    (SELECT public.is_admin())
    OR EXISTS (
      SELECT 1
      FROM public.rides r
      WHERE r.id = ride_id
        AND (r.rider_id = (SELECT auth.uid()) OR r.driver_id = (SELECT auth.uid()))
    )
  );

DROP POLICY IF EXISTS ridecheck_responses_select_participants ON public.ridecheck_responses;
CREATE POLICY ridecheck_responses_select_participants ON public.ridecheck_responses
  FOR SELECT TO authenticated
  USING (
    (SELECT public.is_admin())
    OR EXISTS (
      SELECT 1
      FROM public.rides r
      WHERE r.id = ride_id
        AND (r.rider_id = (SELECT auth.uid()) OR r.driver_id = (SELECT auth.uid()))
    )
  );

-- No direct client writes (use Edge Functions)
REVOKE ALL ON TABLE public.ridecheck_state FROM authenticated;
REVOKE ALL ON TABLE public.ridecheck_events FROM authenticated;
REVOKE ALL ON TABLE public.ridecheck_responses FROM authenticated;

GRANT SELECT ON TABLE public.ridecheck_events TO authenticated;
GRANT SELECT ON TABLE public.ridecheck_responses TO authenticated;

-- Service role needs privileges
GRANT ALL ON TABLE public.ridecheck_state TO service_role;
GRANT ALL ON TABLE public.ridecheck_events TO service_role;
GRANT ALL ON TABLE public.ridecheck_responses TO service_role;

-- 4) Helper to upsert/open events idempotently
CREATE OR REPLACE FUNCTION public.ridecheck_open_event_v1(p_ride_id uuid, p_kind text, p_metadata jsonb)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public, extensions'
AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.ridecheck_events (ride_id, kind, status, metadata, created_at, updated_at)
  VALUES (p_ride_id, p_kind, 'open', COALESCE(p_metadata,'{}'::jsonb), now(), now())
  ON CONFLICT (ride_id, kind) WHERE status = 'open'
  DO UPDATE SET
    updated_at = EXCLUDED.updated_at,
    metadata = public.ridecheck_events.metadata || EXCLUDED.metadata
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

-- 5) Cron runner: detect anomalies for in-progress rides
CREATE OR REPLACE FUNCTION public.ridecheck_run_v1()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public, extensions'
AS $$
DECLARE
  v_now timestamptz := now();
  rec record;
  st record;
  v_dist double precision;
  v_last_dist double precision;
  v_new_streak integer;
  v_moved_m double precision;
  v_last_move timestamptz;
  v_stale boolean;
BEGIN
  FOR rec IN
    SELECT
      r.id AS ride_id,
      r.driver_id,
      r.rider_id,
      rr.dropoff_loc,
      dl.loc AS driver_loc,
      dl.updated_at AS loc_updated_at
    FROM public.rides r
    JOIN public.ride_requests rr ON rr.id = r.request_id
    LEFT JOIN public.driver_locations dl ON dl.driver_id = r.driver_id
    WHERE r.status = 'in_progress'
  LOOP
    v_stale := (rec.loc_updated_at IS NULL) OR (rec.loc_updated_at < v_now - interval '2 minutes');

    IF v_stale THEN
      PERFORM public.ridecheck_open_event_v1(
        rec.ride_id,
        'gps_stale',
        jsonb_build_object('loc_updated_at', rec.loc_updated_at)
      );
      CONTINUE;
    END IF;

    -- Auto-resolve a prior gps_stale once we see fresh updates again
    UPDATE public.ridecheck_events
      SET status = 'resolved',
          resolved_at = COALESCE(resolved_at, v_now),
          updated_at = v_now,
          metadata = metadata || jsonb_build_object('auto_resolved', true, 'reason', 'gps_fresh')
    WHERE ride_id = rec.ride_id AND kind = 'gps_stale' AND status = 'open';

    v_dist := extensions.st_distance(rec.driver_loc, rec.dropoff_loc);

    SELECT * INTO st FROM public.ridecheck_state WHERE ride_id = rec.ride_id;

    IF NOT FOUND THEN
      INSERT INTO public.ridecheck_state (ride_id, last_seen_at, last_loc, last_distance_to_dropoff_m, distance_increase_streak, last_move_at, updated_at)
      VALUES (rec.ride_id, v_now, rec.driver_loc, v_dist, 0, v_now, v_now)
      ON CONFLICT (ride_id) DO NOTHING;
      CONTINUE;
    END IF;

    v_moved_m := CASE WHEN st.last_loc IS NULL THEN NULL ELSE extensions.st_distance(rec.driver_loc, st.last_loc) END;
    v_last_move := COALESCE(st.last_move_at, v_now);
    IF v_moved_m IS NULL OR v_moved_m > 30 THEN
      v_last_move := v_now;
    END IF;

    -- Long stop: no movement (>30m) for 3+ minutes
    IF v_now - v_last_move > interval '3 minutes' THEN
      PERFORM public.ridecheck_open_event_v1(
        rec.ride_id,
        'long_stop',
        jsonb_build_object('stopped_since', v_last_move, 'moved_m', COALESCE(v_moved_m, 0))
      );
    END IF;

    v_last_dist := st.last_distance_to_dropoff_m;
    IF v_last_dist IS NOT NULL AND v_dist > v_last_dist + 300 THEN
      v_new_streak := COALESCE(st.distance_increase_streak, 0) + 1;
    ELSE
      v_new_streak := 0;
    END IF;

    -- Route deviation: distance to dropoff increases twice consecutively
    IF v_new_streak >= 2 THEN
      PERFORM public.ridecheck_open_event_v1(
        rec.ride_id,
        'route_deviation',
        jsonb_build_object('distance_m', v_dist, 'prev_distance_m', v_last_dist, 'streak', v_new_streak)
      );
    END IF;

    UPDATE public.ridecheck_state
      SET last_seen_at = v_now,
          last_loc = rec.driver_loc,
          last_distance_to_dropoff_m = v_dist,
          distance_increase_streak = v_new_streak,
          last_move_at = v_last_move,
          updated_at = v_now
    WHERE ride_id = rec.ride_id;

  END LOOP;
END;
$$;

-- RideIQ Session 19
-- Admin RideCheck management RPCs

BEGIN;

CREATE OR REPLACE FUNCTION public.admin_ridecheck_resolve(p_event_id uuid, p_note text DEFAULT NULL)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
BEGIN
  IF NOT public.is_admin(auth.uid()) THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  UPDATE public.ridecheck_events
    SET status = 'resolved',
        resolved_at = now(),
        updated_at = now(),
        metadata = metadata || jsonb_build_object('admin_note', left(coalesce(p_note,''), 800), 'resolved_by', auth.uid(), 'resolved_at', now())
  WHERE id = p_event_id;

  RETURN FOUND;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_ridecheck_resolve(p_event_id uuid, p_note text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_ridecheck_resolve(p_event_id uuid, p_note text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_ridecheck_resolve(p_event_id uuid, p_note text) TO service_role;

CREATE OR REPLACE FUNCTION public.admin_ridecheck_escalate(p_event_id uuid, p_note text DEFAULT NULL)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_ride_id uuid;
  v_incident_id uuid;
BEGIN
  IF NOT public.is_admin(auth.uid()) THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  SELECT ride_id INTO v_ride_id FROM public.ridecheck_events WHERE id = p_event_id;
  IF v_ride_id IS NULL THEN
    RAISE EXCEPTION 'not_found';
  END IF;

  UPDATE public.ridecheck_events
    SET status = 'escalated',
        updated_at = now(),
        metadata = metadata || jsonb_build_object('admin_note', left(coalesce(p_note,''), 800), 'escalated_by', auth.uid(), 'escalated_at', now())
  WHERE id = p_event_id;

  INSERT INTO public.ride_incidents (ride_id, reporter_id, reporter_type, category, severity, status, description, metadata)
  VALUES (
    v_ride_id,
    auth.uid(),
    'admin',
    'ridecheck',
    'high',
    'open',
    COALESCE(NULLIF(left(p_note, 800), ''), 'RideCheck event escalated by admin.'),
    jsonb_build_object('ridecheck_event_id', p_event_id)
  )
  RETURNING id INTO v_incident_id;

  RETURN v_incident_id;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_ridecheck_escalate(p_event_id uuid, p_note text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_ridecheck_escalate(p_event_id uuid, p_note text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_ridecheck_escalate(p_event_id uuid, p_note text) TO service_role;

COMMIT;