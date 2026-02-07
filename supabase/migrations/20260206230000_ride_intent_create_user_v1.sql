-- Session: Ride intent create user RPC
--
-- Goal:
--   Make `ride-intent-create` a thin Edge wrapper around a single DB RPC.
--   This centralizes service-area resolution and the insert in one transaction,
--   reduces duplicate business logic, and avoids direct table writes from Edge.

BEGIN;

CREATE OR REPLACE FUNCTION public.ride_intent_create_user_v1(
  p_pickup_lat double precision,
  p_pickup_lng double precision,
  p_dropoff_lat double precision,
  p_dropoff_lng double precision,
  p_pickup_address text DEFAULT NULL,
  p_dropoff_address text DEFAULT NULL,
  p_product_code text DEFAULT 'standard',
  p_scheduled_at timestamp with time zone DEFAULT NULL,
  p_source public.ride_intent_source DEFAULT 'callcenter',
  p_preferences jsonb DEFAULT '{}'::jsonb,
  p_intent_id uuid DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public, extensions'
AS $$
DECLARE
  v_uid uuid;
  v_area_id uuid;
  v_area_name text;
  v_area_governorate text;
  v_intent public.ride_intents;
  v_product text;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  -- Resolve service area from pickup coordinates.
  SELECT sa.id, sa.name, sa.governorate
    INTO v_area_id, v_area_name, v_area_governorate
  FROM public.resolve_service_area(p_pickup_lat, p_pickup_lng) sa;

  IF v_area_id IS NULL THEN
    RAISE EXCEPTION 'outside_service_area';
  END IF;

  -- Normalize product code and validate it's active.
  v_product := lower(left(coalesce(p_product_code, 'standard'), 32));
  IF NOT EXISTS (
    SELECT 1
    FROM public.ride_products rp
    WHERE rp.code = v_product
      AND rp.is_active
  ) THEN
    RAISE EXCEPTION 'invalid_product';
  END IF;

  -- Optional idempotency: if a caller provides p_intent_id and it already exists for
  -- this user, return it instead of inserting a duplicate.
  IF p_intent_id IS NOT NULL THEN
    SELECT * INTO v_intent
    FROM public.ride_intents
    WHERE id = p_intent_id;

    IF FOUND THEN
      IF v_intent.rider_id <> v_uid THEN
        RAISE EXCEPTION 'forbidden';
      END IF;

      RETURN jsonb_build_object(
        'intent', jsonb_build_object(
          'id', v_intent.id,
          'created_at', v_intent.created_at,
          'service_area_id', v_intent.service_area_id,
          'product_code', v_intent.product_code,
          'source', v_intent.source,
          'status', v_intent.status
        ),
        'service_area', jsonb_build_object(
          'id', v_area_id,
          'name', v_area_name,
          'governorate', v_area_governorate
        )
      );
    END IF;
  END IF;

  INSERT INTO public.ride_intents(
    id,
    rider_id,
    pickup_lat,
    pickup_lng,
    dropoff_lat,
    dropoff_lng,
    pickup_address,
    dropoff_address,
    service_area_id,
    product_code,
    scheduled_at,
    source,
    status,
    preferences
  ) VALUES (
    coalesce(p_intent_id, gen_random_uuid()),
    v_uid,
    p_pickup_lat,
    p_pickup_lng,
    p_dropoff_lat,
    p_dropoff_lng,
    p_pickup_address,
    p_dropoff_address,
    v_area_id,
    v_product,
    p_scheduled_at,
    p_source,
    'new'::public.ride_intent_status,
    coalesce(p_preferences, '{}'::jsonb)
  )
  RETURNING * INTO v_intent;

  RETURN jsonb_build_object(
    'intent', jsonb_build_object(
      'id', v_intent.id,
      'created_at', v_intent.created_at,
      'service_area_id', v_intent.service_area_id,
      'product_code', v_intent.product_code,
      'source', v_intent.source,
      'status', v_intent.status
    ),
    'service_area', jsonb_build_object(
      'id', v_area_id,
      'name', v_area_name,
      'governorate', v_area_governorate
    )
  );
END;
$$;

COMMENT ON FUNCTION public.ride_intent_create_user_v1(
  p_pickup_lat double precision,
  p_pickup_lng double precision,
  p_dropoff_lat double precision,
  p_dropoff_lng double precision,
  p_pickup_address text,
  p_dropoff_address text,
  p_product_code text,
  p_scheduled_at timestamp with time zone,
  p_source public.ride_intent_source,
  p_preferences jsonb,
  p_intent_id uuid
) IS 'Creates a ride intent for auth.uid() with server-side service-area resolution; optional p_intent_id supports idempotent retries.';

ALTER FUNCTION public.ride_intent_create_user_v1(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  timestamp with time zone,
  public.ride_intent_source,
  jsonb,
  uuid
) OWNER TO postgres;

REVOKE ALL ON FUNCTION public.ride_intent_create_user_v1(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  timestamp with time zone,
  public.ride_intent_source,
  jsonb,
  uuid
) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.ride_intent_create_user_v1(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  timestamp with time zone,
  public.ride_intent_source,
  jsonb,
  uuid
) FROM anon;

GRANT EXECUTE ON FUNCTION public.ride_intent_create_user_v1(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  timestamp with time zone,
  public.ride_intent_source,
  jsonb,
  uuid
) TO authenticated;

GRANT EXECUTE ON FUNCTION public.ride_intent_create_user_v1(
  double precision,
  double precision,
  double precision,
  double precision,
  text,
  text,
  text,
  timestamp with time zone,
  public.ride_intent_source,
  jsonb,
  uuid
) TO service_role;

COMMIT;
