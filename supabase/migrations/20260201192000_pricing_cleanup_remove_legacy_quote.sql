-- Pricing cleanup: remove legacy SQL-only fare estimation and require auditable fare_quotes linkage.

-- 1) Link ride_requests and scheduled_rides to fare_quotes
ALTER TABLE IF EXISTS public.ride_requests
  ADD COLUMN IF NOT EXISTS fare_quote_id uuid;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'ride_requests_fare_quote_fk'
      AND conrelid = 'public.ride_requests'::regclass
  ) THEN
    ALTER TABLE public.ride_requests
      ADD CONSTRAINT ride_requests_fare_quote_fk
      FOREIGN KEY (fare_quote_id)
      REFERENCES public.fare_quotes(id)
      ON DELETE SET NULL;
  END IF;
END $$;

ALTER TABLE IF EXISTS public.scheduled_rides
  ADD COLUMN IF NOT EXISTS fare_quote_id uuid,
  ADD COLUMN IF NOT EXISTS quote_amount_iqd integer,
  ADD COLUMN IF NOT EXISTS currency text DEFAULT 'IQD' NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'scheduled_rides_fare_quote_fk'
      AND conrelid = 'public.scheduled_rides'::regclass
  ) THEN
    ALTER TABLE public.scheduled_rides
      ADD CONSTRAINT scheduled_rides_fare_quote_fk
      FOREIGN KEY (fare_quote_id)
      REFERENCES public.fare_quotes(id)
      ON DELETE SET NULL;
  END IF;
END $$;

-- 2) Ensure ride requests always have a valid quote amount derived from fare_quotes.
CREATE OR REPLACE FUNCTION public.ride_requests_set_quote() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public, extensions'
AS $$
DECLARE
  cfg record;
  v_product text;
  v_total integer;
  v_rider uuid;
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
  NEW.product_code := v_product;

  IF NEW.fare_quote_id IS NOT NULL THEN
    SELECT fq.total_iqd, fq.rider_id
      INTO v_total, v_rider
    FROM public.fare_quotes fq
    WHERE fq.id = NEW.fare_quote_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'fare_quote_not_found';
    END IF;

    -- Prevent cross-user quote reuse.
    IF v_rider IS DISTINCT FROM NEW.rider_id THEN
      RAISE EXCEPTION 'fare_quote_rider_mismatch';
    END IF;

    NEW.quote_amount_iqd := COALESCE(v_total, 0);
  END IF;

  IF NEW.quote_amount_iqd IS NULL OR NEW.quote_amount_iqd <= 0 THEN
    RAISE EXCEPTION 'missing_or_invalid_quote';
  END IF;

  RETURN NEW;
END;
$$;

-- 3) Scheduled ride execution must carry over stored quote.
CREATE OR REPLACE FUNCTION public.scheduled_rides_execute_due(p_limit integer DEFAULT 100) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public, extensions'
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
    LIMIT greatest(1, least(p_limit, 1000))
    FOR UPDATE SKIP LOCKED
  LOOP
    BEGIN
      -- Create ride request using the stored quote (no DB-side estimation).
      INSERT INTO public.ride_requests (
        rider_id,
        pickup_lat,
        pickup_lng,
        dropoff_lat,
        dropoff_lng,
        pickup_address,
        dropoff_address,
        product_code,
        preferences,
        service_area_id,
        currency,
        fare_quote_id,
        quote_amount_iqd
      ) VALUES (
        r.rider_id,
        r.pickup_lat,
        r.pickup_lng,
        r.dropoff_lat,
        r.dropoff_lng,
        r.pickup_address,
        r.dropoff_address,
        r.product_code,
        r.preferences,
        r.service_area_id,
        COALESCE(r.currency, 'IQD'),
        r.fare_quote_id,
        r.quote_amount_iqd
      )
      RETURNING id INTO v_request_id;

      -- Attempt matching using existing dispatch function (consistent behavior).
      PERFORM 1 FROM public.dispatch_match_ride(v_request_id, r.rider_id);

      UPDATE public.scheduled_rides
      SET
        status = 'executed',
        executed_at = now(),
        ride_request_id = v_request_id,
        failure_reason = NULL,
        updated_at = now()
      WHERE id = r.id;

      v_count := v_count + 1;
    EXCEPTION WHEN OTHERS THEN
      UPDATE public.scheduled_rides
      SET
        status = 'failed',
        failure_reason = SQLERRM,
        updated_at = now()
      WHERE id = r.id;
    END;
  END LOOP;

  RETURN v_count;
END;
$$;

-- 4) Dispatch functions must not fall back to legacy SQL quote estimation.
CREATE OR REPLACE FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid)
RETURNS TABLE(
  ride_id uuid,
  ride_status public.ride_status,
  request_status public.ride_request_status,
  wallet_hold_id uuid,
  rider_id uuid,
  driver_id uuid,
  started_at timestamp with time zone,
  completed_at timestamp with time zone,
  fare_amount_iqd integer,
  currency text
)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog, public, extensions'
AS $$
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
    RAISE EXCEPTION 'invalid_quote';
  END IF;

  UPDATE public.ride_requests
    SET status = 'accepted'
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

  v_hold_id := public.wallet_hold_upsert_for_ride(r.rider_id, r.id, COALESCE(r.fare_amount_iqd, v_quote)::bigint);

  PERFORM public.transition_driver(p_driver_id, 'on_trip'::public.driver_status, p_driver_id, 'accept_ride');

  RETURN QUERY
    SELECT r.id, r.status, 'accepted'::public.ride_request_status, v_hold_id, r.rider_id, r.driver_id, r.started_at, r.completed_at, r.fare_amount_iqd, r.currency;
END;
$$;

CREATE OR REPLACE FUNCTION public.dispatch_match_ride(
  p_request_id uuid,
  p_rider_id uuid,
  p_radius_m numeric DEFAULT 5000,
  p_limit_n integer DEFAULT 20,
  p_match_ttl_seconds integer DEFAULT 120,
  p_stale_after_seconds integer DEFAULT 120
)
RETURNS TABLE(
  id uuid,
  status public.ride_request_status,
  assigned_driver_id uuid,
  match_deadline timestamp with time zone,
  match_attempts integer,
  matched_at timestamp with time zone
)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog, public, extensions'
AS $$
DECLARE
  rr record;
  candidate uuid;
  up record;
  tried uuid[] := '{}'::uuid[];
  v_balance bigint;
  v_held bigint;
  v_available bigint;
  v_quote bigint;
  v_req_capacity int := 4;
  v_stale_after int;
BEGIN
  v_stale_after := greatest(30, coalesce(p_stale_after_seconds, 120));

  PERFORM public.expire_matched_ride_requests_v1(200);

  SELECT * INTO rr
  FROM public.ride_requests AS req
  WHERE req.id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'ride_request_not_found';
  END IF;

  IF rr.rider_id <> p_rider_id THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  IF rr.status = 'accepted' THEN
    RETURN QUERY SELECT rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
    RETURN;
  END IF;

  IF rr.status = 'matched' AND rr.match_deadline IS NOT NULL AND rr.match_deadline <= now() THEN
    PERFORM public.transition_driver(rr.assigned_driver_id, 'available'::public.driver_status, NULL, 'match_expired');

    UPDATE public.ride_requests
      SET status = 'requested',
          assigned_driver_id = NULL,
          match_deadline = NULL
    WHERE id = rr.id AND status = 'matched';

    rr.status := 'requested';
    rr.assigned_driver_id := NULL;
    rr.match_deadline := NULL;
  END IF;

  IF rr.status <> 'requested' THEN
    RETURN QUERY SELECT rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
    RETURN;
  END IF;

  SELECT capacity_min INTO v_req_capacity
  FROM public.ride_products
  WHERE code = rr.product_code;

  v_req_capacity := coalesce(v_req_capacity, 4);

  SELECT coalesce(w.balance_iqd, 0), coalesce(w.held_iqd, 0)
    INTO v_balance, v_held
  FROM public.wallet_accounts w
  WHERE w.user_id = rr.rider_id;

  v_available := coalesce(v_balance, 0) - coalesce(v_held, 0);

  v_quote := coalesce(rr.quote_amount_iqd, 0)::bigint;
  IF v_quote <= 0 THEN
    RAISE EXCEPTION 'invalid_quote';
  END IF;

  IF v_available < v_quote THEN
    RAISE EXCEPTION 'insufficient_wallet_balance';
  END IF;

  FOR i IN 1..3 LOOP
    WITH pickup AS (
      SELECT rr.pickup_loc AS pickup
    ), candidates AS (
      SELECT d.id AS driver_id
      FROM public.drivers d
      CROSS JOIN pickup
      JOIN public.driver_locations dl
        ON dl.driver_id = d.id
       AND dl.updated_at >= now() - make_interval(secs => v_stale_after)
      WHERE d.status = 'available'
        AND NOT (d.id = ANY(tried))
        AND extensions.st_dwithin(dl.loc, pickup.pickup, p_radius_m)
        AND EXISTS (
          SELECT 1 FROM public.driver_vehicles v
          WHERE v.driver_id = d.id
            AND coalesce(v.is_active, true) = true
            AND coalesce(v.capacity, 4) >= v_req_capacity
        )
        AND NOT EXISTS (
          SELECT 1 FROM public.rides r
          WHERE r.driver_id = d.id
            AND r.status IN ('assigned','arrived','in_progress')
        )
        AND NOT EXISTS (
          SELECT 1 FROM public.ride_requests rr2
          WHERE rr2.assigned_driver_id = d.id
            AND rr2.status = 'matched'
            AND (rr2.match_deadline IS NULL OR rr2.match_deadline > now())
        )
      ORDER BY extensions.st_distance(dl.loc, pickup.pickup)
      LIMIT p_limit_n
    ), locked AS (
      SELECT c.driver_id
      FROM candidates c
      JOIN public.drivers d ON d.id = c.driver_id
      WHERE d.status = 'available'
      FOR UPDATE OF d SKIP LOCKED
      LIMIT 1
    )
    SELECT driver_id INTO candidate FROM locked;

    EXIT WHEN candidate IS NULL;

    BEGIN
      PERFORM public.transition_driver(candidate, 'reserved'::public.driver_status, NULL, 'matching');
    EXCEPTION WHEN OTHERS THEN
      tried := array_append(tried, candidate);
      CONTINUE;
    END;

    BEGIN
      UPDATE public.ride_requests AS req
        SET status = 'matched',
            assigned_driver_id = candidate,
            match_attempts = rr.match_attempts + 1,
            match_deadline = now() + make_interval(secs => p_match_ttl_seconds)
      WHERE req.id = rr.id
        AND req.status = 'requested'
        AND req.assigned_driver_id IS NULL
      RETURNING req.id, req.status, req.assigned_driver_id, req.match_deadline, req.match_attempts, req.matched_at
        INTO up;

      IF FOUND THEN
        RETURN QUERY SELECT up.id, up.status, up.assigned_driver_id, up.match_deadline, up.match_attempts, up.matched_at;
        RETURN;
      END IF;
    EXCEPTION
      WHEN unique_violation THEN
        PERFORM public.transition_driver(candidate, 'available'::public.driver_status, NULL, 'match_conflict');
      WHEN OTHERS THEN
        PERFORM public.transition_driver(candidate, 'available'::public.driver_status, NULL, 'match_error');
        RAISE;
    END;

    tried := array_append(tried, candidate);
    PERFORM public.transition_driver(candidate, 'available'::public.driver_status, NULL, 'match_failed');
  END LOOP;

  RETURN QUERY SELECT rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
END;
$$;

-- 5) Update fare_quotes engine default to match the new engine name.
ALTER TABLE IF EXISTS public.fare_quotes
  ALTER COLUMN engine SET DEFAULT 'fare-engine-v1';

-- 6) Drop legacy SQL quote functions (replaced by Edge fare-engine + fare_quotes).
DROP FUNCTION IF EXISTS public.quote_breakdown_iqd(double precision, double precision, double precision, double precision, text);
DROP FUNCTION IF EXISTS public.quote_products_iqd(double precision, double precision, double precision, double precision);
DROP FUNCTION IF EXISTS public.estimate_ride_quote_breakdown_iqd_v1(extensions.geography, extensions.geography, text);
DROP FUNCTION IF EXISTS public.estimate_ride_quote_iqd(extensions.geography, extensions.geography);
DROP FUNCTION IF EXISTS public.estimate_ride_quote_iqd_v2(extensions.geography, extensions.geography, text);
