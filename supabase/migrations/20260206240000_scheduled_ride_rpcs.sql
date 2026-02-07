-- Session: Scheduled rides RPC hardening
--
-- Goal:
--   Make scheduled ride create/cancel operations transactionally enforced in DB.
--   Edge functions remain thin wrappers (auth/rate-limit/fraud gating only).
--
-- Rationale:
--   Scheduled rides are a correctness-sensitive booking primitive. The DB should
--   own invariants (bounds, limits, ownership) and apply them transactionally.

BEGIN;

CREATE OR REPLACE FUNCTION public.scheduled_ride_create_user_v1(
  p_pickup_lat double precision,
  p_pickup_lng double precision,
  p_dropoff_lat double precision,
  p_dropoff_lng double precision,
  p_pickup_address text DEFAULT NULL,
  p_dropoff_address text DEFAULT NULL,
  p_product_code text DEFAULT 'standard',
  p_scheduled_at timestamp with time zone DEFAULT NULL,
  p_preferences jsonb DEFAULT '{}'::jsonb,
  p_payment_method public.ride_payment_method DEFAULT 'wallet',
  p_fare_quote_id uuid DEFAULT NULL,
  p_scheduled_ride_id uuid DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public, extensions'
AS $$
DECLARE
  v_uid uuid;
  v_product text;
  v_now timestamptz := now();
  v_min timestamptz := v_now + interval '5 minutes';
  v_max timestamptz := v_now + interval '14 days';
  v_day_start timestamptz;
  v_day_end timestamptz;
  v_total int;
  v_today int;
  v_quote public.fare_quotes;
  v_area_id uuid;
  v_sr public.scheduled_rides;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  IF p_scheduled_at IS NULL THEN
    RAISE EXCEPTION 'validation_error';
  END IF;

  IF p_scheduled_at < v_min THEN
    RAISE EXCEPTION 'scheduled_at_too_soon';
  END IF;

  IF p_scheduled_at > v_max THEN
    RAISE EXCEPTION 'scheduled_at_too_far';
  END IF;

  v_product := lower(left(coalesce(p_product_code, 'standard'), 32));

  IF NOT EXISTS (
    SELECT 1
    FROM public.ride_products rp
    WHERE rp.code = v_product
      AND rp.is_active
  ) THEN
    RAISE EXCEPTION 'invalid_product';
  END IF;

  -- Optional idempotency: if the caller supplies an ID and it already exists for this
  -- user, return it instead of inserting a duplicate.
  IF p_scheduled_ride_id IS NOT NULL THEN
    SELECT * INTO v_sr
    FROM public.scheduled_rides
    WHERE id = p_scheduled_ride_id;

    IF FOUND THEN
      IF v_sr.rider_id <> v_uid THEN
        RAISE EXCEPTION 'forbidden';
      END IF;

      RETURN jsonb_build_object(
        'scheduled_ride', to_jsonb(v_sr),
        'already_exists', true
      );
    END IF;
  END IF;

  IF p_fare_quote_id IS NULL THEN
    RAISE EXCEPTION 'missing_fare_quote';
  END IF;

  SELECT * INTO v_quote
  FROM public.fare_quotes
  WHERE id = p_fare_quote_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'invalid_fare_quote';
  END IF;

  IF v_quote.rider_id <> v_uid THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  IF v_quote.product_code <> v_product THEN
    RAISE EXCEPTION 'invalid_fare_quote';
  END IF;

  v_area_id := v_quote.service_area_id;
  IF v_area_id IS NULL THEN
    SELECT sa.id INTO v_area_id
    FROM public.resolve_service_area(p_pickup_lat, p_pickup_lng) sa;
  END IF;

  IF v_area_id IS NULL
     OR NOT EXISTS (
       SELECT 1 FROM public.service_areas sa WHERE sa.id = v_area_id AND sa.is_active
     )
  THEN
    RAISE EXCEPTION 'outside_service_area';
  END IF;

  -- Per-user pending limits.
  SELECT count(*) INTO v_total
  FROM public.scheduled_rides
  WHERE rider_id = v_uid
    AND status = 'pending'::public.scheduled_ride_status;

  IF v_total >= 20 THEN
    RAISE EXCEPTION 'too_many_pending';
  END IF;

  -- Daily limit should align with the primary operating timezone.
  -- Convert to local midnight and back to timestamptz for consistent boundaries.
  v_day_start := (date_trunc('day', p_scheduled_at AT TIME ZONE 'Asia/Baghdad') AT TIME ZONE 'Asia/Baghdad');
  v_day_end := v_day_start + interval '1 day';

  SELECT count(*) INTO v_today
  FROM public.scheduled_rides
  WHERE rider_id = v_uid
    AND status = 'pending'::public.scheduled_ride_status
    AND scheduled_at >= v_day_start
    AND scheduled_at < v_day_end;

  IF v_today >= 5 THEN
    RAISE EXCEPTION 'too_many_pending_today';
  END IF;

  INSERT INTO public.scheduled_rides(
    id,
    rider_id,
    pickup_lat,
    pickup_lng,
    dropoff_lat,
    dropoff_lng,
    pickup_address,
    dropoff_address,
    product_code,
    scheduled_at,
    preferences,
    service_area_id,
    fare_quote_id,
    quote_amount_iqd,
    currency,
    payment_method,
    payment_status
  ) VALUES (
    coalesce(p_scheduled_ride_id, gen_random_uuid()),
    v_uid,
    p_pickup_lat,
    p_pickup_lng,
    p_dropoff_lat,
    p_dropoff_lng,
    p_pickup_address,
    p_dropoff_address,
    v_product,
    p_scheduled_at,
    coalesce(p_preferences, '{}'::jsonb),
    v_area_id,
    v_quote.id,
    v_quote.total_iqd,
    v_quote.currency,
    coalesce(p_payment_method, 'wallet'::public.ride_payment_method),
    'unpaid'::public.ride_payment_status
  )
  RETURNING * INTO v_sr;

  RETURN jsonb_build_object(
    'scheduled_ride', to_jsonb(v_sr),
    'already_exists', false
  );
END;
$$;

COMMENT ON FUNCTION public.scheduled_ride_create_user_v1(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  timestamp with time zone,
  jsonb,
  public.ride_payment_method,
  uuid,
  uuid
) IS 'Creates a scheduled ride for auth.uid() with server-side validation and fare-quote ownership enforcement.';

ALTER FUNCTION public.scheduled_ride_create_user_v1(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  timestamp with time zone,
  jsonb,
  public.ride_payment_method,
  uuid,
  uuid
) OWNER TO postgres;

REVOKE ALL ON FUNCTION public.scheduled_ride_create_user_v1(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  timestamp with time zone,
  jsonb,
  public.ride_payment_method,
  uuid,
  uuid
) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.scheduled_ride_create_user_v1(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  timestamp with time zone,
  jsonb,
  public.ride_payment_method,
  uuid,
  uuid
) FROM anon;

GRANT EXECUTE ON FUNCTION public.scheduled_ride_create_user_v1(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  timestamp with time zone,
  jsonb,
  public.ride_payment_method,
  uuid,
  uuid
) TO authenticated;

GRANT EXECUTE ON FUNCTION public.scheduled_ride_create_user_v1(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  timestamp with time zone,
  jsonb,
  public.ride_payment_method,
  uuid,
  uuid
) TO service_role;

CREATE OR REPLACE FUNCTION public.scheduled_ride_cancel_user_v1(
  p_id uuid
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public, extensions'
AS $$
DECLARE
  v_uid uuid;
  v_sr public.scheduled_rides;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  SELECT * INTO v_sr
  FROM public.scheduled_rides
  WHERE id = p_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found';
  END IF;

  IF v_sr.rider_id <> v_uid THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  IF v_sr.status = 'cancelled'::public.scheduled_ride_status THEN
    RETURN jsonb_build_object(
      'scheduled_ride', to_jsonb(v_sr),
      'already_cancelled', true
    );
  END IF;

  IF v_sr.status <> 'pending'::public.scheduled_ride_status THEN
    RAISE EXCEPTION 'cannot_cancel';
  END IF;

  UPDATE public.scheduled_rides
     SET status = 'cancelled'::public.scheduled_ride_status,
         cancelled_at = now()
   WHERE id = p_id
   RETURNING * INTO v_sr;

  RETURN jsonb_build_object(
    'scheduled_ride', to_jsonb(v_sr),
    'already_cancelled', false
  );
END;
$$;

COMMENT ON FUNCTION public.scheduled_ride_cancel_user_v1(uuid)
IS 'Cancels a pending scheduled ride belonging to auth.uid(); idempotent if already cancelled.';

ALTER FUNCTION public.scheduled_ride_cancel_user_v1(uuid) OWNER TO postgres;

REVOKE ALL ON FUNCTION public.scheduled_ride_cancel_user_v1(uuid) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.scheduled_ride_cancel_user_v1(uuid) FROM anon;

GRANT EXECUTE ON FUNCTION public.scheduled_ride_cancel_user_v1(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.scheduled_ride_cancel_user_v1(uuid) TO service_role;

COMMIT;
