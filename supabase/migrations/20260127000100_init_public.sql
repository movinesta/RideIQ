-- RideIQ: public schema init (generated from supabase/schema.sql pg_dump)
-- Generated: 2026-01-27
-- Note: This migration intentionally includes ONLY objects in the `public` schema.
--       Supabase-managed schemas (auth, storage, etc.) are not recreated here.

-- Required extensions (Supabase local + hosted provide these; IF NOT EXISTS keeps it safe)
create extension if not exists pgcrypto with schema extensions;
create extension if not exists "uuid-ossp" with schema extensions;
create extension if not exists postgis with schema extensions;


--

CREATE TYPE public.app_event_level AS ENUM (
    'info',
    'warn',
    'error'
);


ALTER TYPE public.app_event_level OWNER TO postgres;

--
-- TOC entry 2283 (class 1247 OID 39596)

--

CREATE TYPE public.driver_status AS ENUM (
    'offline',
    'available',
    'on_trip',
    'suspended',
    'reserved',
    'assigned'
);


ALTER TYPE public.driver_status OWNER TO postgres;

--
-- TOC entry 2286 (class 1247 OID 39608)

--

CREATE TYPE public.incident_severity AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);


ALTER TYPE public.incident_severity OWNER TO postgres;

--
-- TOC entry 2289 (class 1247 OID 39618)

--

CREATE TYPE public.incident_status AS ENUM (
    'open',
    'triaging',
    'resolved',
    'closed'
);


ALTER TYPE public.incident_status OWNER TO postgres;

--
-- TOC entry 2292 (class 1247 OID 39628)

--

CREATE TYPE public.kyc_status AS ENUM (
    'unverified',
    'pending',
    'verified',
    'rejected'
);


ALTER TYPE public.kyc_status OWNER TO postgres;

--
-- TOC entry 2295 (class 1247 OID 39638)

--

CREATE TYPE public.party_role AS ENUM (
    'rider',
    'driver'
);


ALTER TYPE public.party_role OWNER TO postgres;

--
-- TOC entry 2298 (class 1247 OID 39644)

--

CREATE TYPE public.payment_intent_status AS ENUM (
    'requires_payment_method',
    'requires_confirmation',
    'requires_capture',
    'succeeded',
    'failed',
    'canceled',
    'refunded'
);


ALTER TYPE public.payment_intent_status OWNER TO postgres;

--
-- TOC entry 2301 (class 1247 OID 39660)

--

CREATE TYPE public.payment_provider_kind AS ENUM (
    'zaincash',
    'asiapay',
    'qicard',
    'manual'
);


ALTER TYPE public.payment_provider_kind OWNER TO postgres;

--
-- TOC entry 2304 (class 1247 OID 39670)

--

CREATE TYPE public.ride_actor_type AS ENUM (
    'rider',
    'driver',
    'system'
);


ALTER TYPE public.ride_actor_type OWNER TO postgres;

--
-- TOC entry 2307 (class 1247 OID 39678)

--

CREATE TYPE public.ride_request_status AS ENUM (
    'requested',
    'matched',
    'accepted',
    'cancelled',
    'no_driver',
    'expired'
);


ALTER TYPE public.ride_request_status OWNER TO postgres;

--
-- TOC entry 2310 (class 1247 OID 39692)

--

CREATE TYPE public.ride_status AS ENUM (
    'assigned',
    'arrived',
    'in_progress',
    'completed',
    'canceled'
);


ALTER TYPE public.ride_status OWNER TO postgres;

--
-- TOC entry 2516 (class 1247 OID 43536)

--

CREATE TYPE public.scheduled_ride_status AS ENUM (
    'pending',
    'cancelled',
    'executed',
    'failed'
);


ALTER TYPE public.scheduled_ride_status OWNER TO postgres;

--
-- TOC entry 2313 (class 1247 OID 39704)

--

CREATE TYPE public.topup_status AS ENUM (
    'created',
    'pending',
    'succeeded',
    'failed'
);


ALTER TYPE public.topup_status OWNER TO postgres;

--
-- TOC entry 2316 (class 1247 OID 39714)

--

CREATE TYPE public.wallet_entry_kind AS ENUM (
    'topup',
    'ride_fare',
    'withdrawal',
    'adjustment'
);


ALTER TYPE public.wallet_entry_kind OWNER TO postgres;

--
-- TOC entry 2319 (class 1247 OID 39724)

--

CREATE TYPE public.wallet_hold_kind AS ENUM (
    'ride',
    'withdraw'
);


ALTER TYPE public.wallet_hold_kind OWNER TO postgres;

--
-- TOC entry 2322 (class 1247 OID 39730)

--

CREATE TYPE public.wallet_hold_status AS ENUM (
    'active',
    'captured',
    'released',
    'held'
);


ALTER TYPE public.wallet_hold_status OWNER TO postgres;

--
-- TOC entry 2325 (class 1247 OID 39738)

--

CREATE TYPE public.withdraw_payout_kind AS ENUM (
    'qicard',
    'asiapay',
    'zaincash'
);


ALTER TYPE public.withdraw_payout_kind OWNER TO postgres;

--
-- TOC entry 2328 (class 1247 OID 39746)

--

CREATE TYPE public.withdraw_request_status AS ENUM (
    'requested',
    'approved',
    'rejected',
    'paid',
    'cancelled'
);


ALTER TYPE public.withdraw_request_status OWNER TO postgres;

--
-- TOC entry 2215 (class 1247 OID 17122)

--

CREATE FUNCTION public.achievement_claim(p_key text) RETURNS TABLE(achievement_key text, claimed boolean, reward_iqd integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_uid uuid := (select auth.uid());
  v_a public.achievements%rowtype;
  v_p public.achievement_progress%rowtype;
  v_reward integer;
  v_key text := trim(coalesce(p_key, ''));
  v_idem text;
begin
  if v_uid is null then
    raise exception 'unauthorized';
  end if;
  if v_key = '' then
    raise exception 'invalid_key';
  end if;

  select * into v_a from public.achievements where key = v_key and active;
  if not found then
    raise exception 'achievement_not_found';
  end if;

  select * into v_p
  from public.achievement_progress
  where user_id = v_uid and achievement_id = v_a.id
  for update;

  if not found or v_p.completed_at is null then
    raise exception 'achievement_not_completed';
  end if;

  if v_p.claimed_at is not null then
    return query select v_key, true, v_a.reward_iqd;
    return;
  end if;

  v_reward := coalesce(v_a.reward_iqd, 0);

  if v_reward > 0 then
    v_idem := 'achievement:' || v_key || ':' || v_uid::text;

    insert into public.wallet_accounts(user_id)
    values (v_uid)
    on conflict (user_id) do nothing;

    insert into public.wallet_entries(
      user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key
    )
    values (
      v_uid,
      v_reward::bigint,
      'reward',
      'Achievement reward',
      'achievement',
      v_a.id,
      jsonb_build_object('achievement_key', v_key),
      v_idem
    )
    on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

    update public.wallet_accounts
      set balance_iqd = balance_iqd + v_reward::bigint,
          updated_at = now()
    where user_id = v_uid;
  end if;

  update public.achievement_progress
    set claimed_at = now(),
        updated_at = now()
  where id = v_p.id;

  perform public.notify_user(v_uid, 'achievement_claimed', 'Achievement unlocked', 'Reward claimed successfully.', jsonb_build_object('achievement_key', v_key, 'reward_iqd', v_reward));

  return query select v_key, true, v_reward;
end;
$$;


ALTER FUNCTION public.achievement_claim(p_key text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 410 (class 1259 OID 39757)

--

CREATE TABLE public.gift_codes (
    code text NOT NULL,
    amount_iqd bigint NOT NULL,
    memo text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    redeemed_by uuid,
    redeemed_at timestamp with time zone,
    redeemed_entry_id bigint,
    CONSTRAINT gift_codes_amount_iqd_check CHECK ((amount_iqd > 0))
);


ALTER TABLE public.gift_codes OWNER TO postgres;

--
-- TOC entry 725 (class 1255 OID 39764)

--

CREATE FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text DEFAULT NULL::text, p_memo text DEFAULT NULL::text) RETURNS public.gift_codes
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
DECLARE
  v_code text;
  v_row public.gift_codes;
  v_memo text;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not_admin' USING errcode = '42501';
  END IF;

  IF p_amount_iqd IS NULL OR p_amount_iqd <= 0 THEN
    RAISE EXCEPTION 'invalid_amount';
  END IF;

  v_code := upper(trim(coalesce(p_code, '')));
  v_memo := nullif(trim(coalesce(p_memo, '')), '');

  IF v_code = '' THEN
    v_code := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));
  END IF;

  LOOP
    BEGIN
      INSERT INTO public.gift_codes (code, amount_iqd, memo, created_by)
      VALUES (v_code, p_amount_iqd, v_memo, auth.uid())
      RETURNING * INTO v_row;
      EXIT;
    EXCEPTION WHEN unique_violation THEN
      IF p_code IS NOT NULL AND trim(p_code) <> '' THEN
        RAISE EXCEPTION 'gift_code_exists';
      END IF;
      v_code := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));
    END;
  END LOOP;

  RETURN v_row;
END;
$$;


ALTER FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) OWNER TO postgres;

--
-- TOC entry 1312 (class 1255 OID 43614)

--

CREATE FUNCTION public.admin_create_service_area_bbox(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer DEFAULT 0, p_is_active boolean DEFAULT true, p_pricing_config_id uuid DEFAULT NULL::uuid) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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
    extensions.ST_Multi(extensions.ST_MakeEnvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326))
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


ALTER FUNCTION public.admin_create_service_area_bbox(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer, p_is_active boolean, p_pricing_config_id uuid) OWNER TO postgres;

--
-- TOC entry 1368 (class 1255 OID 43673)

--

CREATE FUNCTION public.admin_create_service_area_bbox_v2(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer DEFAULT 0, p_is_active boolean DEFAULT true, p_pricing_config_id uuid DEFAULT NULL::uuid, p_notes text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


ALTER FUNCTION public.admin_create_service_area_bbox_v2(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer, p_is_active boolean, p_pricing_config_id uuid, p_notes text) OWNER TO postgres;

--
-- TOC entry 644 (class 1255 OID 44210)

--

CREATE FUNCTION public.admin_create_service_area_bbox_v2(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer DEFAULT 0, p_is_active boolean DEFAULT true, p_pricing_config_id uuid DEFAULT NULL::uuid, p_min_base_fare_iqd integer DEFAULT NULL::integer, p_surge_multiplier numeric DEFAULT NULL::numeric, p_surge_reason text DEFAULT NULL::text, p_notes text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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
    extensions.ST_Multi(extensions.ST_MakeEnvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326))
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


ALTER FUNCTION public.admin_create_service_area_bbox_v2(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer, p_is_active boolean, p_pricing_config_id uuid, p_min_base_fare_iqd integer, p_surge_multiplier numeric, p_surge_reason text, p_notes text) OWNER TO postgres;

--
-- TOC entry 1119 (class 1255 OID 39765)

--

CREATE FUNCTION public.admin_mark_stale_drivers_offline(p_stale_after_seconds integer DEFAULT 120, p_limit integer DEFAULT 500) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
DECLARE
  v_count integer := 0;
  v_limit integer;
BEGIN
  v_limit := greatest(1, least(coalesce(p_limit, 500), 5000));

  WITH stale AS (
    SELECT d.id
    FROM public.drivers d
    JOIN public.driver_locations dl ON dl.driver_id = d.id
    WHERE d.status = 'available'
      AND dl.updated_at < now() - make_interval(secs => greatest(1, coalesce(p_stale_after_seconds, 120)))
    ORDER BY dl.updated_at ASC
    LIMIT v_limit
  )
  UPDATE public.drivers d
  SET status = 'offline'
  WHERE d.id IN (SELECT id FROM stale);

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;


ALTER FUNCTION public.admin_mark_stale_drivers_offline(p_stale_after_seconds integer, p_limit integer) OWNER TO postgres;

--
-- TOC entry 1140 (class 1255 OID 39766)

--

CREATE FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer DEFAULT NULL::integer, p_reason text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  v_receipt public.ride_receipts%rowtype;
  v_payment public.payments%rowtype;
  v_total integer;
  v_prev_refunded integer;
  v_add integer;
  v_new_total integer;
  v_ref_id text;
begin
  -- authz
  if not public.is_admin() then
    raise exception 'not_admin' using errcode = '42501';
  end if;

  -- lock receipt
  select * into v_receipt
  from public.ride_receipts
  where ride_id = p_ride_id
  for update;

  if not found then
    raise exception 'receipt_not_found' using errcode = 'P0002';
  end if;

  v_total := coalesce(v_receipt.total_iqd, 0);
  v_prev_refunded := coalesce(v_receipt.refunded_iqd, 0);

  if p_refund_amount_iqd is null then
    v_add := greatest(v_total - v_prev_refunded, 0);
  else
    v_add := greatest(least(p_refund_amount_iqd, v_total - v_prev_refunded), 0);
  end if;

  if v_add <= 0 then
    return jsonb_build_object(
      'ride_id', p_ride_id,
      'refunded_iqd', v_prev_refunded,
      'added_iqd', 0,
      'status', 'no_op',
      'reason', p_reason
    );
  end if;

  v_new_total := v_prev_refunded + v_add;

  -- lock latest succeeded payment
  select * into v_payment
  from public.payments
  where ride_id = p_ride_id and status = 'succeeded'
  order by created_at desc
  limit 1
  for update;

  if not found then
    raise exception 'payment_not_found' using errcode = 'P0002';
  end if;

  v_ref_id := coalesce(v_payment.provider_refund_id, 'manual_refund:' || gen_random_uuid()::text);

  update public.payments
  set provider_refund_id = v_ref_id,
      refunded_at = now(),
      refund_amount_iqd = v_new_total,
      updated_at = now()
  where id = v_payment.id;

  return jsonb_build_object(
    'ride_id', p_ride_id,
    'payment_id', v_payment.id,
    'provider_refund_id', v_ref_id,
    'added_iqd', v_add,
    'refunded_iqd', v_new_total,
    'reason', p_reason
  );
end;
$$;


ALTER FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) OWNER TO postgres;

--
-- TOC entry 869 (class 1255 OID 43882)

--

CREATE FUNCTION public.admin_ridecheck_escalate(p_event_id uuid, p_note text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.admin_ridecheck_escalate(p_event_id uuid, p_note text) OWNER TO postgres;

--
-- TOC entry 1321 (class 1255 OID 43881)

--

CREATE FUNCTION public.admin_ridecheck_resolve(p_event_id uuid, p_note text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.admin_ridecheck_resolve(p_event_id uuid, p_note text) OWNER TO postgres;

--
-- TOC entry 1229 (class 1255 OID 43672)

--

CREATE FUNCTION public.admin_update_pricing_config_caps(p_id uuid, p_max_surge_multiplier numeric) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


ALTER FUNCTION public.admin_update_pricing_config_caps(p_id uuid, p_max_surge_multiplier numeric) OWNER TO postgres;

--
-- TOC entry 727 (class 1255 OID 39767)

--

CREATE FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status DEFAULT NULL::public.incident_status, p_assigned_to uuid DEFAULT NULL::uuid, p_resolution_note text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
begin
  if not public.is_admin() then
    raise exception 'not_allowed';
  end if;

  update public.ride_incidents
  set
    status = coalesce(p_status, status),
    assigned_to = coalesce(p_assigned_to, assigned_to),
    resolution_note = coalesce(p_resolution_note, resolution_note),
    reviewed_at = case when p_status is null then reviewed_at else now() end
  where id = p_incident_id;

  if not found then
    raise exception 'not_found';
  end if;
end;
$$;


ALTER FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) OWNER TO postgres;

--
-- TOC entry 937 (class 1255 OID 39768)

--

CREATE FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer DEFAULT 50, p_hold_age_seconds integer DEFAULT 3600, p_topup_age_seconds integer DEFAULT 600) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_limit int := greatest(1, least(coalesce(p_limit, 50), 200));
  v_hold_age interval := make_interval(secs => greatest(60, least(coalesce(p_hold_age_seconds, 3600), 30 * 24 * 3600)));
  v_topup_age interval := make_interval(secs => greatest(30, least(coalesce(p_topup_age_seconds, 600), 7 * 24 * 3600)));
  v_now timestamptz := now();

  v_accounts_count bigint;
  v_balance_sum bigint;
  v_held_sum bigint;
  v_active_holds_sum bigint;

  v_active_holds_old jsonb;
  v_active_holds_terminal_ride jsonb;
  v_completed_rides_missing_entries jsonb;
  v_held_mismatch jsonb;
  v_topup_succeeded_missing_entry jsonb;
  v_topup_stuck_pending jsonb;
begin
  if not public.is_admin() then
    raise exception 'not_allowed';
  end if;

  select
    count(*)::bigint,
    coalesce(sum(balance_iqd), 0)::bigint,
    coalesce(sum(held_iqd), 0)::bigint
  into v_accounts_count, v_balance_sum, v_held_sum
  from public.wallet_accounts;

  select coalesce(sum(amount_iqd), 0)::bigint
  into v_active_holds_sum
  from public.wallet_holds
  where status = 'active';

  -- 1) Active holds that are older than a threshold
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_active_holds_old
  from (
    select
      h.id as hold_id,
      h.user_id,
      h.ride_id,
      h.amount_iqd,
      h.created_at,
      h.updated_at
    from public.wallet_holds h
    where h.status = 'active'
      and h.created_at < (v_now - v_hold_age)
    order by h.created_at asc
    limit v_limit
  ) t;

  -- 2) Active holds where the related ride is already terminal (should have been captured/released)
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_active_holds_terminal_ride
  from (
    select
      h.id as hold_id,
      h.user_id,
      h.ride_id,
      h.amount_iqd,
      h.created_at,
      r.status as ride_status,
      r.updated_at as ride_updated_at
    from public.wallet_holds h
    join public.rides r on r.id = h.ride_id
    where h.status = 'active'
      and r.status in ('completed','canceled')
    order by r.updated_at desc
    limit v_limit
  ) t;

  -- 3) Completed rides missing either the rider debit or driver credit entry
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_completed_rides_missing_entries
  from (
    select
      r.id as ride_id,
      r.rider_id,
      r.driver_id,
      r.status,
      r.completed_at,
      r.updated_at,
      not exists(
        select 1
        from public.wallet_entries we
        where we.user_id = r.rider_id
          and we.idempotency_key = ('ride:' || r.id::text || ':rider_debit')
      ) as missing_rider_debit,
      not exists(
        select 1
        from public.wallet_entries we
        where we.user_id = r.driver_id
          and we.idempotency_key = ('ride:' || r.id::text || ':driver_credit')
      ) as missing_driver_credit,
      (
        select h.id
        from public.wallet_holds h
        where h.ride_id = r.id
        order by h.created_at desc
        limit 1
      ) as hold_id
    from public.rides r
    where r.status = 'completed'
      and r.completed_at is not null
      and r.completed_at >= (v_now - interval '30 days')
      and (
        not exists(
          select 1
          from public.wallet_entries we
          where we.user_id = r.rider_id
            and we.idempotency_key = ('ride:' || r.id::text || ':rider_debit')
        )
        or not exists(
          select 1
          from public.wallet_entries we
          where we.user_id = r.driver_id
            and we.idempotency_key = ('ride:' || r.id::text || ':driver_credit')
        )
      )
    order by r.completed_at desc
    limit v_limit
  ) t;

  -- 4) held_iqd mismatch vs active holds sum per user (tolerate small drift by requiring exact match)
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_held_mismatch
  from (
    with holds as (
      select user_id, coalesce(sum(amount_iqd), 0)::bigint as holds_active
      from public.wallet_holds
      where status = 'active'
      group by user_id
    )
    select
      wa.user_id,
      wa.held_iqd,
      coalesce(h.holds_active, 0) as holds_active,
      (wa.held_iqd - coalesce(h.holds_active, 0)) as diff
    from public.wallet_accounts wa
    left join holds h on h.user_id = wa.user_id
    where wa.held_iqd <> coalesce(h.holds_active, 0)
    order by abs(wa.held_iqd - coalesce(h.holds_active, 0)) desc
    limit v_limit
  ) t;

  -- 5) Succeeded top-ups missing their wallet entry
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_topup_succeeded_missing_entry
  from (
    select
      ti.id as intent_id,
      ti.user_id,
      ti.provider_code,
      ti.provider_tx_id,
      ti.amount_iqd,
      ti.bonus_iqd,
      ti.completed_at,
      ti.updated_at
    from public.topup_intents ti
    where ti.status = 'succeeded'
      and not exists (
        select 1
        from public.wallet_entries we
        where we.user_id = ti.user_id
          and we.idempotency_key = ('topup:' || ti.id::text)
      )
    order by ti.updated_at desc
    limit v_limit
  ) t;

  -- 6) Top-ups stuck in created/pending beyond a threshold
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_topup_stuck_pending
  from (
    select
      ti.id as intent_id,
      ti.user_id,
      ti.provider_code,
      ti.status,
      ti.provider_tx_id,
      ti.created_at,
      ti.updated_at
    from public.topup_intents ti
    where ti.status in ('created','pending')
      and ti.created_at < (v_now - v_topup_age)
    order by ti.created_at asc
    limit v_limit
  ) t;

  return jsonb_build_object(
    'ok', true,
    'generated_at', v_now,
    'params', jsonb_build_object(
      'limit', v_limit,
      'hold_age_seconds', extract(epoch from v_hold_age)::int,
      'topup_age_seconds', extract(epoch from v_topup_age)::int
    ),
    'summary', jsonb_build_object(
      'accounts_count', v_accounts_count,
      'balance_iqd_sum', v_balance_sum,
      'held_iqd_sum', v_held_sum,
      'active_holds_iqd_sum', v_active_holds_sum,
      'held_minus_active_holds', (v_held_sum - v_active_holds_sum)
    ),
    'issues', jsonb_build_object(
      'active_holds_old', v_active_holds_old,
      'active_holds_terminal_ride', v_active_holds_terminal_ride,
      'completed_rides_missing_entries', v_completed_rides_missing_entries,
      'held_iqd_mismatch', v_held_mismatch,
      'topup_succeeded_missing_entry', v_topup_succeeded_missing_entry,
      'topup_stuck_pending', v_topup_stuck_pending
    )
  );
end;
$$;


ALTER FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) OWNER TO postgres;

--
-- TOC entry 1406 (class 1255 OID 39770)

--

CREATE FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
DECLARE
  r record;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not_admin';
  END IF;

  SELECT * INTO r
  FROM public.wallet_withdraw_requests
  WHERE id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'withdraw_request_not_found';
  END IF;

  IF r.status <> 'requested' THEN
    RAISE EXCEPTION 'invalid_status_transition';
  END IF;

  UPDATE public.wallet_withdraw_requests
  SET status = 'approved',
      note = COALESCE(p_note, note),
      approved_at = now(),
      updated_at = now()
  WHERE id = r.id;

  PERFORM public.notify_user(r.user_id, 'withdraw_approved', 'Withdrawal approved',
    'Your withdrawal request was approved and will be paid soon.',
    jsonb_build_object('request_id', r.id, 'amount_iqd', r.amount_iqd, 'payout_kind', r.payout_kind)
  );
END;
$$;


ALTER FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) OWNER TO postgres;

--
-- TOC entry 649 (class 1255 OID 39771)

--

CREATE FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
DECLARE
  r record;
  h record;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not_admin';
  END IF;

  SELECT * INTO r
  FROM public.wallet_withdraw_requests
  WHERE id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'withdraw_request_not_found';
  END IF;

  IF r.status <> 'approved' THEN
    RAISE EXCEPTION 'invalid_status_transition';
  END IF;

  -- lock active hold
  SELECT * INTO h
  FROM public.wallet_holds
  WHERE withdraw_request_id = r.id AND status = 'active'
  ORDER BY created_at DESC
  LIMIT 1
  FOR UPDATE;

  -- lock wallet account
  PERFORM 1 FROM public.wallet_accounts wa WHERE wa.user_id = r.user_id FOR UPDATE;

  UPDATE public.wallet_accounts
  SET held_iqd = GREATEST(held_iqd - r.amount_iqd, 0),
      balance_iqd = balance_iqd - r.amount_iqd,
      updated_at = now()
  WHERE user_id = r.user_id;

  -- ledger entry
  INSERT INTO public.wallet_entries (user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
  VALUES (
    r.user_id,
    -r.amount_iqd,
    'withdrawal',
    'Driver withdrawal',
    'withdraw',
    r.id,
    jsonb_build_object(
      'payout_kind', r.payout_kind,
      'destination', r.destination,
      'payout_reference', p_payout_reference
    ),
    'withdraw:' || r.id::text
  )
  ON CONFLICT (idempotency_key) DO NOTHING;

  UPDATE public.wallet_holds
  SET status = 'captured', captured_at = now(), updated_at = now()
  WHERE id = h.id AND status = 'active';

  UPDATE public.wallet_withdraw_requests
  SET status = 'paid',
      payout_reference = COALESCE(p_payout_reference, payout_reference),
      paid_at = now(),
      updated_at = now()
  WHERE id = r.id;

  PERFORM public.notify_user(r.user_id, 'withdraw_paid', 'Withdrawal paid',
    CASE WHEN p_payout_reference IS NULL OR p_payout_reference = '' THEN 'Your withdrawal has been paid.'
      ELSE 'Your withdrawal has been paid. Reference: ' || p_payout_reference END,
    jsonb_build_object('request_id', r.id, 'amount_iqd', r.amount_iqd, 'payout_kind', r.payout_kind, 'payout_reference', p_payout_reference)
  );
END;
$$;


ALTER FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) OWNER TO postgres;

--
-- TOC entry 582 (class 1255 OID 39772)

--

CREATE FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
DECLARE
  r record;
  h record;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not_admin';
  END IF;

  SELECT * INTO r
  FROM public.wallet_withdraw_requests
  WHERE id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'withdraw_request_not_found';
  END IF;

  IF r.status NOT IN ('requested','approved') THEN
    RAISE EXCEPTION 'invalid_status_transition';
  END IF;

  SELECT * INTO h
  FROM public.wallet_holds
  WHERE withdraw_request_id = r.id AND status = 'active'
  ORDER BY created_at DESC
  LIMIT 1
  FOR UPDATE;

  UPDATE public.wallet_holds
  SET status = 'released', released_at = now(), updated_at = now()
  WHERE id = h.id AND status = 'active';

  UPDATE public.wallet_accounts
  SET held_iqd = GREATEST(held_iqd - r.amount_iqd, 0),
      updated_at = now()
  WHERE user_id = r.user_id;

  UPDATE public.wallet_withdraw_requests
  SET status = 'rejected',
      note = COALESCE(p_note, note),
      rejected_at = now(),
      updated_at = now()
  WHERE id = r.id;

  PERFORM public.notify_user(r.user_id, 'withdraw_rejected', 'Withdrawal rejected',
    COALESCE(p_note, 'Your withdrawal request was rejected and funds were released.'),
    jsonb_build_object('request_id', r.id, 'amount_iqd', r.amount_iqd, 'payout_kind', r.payout_kind)
  );
END;
$$;


ALTER FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) OWNER TO postgres;

--
-- TOC entry 775 (class 1255 OID 39773)

--

CREATE FUNCTION public.apply_rating_aggregate() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
begin
  if new.ratee_role = 'driver' then
    update public.drivers
      set rating_avg = ((rating_avg * rating_count) + new.rating)::numeric / (rating_count + 1),
          rating_count = rating_count + 1
      where id = new.ratee_id;
  elsif new.ratee_role = 'rider' then
    update public.profiles
      set rating_avg = ((rating_avg * rating_count) + new.rating)::numeric / (rating_count + 1),
          rating_count = rating_count + 1
      where id = new.ratee_id;
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.apply_rating_aggregate() OWNER TO postgres;

--
-- TOC entry 533 (class 1255 OID 40785)

--

CREATE FUNCTION public.apply_referral_rewards(p_referred_id uuid, p_ride_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_redemption public.referral_redemptions%rowtype;
  v_campaign public.referral_campaigns%rowtype;
  v_first boolean;
  v_ref_reward int;
  v_new_reward int;
  v_idem text;
begin
  if p_referred_id is null or p_ride_id is null then
    return;
  end if;

  -- First completed ride check
  select not exists (
    select 1 from public.rides r
    where r.rider_id = p_referred_id
      and r.status = 'completed'
      and r.id <> p_ride_id
  ) into v_first;

  if not v_first then
    return;
  end if;

  select * into v_redemption
  from public.referral_redemptions
  where referred_id = p_referred_id
    and status = 'pending'
  for update;

  if not found then
    return;
  end if;

  select * into v_campaign
  from public.referral_campaigns
  where id = v_redemption.campaign_id and active;

  if not found then
    update public.referral_redemptions
      set status = 'invalid',
          earned_at = now(),
          rewarded_at = now(),
          ride_id = p_ride_id
    where id = v_redemption.id;
    return;
  end if;

  v_ref_reward := coalesce(v_campaign.referrer_reward_iqd, 0);
  v_new_reward := coalesce(v_campaign.referred_reward_iqd, 0);

  -- Idempotency via wallet_entries idempotency_key
  if v_ref_reward > 0 then
    insert into public.wallet_accounts(user_id)
    values (v_redemption.referrer_id)
    on conflict (user_id) do nothing;

    v_idem := 'referral:' || v_redemption.id::text || ':referrer';
    insert into public.wallet_entries(user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
    values (
      v_redemption.referrer_id,
      v_ref_reward::bigint,
      'reward',
      'Referral reward',
      'referral',
      v_redemption.id,
      jsonb_build_object('referred_id', p_referred_id, 'ride_id', p_ride_id),
      v_idem
    )
    on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

    update public.wallet_accounts
      set balance_iqd = balance_iqd + v_ref_reward::bigint,
          updated_at = now()
    where user_id = v_redemption.referrer_id;
  end if;

  if v_new_reward > 0 then
    insert into public.wallet_accounts(user_id)
    values (p_referred_id)
    on conflict (user_id) do nothing;

    v_idem := 'referral:' || v_redemption.id::text || ':referred';
    insert into public.wallet_entries(user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
    values (
      p_referred_id,
      v_new_reward::bigint,
      'reward',
      'Referral reward',
      'referral',
      v_redemption.id,
      jsonb_build_object('referrer_id', v_redemption.referrer_id, 'ride_id', p_ride_id),
      v_idem
    )
    on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

    update public.wallet_accounts
      set balance_iqd = balance_iqd + v_new_reward::bigint,
          updated_at = now()
    where user_id = p_referred_id;
  end if;

  update public.referral_redemptions
    set status = 'rewarded',
        earned_at = now(),
        rewarded_at = now(),
        ride_id = p_ride_id
  where id = v_redemption.id;

  perform public.notify_user(v_redemption.referrer_id, 'referral_reward', 'Referral reward earned', 'Your referral completed their first ride. Reward added to your wallet.', jsonb_build_object('reward_iqd', v_ref_reward, 'referred_id', p_referred_id));
  perform public.notify_user(p_referred_id, 'referral_reward', 'Welcome reward', 'You completed your first ride. Reward added to your wallet.', jsonb_build_object('reward_iqd', v_new_reward, 'referrer_id', v_redemption.referrer_id));
end;
$$;


ALTER FUNCTION public.apply_referral_rewards(p_referred_id uuid, p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 939 (class 1255 OID 39774)

--

CREATE FUNCTION public.create_receipt_from_payment() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_ride public.rides%rowtype;
  v_base integer;
  v_total integer;
  v_tip integer;
  v_currency text;
begin
  -- Only generate receipt for succeeded payments
  if new.status <> 'succeeded' then
    return new;
  end if;

  select * into v_ride from public.rides where id = new.ride_id;
  if not found then
    return new;
  end if;

  v_currency := coalesce(new.currency, v_ride.currency, 'IQD');
  v_total := greatest(new.amount_iqd, 0);
  v_base := coalesce(v_ride.fare_amount_iqd, v_total);
  v_tip := greatest(v_total - v_base, 0);

  insert into public.ride_receipts (ride_id, base_fare_iqd, tax_iqd, tip_iqd, total_iqd, currency)
  values (new.ride_id, v_base, 0, v_tip, v_total, v_currency)
  on conflict (ride_id) do update
    set base_fare_iqd = excluded.base_fare_iqd,
        tax_iqd = excluded.tax_iqd,
        tip_iqd = excluded.tip_iqd,
        total_iqd = excluded.total_iqd,
        currency = excluded.currency,
        generated_at = now();

  return new;
end;
$$;


ALTER FUNCTION public.create_receipt_from_payment() OWNER TO postgres;

--
-- TOC entry 1389 (class 1255 OID 39775)

--

CREATE FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity DEFAULT 'low'::public.incident_severity) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_uid uuid;
  v_ok boolean;
  v_id uuid;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  select exists(
    select 1 from public.rides r
    where r.id = p_ride_id and (r.rider_id = v_uid or r.driver_id = v_uid)
  ) into v_ok;

  if not v_ok then
    raise exception 'not_allowed';
  end if;

  insert into public.ride_incidents (ride_id, reporter_id, category, description, severity)
  values (p_ride_id, v_uid, left(coalesce(p_category,''), 120), nullif(p_description,''), p_severity)
  returning id into v_id;

  return v_id;
end;
$$;


ALTER FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) OWNER TO postgres;

--
-- TOC entry 910 (class 1255 OID 41368)

--

CREATE FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) RETURNS TABLE(ride_id uuid, ride_status public.ride_status, request_status public.ride_request_status, wallet_hold_id uuid, rider_id uuid, driver_id uuid, started_at timestamp with time zone, completed_at timestamp with time zone, fare_amount_iqd integer, currency text)
    LANGUAGE plpgsql SECURITY DEFINER
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
    v_quote := COALESCE(public.estimate_ride_quote_iqd_v2(rr.pickup_loc, rr.dropoff_loc, rr.product_code), 0)::bigint;
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

  v_hold_id := public.wallet_hold_upsert_for_ride(r.rider_id, r.id, COALESCE(r.fare_amount_iqd, v_quote)::bigint);

  UPDATE public.drivers
    SET status = 'on_trip'
  WHERE id = p_driver_id;

  RETURN QUERY
    SELECT r.id, r.status, 'accepted'::public.ride_request_status, v_hold_id, r.rider_id, r.driver_id, r.started_at, r.completed_at, r.fare_amount_iqd, r.currency;
END;
$$;


ALTER FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) OWNER TO postgres;

--
-- TOC entry 1296 (class 1255 OID 39777)

--

CREATE FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric DEFAULT 5000, p_limit_n integer DEFAULT 20, p_match_ttl_seconds integer DEFAULT 120, p_stale_after_seconds integer DEFAULT 30) RETURNS TABLE(id uuid, status public.ride_request_status, assigned_driver_id uuid, match_deadline timestamp with time zone, match_attempts integer, matched_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
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
    where id = rr.assigned_driver_id and status in ('reserved', 'assigned');

    update public.ride_requests
      set status = 'requested',
          assigned_driver_id = null,
          match_deadline = null
    where id = rr.id and status = 'matched';
    rr.status := 'requested';
    rr.assigned_driver_id := null;
    rr.match_deadline := null;
  end if;

  if rr.status <> 'requested' then
    return query select rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
    return;
  end if;

  select capacity_min into v_req_capacity
  from public.ride_products
  where code = rr.product_code;

  v_req_capacity := coalesce(v_req_capacity, 4);

  v_quote := coalesce(rr.quote_amount_iqd, 0)::bigint;
  if v_quote <= 0 then
    v_quote := public.estimate_ride_quote_iqd_v2(rr.pickup_loc, rr.dropoff_loc, rr.product_code)::bigint;
    if v_quote <= 0 then
      raise exception 'invalid_quote';
    end if;
  end if;

  insert into public.wallet_accounts(user_id)
  values (rr.rider_id)
  on conflict (user_id) do nothing;

  select balance_iqd, held_iqd
    into v_balance, v_held
  from public.wallet_accounts
  where user_id = rr.rider_id;

  v_available := coalesce(v_balance,0) - coalesce(v_held,0);
  if v_available < v_quote then
    raise exception 'insufficient_wallet_balance';
  end if;

  for i in 1..3 loop
    candidate := null;

    with pickup as (
      select rr.pickup_loc as pickup
    ), candidates as (
      select d.id as driver_id
      from public.drivers d
      join public.driver_locations dl on dl.driver_id = d.id
      cross join pickup
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
      order by extensions.st_distance(dl.loc, pickup.pickup)
      limit p_limit_n
    ), locked as (
      select c.driver_id
      from candidates c
      join public.drivers d on d.id = c.driver_id
      where d.status = 'available'
      for update of d skip locked
      limit 1
    )
    select driver_id into candidate from locked;

    exit when candidate is null;

    -- ✅ CHANGE HERE: reserve the driver, don’t "assign" them
    update public.drivers
      set status = 'reserved'
    where public.drivers.id = candidate and public.drivers.status = 'available';

    if not found then
      tried := array_append(tried, candidate);
      continue;
    end if;

    begin
      update public.ride_requests as req
        set status = 'matched',
            assigned_driver_id = candidate,
            match_attempts = rr.match_attempts + 1,
            match_deadline = now() + make_interval(secs => p_match_ttl_seconds)
      where req.id = rr.id
        and req.status = 'requested'
        and assigned_driver_id is null
      returning req.id, req.status, req.assigned_driver_id, req.match_deadline, req.match_attempts, req.matched_at
        into up;

      if found then
        return query select up.id, up.status, up.assigned_driver_id, up.match_deadline, up.match_attempts, up.matched_at;
        return;
      end if;
    exception
      when unique_violation then
        update public.drivers
          set status = 'available'
        where id = candidate and status in ('reserved', 'assigned');
      when others then
        update public.drivers
          set status = 'available'
        where id = candidate and status in ('reserved', 'assigned');
        raise;
    end;

    tried := array_append(tried, candidate);

    update public.drivers
      set status = 'available'
    where id = candidate and status in ('reserved', 'assigned');
  end loop;

  return query select rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
end;
$$;


ALTER FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer) OWNER TO postgres;

--
-- TOC entry 1386 (class 1255 OID 41844)

--

CREATE FUNCTION public.driver_leaderboard_refresh_day(p_day date DEFAULT NULL::date) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v_day date := coalesce(p_day, (now() at time zone 'utc')::date);
begin
  -- Ensure stats exist
  perform public.driver_stats_rollup_day(v_day);

  -- Score: trips + (earnings in thousands)
  with base as (
    select
      day,
      driver_id,
      trips_count,
      earnings_iqd,
      (trips_count::numeric + (earnings_iqd::numeric / 1000.0)) as score
    from public.driver_stats_daily
    where day = v_day
  ),
  ranked as (
    select
      b.*,
      dense_rank() over (order by b.score desc, b.trips_count desc, b.earnings_iqd desc, b.driver_id) as rnk
    from base b
  )
  insert into public.driver_leaderboard_daily (day, driver_id, trips_count, earnings_iqd, score, rank, updated_at)
  select day, driver_id, trips_count, earnings_iqd, score, rnk, now()
  from ranked
  on conflict (day, driver_id) do update
    set trips_count = excluded.trips_count,
        earnings_iqd = excluded.earnings_iqd,
        score = excluded.score,
        rank = excluded.rank,
        updated_at = now();
end;
$$;


ALTER FUNCTION public.driver_leaderboard_refresh_day(p_day date) OWNER TO postgres;

--
-- TOC entry 832 (class 1255 OID 41824)

--

CREATE FUNCTION public.driver_stats_rollup_day(p_day date DEFAULT NULL::date) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v_day date := coalesce(p_day, (now() at time zone 'utc')::date);
begin
  -- Aggregate completed rides for each driver on v_day using wallet entries (driver credit)
  insert into public.driver_stats_daily (day, driver_id, trips_count, earnings_iqd, updated_at)
  select
    v_day as day,
    r.driver_id,
    count(*)::int as trips_count,
    coalesce(sum(we.delta_iqd),0)::bigint as earnings_iqd,
    now()
  from public.rides r
  left join public.wallet_entries we
    on we.source_type = 'ride'
   and we.source_id = r.id
   and we.user_id = r.driver_id
   and we.kind = 'ride_fare'
   and we.delta_iqd > 0
  where r.status = 'completed'
    and (r.completed_at at time zone 'utc')::date = v_day
  group by r.driver_id
  on conflict (day, driver_id) do update
    set trips_count = excluded.trips_count,
        earnings_iqd = excluded.earnings_iqd,
        updated_at = now();
end;
$$;


ALTER FUNCTION public.driver_stats_rollup_day(p_day date) OWNER TO postgres;

--
-- TOC entry 556 (class 1255 OID 42211)

--

CREATE FUNCTION public.drivers_force_id_from_auth_uid() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_catalog'
    AS $$
begin
  if (select auth.uid()) is not null then
    new.id := (select auth.uid());
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.drivers_force_id_from_auth_uid() OWNER TO postgres;

--
-- TOC entry 648 (class 1255 OID 40629)

--

CREATE FUNCTION public.enqueue_notification_outbox() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  insert into public.notification_outbox (notification_id, user_id, device_token_id, payload)
  select
    new.id,
    new.user_id,
    dt.id,
    jsonb_build_object(
      'title', new.title,
      'body', new.body,
      'type', new.kind,
      'data', coalesce(new.data, '{}'::jsonb),
      'notification_id', new.id::text
    )
  from public.device_tokens dt
  where dt.user_id = new.user_id and dt.enabled = true;

  return new;
end;
$$;


ALTER FUNCTION public.enqueue_notification_outbox() OWNER TO postgres;

--
-- TOC entry 828 (class 1255 OID 40783)

--

CREATE FUNCTION public.ensure_referral_code(p_user_id uuid DEFAULT NULL::uuid) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_uid uuid := coalesce(p_user_id, (select auth.uid()));
  v_code text;
  v_try int := 0;
begin
  if v_uid is null then
    raise exception 'unauthorized';
  end if;

  select code into v_code from public.referral_codes where user_id = v_uid;
  if found then
    return v_code;
  end if;

  loop
    v_try := v_try + 1;
    v_code := upper(substring(replace(encode(gen_random_bytes(6), 'base32'), '=', '') from 1 for 8));

    begin
      insert into public.referral_codes(code, user_id)
      values (v_code, v_uid);
      return v_code;
    exception when unique_violation then
      if v_try > 10 then
        raise exception 'could_not_generate_code';
      end if;
    end;
  end loop;
end;
$$;


ALTER FUNCTION public.ensure_referral_code(p_user_id uuid) OWNER TO postgres;

--
-- TOC entry 1036 (class 1255 OID 39779)

--

CREATE FUNCTION public.ensure_wallet_account() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
BEGIN
  INSERT INTO public.wallet_accounts(user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.ensure_wallet_account() OWNER TO postgres;

--
-- TOC entry 1227 (class 1255 OID 43670)

--

CREATE FUNCTION public.estimate_ride_quote_breakdown_iqd_v1(_pickup extensions.geography, _dropoff extensions.geography, _product_code text DEFAULT 'standard'::text) RETURNS jsonb
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
  SELECT s.currency, s.base_fare_iqd, s.per_km_iqd, s.per_min_iqd, s.minimum_fare_iqd, s.max_surge_multiplier
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


ALTER FUNCTION public.estimate_ride_quote_breakdown_iqd_v1(_pickup extensions.geography, _dropoff extensions.geography, _product_code text) OWNER TO postgres;

--
-- TOC entry 542 (class 1255 OID 39780)

--

CREATE FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) RETURNS integer
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
  select s.currency, s.base_fare_iqd, s.per_km_iqd, s.per_min_iqd, s.minimum_fare_iqd
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


ALTER FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) OWNER TO postgres;

--
-- TOC entry 943 (class 1255 OID 41228)

--

CREATE FUNCTION public.estimate_ride_quote_iqd_v2(_pickup extensions.geography, _dropoff extensions.geography, _product_code text DEFAULT 'standard'::text) RETURNS integer
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
  select s.currency, s.base_fare_iqd, s.per_km_iqd, s.per_min_iqd, s.minimum_fare_iqd
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


ALTER FUNCTION public.estimate_ride_quote_iqd_v2(_pickup extensions.geography, _dropoff extensions.geography, _product_code text) OWNER TO postgres;

--
-- TOC entry 1054 (class 1255 OID 40788)

--

CREATE FUNCTION public.get_assigned_driver(p_ride_id uuid) RETURNS TABLE(driver_id uuid, display_name text, rating_avg numeric, rating_count integer, vehicle_make text, vehicle_model text, vehicle_color text, plate_number text)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_uid uuid := (select auth.uid());
  v_ride record;
begin
  if v_uid is null then
    raise exception 'unauthorized';
  end if;

  select r.id, r.rider_id, r.driver_id into v_ride
  from public.rides r
  where r.id = p_ride_id;

  if not found then
    raise exception 'ride_not_found';
  end if;

  if v_ride.rider_id <> v_uid and v_ride.driver_id <> v_uid and not (select public.is_admin()) then
    raise exception 'forbidden';
  end if;

  return query
  select
    d.id,
    pp.display_name,
    d.rating_avg,
    d.rating_count,
    dv.make,
    dv.model,
    dv.color,
    dv.plate_number
  from public.drivers d
  left join public.public_profiles pp on pp.id = d.id
  left join lateral (
    select make, model, color, plate_number
    from public.driver_vehicles
    where driver_id = d.id
    order by updated_at desc nulls last, created_at desc
    limit 1
  ) dv on true
  where d.id = v_ride.driver_id;
end;
$$;


ALTER FUNCTION public.get_assigned_driver(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 681 (class 1255 OID 40680)

--

CREATE FUNCTION public.get_driver_leaderboard(p_period text, p_period_start date DEFAULT NULL::date, p_limit integer DEFAULT 50) RETURNS TABLE(rank integer, driver_id uuid, display_name text, rating_avg numeric, score_iqd bigint, rides_completed integer)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
  with params as (
    select
      lower(coalesce(p_period, 'weekly')) as period,
      coalesce(
        p_period_start,
        case
          when lower(coalesce(p_period, 'weekly')) = 'weekly' then date_trunc('week', now())::date
          else date_trunc('month', now())::date
        end
      ) as period_start,
      greatest(1, least(coalesce(p_limit, 50), 200)) as lim
  )
  select
    s.rank,
    s.driver_id,
    pp.display_name,
    d.rating_avg,
    s.score_iqd,
    s.rides_completed
  from params p
  join public.driver_rank_snapshots s
    on s.period = p.period and s.period_start = p.period_start
  join public.drivers d on d.id = s.driver_id
  left join public.public_profiles pp on pp.id = s.driver_id
  order by s.rank
  limit (select lim from params);
$$;


ALTER FUNCTION public.get_driver_leaderboard(p_period text, p_period_start date, p_limit integer) OWNER TO postgres;

--
-- TOC entry 1114 (class 1255 OID 39781)

--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
begin
  insert into public.profiles (id, display_name, phone)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name', null), new.phone);
  return new;
end;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- TOC entry 693 (class 1255 OID 39782)

--

CREATE FUNCTION public.is_admin() RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
  select coalesce((select p.is_admin from public.profiles p where p.id = auth.uid()), false);
$$;


ALTER FUNCTION public.is_admin() OWNER TO postgres;

--
-- TOC entry 1031 (class 1255 OID 43965)

--

CREATE FUNCTION public.is_admin(p_user uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'auth'
    AS $_$
DECLARE
  v boolean := false;
BEGIN
  -- Option A: dedicated admin table (admin_users.user_id)
  IF to_regclass('public.admin_users') IS NOT NULL THEN
    EXECUTE 'SELECT EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = $1)'
      INTO v USING p_user;
    RETURN v;
  END IF;

  -- Option B: profiles.role
  IF to_regclass('public.profiles') IS NOT NULL
     AND EXISTS (
       SELECT 1 FROM information_schema.columns
       WHERE table_schema='public' AND table_name='profiles' AND column_name='role'
     )
  THEN
    EXECUTE
      'SELECT EXISTS (
         SELECT 1 FROM public.profiles
         WHERE id = $1 AND role IN (''admin'',''super_admin'')
       )'
      INTO v USING p_user;
    RETURN v;
  END IF;

  -- Option C: profiles.is_admin boolean
  IF to_regclass('public.profiles') IS NOT NULL
     AND EXISTS (
       SELECT 1 FROM information_schema.columns
       WHERE table_schema='public' AND table_name='profiles' AND column_name='is_admin'
     )
  THEN
    EXECUTE 'SELECT COALESCE((SELECT is_admin FROM public.profiles WHERE id=$1), false)'
      INTO v USING p_user;
    RETURN v;
  END IF;

  RETURN false;
END;
$_$;


ALTER FUNCTION public.is_admin(p_user uuid) OWNER TO postgres;

--
-- TOC entry 921 (class 1255 OID 43810)

--

CREATE FUNCTION public.is_pickup_pin_required_v1(p_rider_id uuid, p_driver_id uuid) RETURNS boolean
    LANGUAGE sql STABLE
    SET search_path TO 'pg_catalog', 'public'
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


ALTER FUNCTION public.is_pickup_pin_required_v1(p_rider_id uuid, p_driver_id uuid) OWNER TO postgres;

--
-- TOC entry 785 (class 1255 OID 40631)

--

CREATE FUNCTION public.notification_outbox_claim(p_limit integer DEFAULT 50) RETURNS TABLE(id bigint, notification_id uuid, user_id uuid, attempts integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
begin
  return query
  with picked as (
    select o.id
    from public.notification_outbox o
    where o.status = 'pending'
    order by o.id
    limit greatest(1, least(coalesce(p_limit, 50), 200))
    for update skip locked
  )
  update public.notification_outbox o
    set status = 'processing',
        attempts = o.attempts + 1,
        last_attempt_at = now()
  where o.id in (select id from picked)
  returning o.id, o.notification_id, o.user_id, o.attempts;
end;
$$;


ALTER FUNCTION public.notification_outbox_claim(p_limit integer) OWNER TO postgres;

--
-- TOC entry 539 (class 1255 OID 40632)

--

CREATE FUNCTION public.notification_outbox_mark(p_outbox_id bigint, p_status text, p_error text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_status text := lower(coalesce(p_status, 'failed'));
begin
  if v_status not in ('sent','failed','skipped') then
    raise exception 'invalid_status';
  end if;

  update public.notification_outbox
    set status = v_status,
        last_error = case when v_status in ('failed') then left(coalesce(p_error,''), 1000) else null end
  where id = p_outbox_id;
end;
$$;


ALTER FUNCTION public.notification_outbox_mark(p_outbox_id bigint, p_status text, p_error text) OWNER TO postgres;

--
-- TOC entry 717 (class 1255 OID 39783)

--

CREATE FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text DEFAULT NULL::text, p_data jsonb DEFAULT '{}'::jsonb) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.user_notifications (user_id, kind, title, body, data)
  VALUES (p_user_id, p_kind, p_title, p_body, COALESCE(p_data, '{}'::jsonb))
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;


ALTER FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) OWNER TO postgres;

--
-- TOC entry 1032 (class 1255 OID 43746)

--

CREATE FUNCTION public.notify_users_bulk(p_user_ids uuid[], p_kind text, p_title text, p_body text DEFAULT NULL::text, p_data jsonb DEFAULT '{}'::jsonb) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
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


ALTER FUNCTION public.notify_users_bulk(p_user_ids uuid[], p_kind text, p_title text, p_body text, p_data jsonb) OWNER TO postgres;

--
-- TOC entry 1409 (class 1255 OID 40786)

--

CREATE FUNCTION public.on_ride_completed_side_effects() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_day date;
  v_amount bigint;
begin
  -- only for transitions into completed
  if new.status <> 'completed' or old.status = 'completed' then
    return new;
  end if;

  v_day := (coalesce(new.completed_at, now()) at time zone 'UTC')::date;
  v_amount := coalesce(new.fare_amount_iqd, 0)::bigint;

  -- trips_count on drivers
  update public.drivers
    set trips_count = trips_count + 1,
        updated_at = now()
  where id = new.driver_id;

  -- counters
  insert into public.driver_counters(driver_id, completed_rides, earnings_iqd, updated_at)
  values (new.driver_id, 1, v_amount, now())
  on conflict (driver_id) do update
    set completed_rides = public.driver_counters.completed_rides + 1,
        earnings_iqd = public.driver_counters.earnings_iqd + excluded.earnings_iqd,
        updated_at = now();

  -- daily stats
  insert into public.driver_stats_daily(driver_id, day, rides_completed, earnings_iqd, updated_at)
  values (new.driver_id, v_day, 1, v_amount, now())
  on conflict (driver_id, day) do update
    set rides_completed = public.driver_stats_daily.rides_completed + 1,
        earnings_iqd = public.driver_stats_daily.earnings_iqd + excluded.earnings_iqd,
        updated_at = now();

  -- achievements
  perform public.update_driver_achievements(new.driver_id);

  -- referrals (first ride reward)
  perform public.apply_referral_rewards(new.rider_id, new.id);

  -- optional notifications
  perform public.notify_user(new.driver_id, 'driver_trip_completed', 'Trip completed', 'Your earnings were added to your wallet.', jsonb_build_object('ride_id', new.id, 'amount_iqd', v_amount));
  perform public.notify_user(new.rider_id, 'rider_trip_completed', 'Trip completed', 'Thanks for riding with RideIQ.', jsonb_build_object('ride_id', new.id));

  return new;
end;
$$;


ALTER FUNCTION public.on_ride_completed_side_effects() OWNER TO postgres;

--
-- TOC entry 722 (class 1255 OID 41728)

--

CREATE FUNCTION public.on_ride_completed_v1(p_ride_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  v_ride public.rides;
  v_day date;
  v_first_driver_completed boolean := false;
  v_total_driver_completed int;
  v_a record;
  v_progress int;
  v_rewarded boolean := false;
  v_redemption public.referral_redemptions;
  v_campaign public.referral_campaigns;
  v_driver_reward bigint;
  v_referred_reward bigint;
begin
  -- idempotency guard
  insert into public.ride_completion_log (ride_id) values (p_ride_id)
  on conflict (ride_id) do nothing;

  if not found then
    return;
  end if;

  select * into v_ride from public.rides where id = p_ride_id;
  if not found then
    return;
  end if;

  if v_ride.status <> 'completed'::public.ride_status then
    return;
  end if;

  v_day := (v_ride.completed_at at time zone 'UTC')::date;

  -- Driver aggregate counters
  update public.drivers
    set trips_count = trips_count + 1,
        updated_at = now()
  where id = v_ride.driver_id;

  -- Driver daily stats
  insert into public.driver_stats_daily (driver_id, day, rides_completed, earnings_iqd)
  values (v_ride.driver_id, v_day, 1, coalesce(v_ride.fare_amount_iqd, 0))
  on conflict (driver_id, day) do update
    set rides_completed = public.driver_stats_daily.rides_completed + 1,
        earnings_iqd = public.driver_stats_daily.earnings_iqd + coalesce(v_ride.fare_amount_iqd, 0),
        updated_at = now();

  -- Achievement progress (driver rides completed)
  select trips_count into v_total_driver_completed from public.drivers where id = v_ride.driver_id;
  if v_total_driver_completed is null then
    v_total_driver_completed := 0;
  end if;

  for v_a in
    select a.key, a.target_value, a.reward_iqd
    from public.achievements a
    where a.audience = 'driver'
  loop
    v_progress := least(v_total_driver_completed, v_a.target_value);

    insert into public.user_achievement_progress (user_id, achievement_key, progress_value)
    values (v_ride.driver_id, v_a.key, v_progress)
    on conflict (user_id, achievement_key) do update
      set progress_value = excluded.progress_value,
          updated_at = now();

    -- Auto-grant reward when reaching target (idempotent via unique claim)
    if v_progress >= v_a.target_value then
      begin
        insert into public.achievement_claims (user_id, achievement_key, reward_iqd, idempotency_key)
        values (v_ride.driver_id, v_a.key, v_a.reward_iqd, concat('ach:', v_ride.driver_id::text, ':', v_a.key))
        on conflict (user_id, achievement_key) do nothing;

        if found and v_a.reward_iqd > 0 then
          perform public.wallet_adjust_v1(
            v_ride.driver_id,
            v_a.reward_iqd,
            'Achievement reward',
            'achievement',
            v_ride.id,
            concat('ach_reward:', v_ride.driver_id::text, ':', v_a.key),
            jsonb_build_object('achievement_key', v_a.key, 'ride_id', v_ride.id)
          );

          perform public.notify_user(
            v_ride.driver_id,
            'achievement',
            'Achievement unlocked!',
            v_a.key,
            jsonb_build_object('achievement_key', v_a.key)
          );
        end if;
      exception when others then
        -- do not break completion path
        null;
      end;
    end if;
  end loop;

  -- Referrals: when rider completes their first ride
  -- Determine first completed ride for the rider
  if v_ride.rider_id is not null then
    perform 1;
    if (select count(1) from public.rides r where r.rider_id = v_ride.rider_id and r.status = 'completed') = 1 then
      select * into v_redemption
      from public.referral_redemptions rr
      where rr.referred_user_id = v_ride.rider_id and rr.status = 'pending'
      limit 1;

      if found then
        select * into v_campaign
        from public.referral_campaigns c
        where c.id = v_redemption.campaign_id
        limit 1;

        if not found then
          -- fallback: first active campaign
          select * into v_campaign
          from public.referral_campaigns c
          where c.active = true
          order by c.created_at desc
          limit 1;
        end if;

        v_driver_reward := coalesce(v_campaign.reward_referrer_iqd, 0);
        v_referred_reward := coalesce(v_campaign.reward_referred_iqd, 0);

        update public.referral_redemptions
          set status = 'rewarded',
              rewarded_at = now()
        where id = v_redemption.id and status = 'pending';

        if found then
          if v_driver_reward > 0 then
            perform public.wallet_adjust_v1(
              v_redemption.referrer_user_id,
              v_driver_reward,
              'Referral reward',
              'referral',
              v_ride.id,
              concat('ref_reward_referrer:', v_redemption.id::text),
              jsonb_build_object('redemption_id', v_redemption.id, 'role', 'referrer')
            );
            perform public.notify_user(
              v_redemption.referrer_user_id,
              'referral',
              'Referral reward earned',
              null,
              jsonb_build_object('amount_iqd', v_driver_reward)
            );
          end if;

          if v_referred_reward > 0 then
            perform public.wallet_adjust_v1(
              v_redemption.referred_user_id,
              v_referred_reward,
              'Welcome bonus',
              'referral',
              v_ride.id,
              concat('ref_reward_referred:', v_redemption.id::text),
              jsonb_build_object('redemption_id', v_redemption.id, 'role', 'referred')
            );
            perform public.notify_user(
              v_redemption.referred_user_id,
              'referral',
              'Welcome bonus received',
              null,
              jsonb_build_object('amount_iqd', v_referred_reward)
            );
          end if;
        end if;
      end if;
    end if;
  end if;

end;
$$;


ALTER FUNCTION public.on_ride_completed_v1(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 1019 (class 1255 OID 39784)

--

CREATE FUNCTION public.profile_kyc_init() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
BEGIN
  INSERT INTO public.profile_kyc (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.profile_kyc_init() OWNER TO postgres;

--
-- TOC entry 971 (class 1255 OID 43671)

--

CREATE FUNCTION public.quote_breakdown_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision, p_product_code text DEFAULT 'standard'::text) RETURNS jsonb
    LANGUAGE sql STABLE
    SET search_path TO 'pg_catalog, extensions'
    AS $$
  SELECT public.estimate_ride_quote_breakdown_iqd_v1(
    (extensions.st_setsrid(extensions.st_makepoint(p_pickup_lng, p_pickup_lat), 4326))::extensions.geography,
    (extensions.st_setsrid(extensions.st_makepoint(p_dropoff_lng, p_dropoff_lat), 4326))::extensions.geography,
    p_product_code
  );
$$;


ALTER FUNCTION public.quote_breakdown_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision, p_product_code text) OWNER TO postgres;

--
-- TOC entry 889 (class 1255 OID 41229)

--

CREATE FUNCTION public.quote_products_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision) RETURNS TABLE(product_code text, product_name text, capacity_min integer, price_multiplier numeric, quote_amount_iqd integer)
    LANGUAGE sql STABLE
    SET search_path TO 'pg_catalog, extensions'
    AS $$
with pts as (
  select
    (extensions.st_setsrid(extensions.st_makepoint(p_pickup_lng, p_pickup_lat), 4326))::extensions.geography as pickup,
    (extensions.st_setsrid(extensions.st_makepoint(p_dropoff_lng, p_dropoff_lat), 4326))::extensions.geography as dropoff
)
select
  rp.code,
  rp.name,
  rp.capacity_min,
  rp.price_multiplier,
  public.estimate_ride_quote_iqd_v2(pts.pickup, pts.dropoff, rp.code) as quote_amount_iqd
from public.ride_products rp
cross join pts
where rp.is_active = true
order by rp.sort_order, rp.code;
$$;


ALTER FUNCTION public.quote_products_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision) OWNER TO postgres;

--
-- TOC entry 1419 (class 1255 OID 39785)

--

CREATE FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) RETURNS TABLE(allowed boolean, remaining integer, reset_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  now_ts timestamptz := now();
  epoch bigint := floor(extract(epoch from now_ts));
  start_epoch bigint;
  win_start timestamptz;
  new_count integer;
begin
  if p_window_seconds <= 0 or p_limit <= 0 then
    allowed := true;
    remaining := 0;
    reset_at := now_ts;
    return next;
    return;
  end if;

  start_epoch := (epoch / p_window_seconds) * p_window_seconds;
  win_start := to_timestamp(start_epoch);

  insert into public.api_rate_limits(key, window_start, window_seconds, count)
  values (p_key, win_start, p_window_seconds, 1)
  on conflict (key, window_start, window_seconds)
  do update set count = public.api_rate_limits.count + 1
  returning count into new_count;

  allowed := new_count <= p_limit;
  remaining := greatest(p_limit - new_count, 0);
  reset_at := win_start + make_interval(secs => p_window_seconds);
  return next;
end;
$$;


ALTER FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) OWNER TO postgres;

--
-- TOC entry 1064 (class 1255 OID 39786)

--

CREATE FUNCTION public.redeem_gift_code(p_code text) RETURNS public.gift_codes
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
DECLARE
  v_uid uuid;
  v_code text;
  v_gift public.gift_codes;
  v_entry_id bigint;
  v_memo text;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  v_code := upper(trim(coalesce(p_code, '')));
  IF v_code = '' THEN
    RAISE EXCEPTION 'missing_code';
  END IF;

  SELECT * INTO v_gift
  FROM public.gift_codes
  WHERE code = v_code
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'gift_code_not_found' USING errcode = 'P0002';
  END IF;

  IF v_gift.redeemed_at IS NOT NULL THEN
    RAISE EXCEPTION 'gift_code_already_redeemed';
  END IF;

  INSERT INTO public.wallet_accounts(user_id)
  VALUES (v_uid)
  ON CONFLICT (user_id) DO NOTHING;

  v_memo := coalesce(v_gift.memo, 'Gift code');

  UPDATE public.wallet_accounts
  SET balance_iqd = balance_iqd + v_gift.amount_iqd
  WHERE user_id = v_uid;

  INSERT INTO public.wallet_entries (user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
  VALUES (
    v_uid,
    v_gift.amount_iqd,
    'adjustment',
    v_memo,
    'gift_code',
    NULL,
    jsonb_build_object('code', v_code, 'amount_iqd', v_gift.amount_iqd),
    'gift_code:' || v_code
  )
  RETURNING id INTO v_entry_id;

  UPDATE public.gift_codes
  SET redeemed_by = v_uid,
      redeemed_at = now(),
      redeemed_entry_id = v_entry_id
  WHERE code = v_code
  RETURNING * INTO v_gift;

  RETURN v_gift;
END;
$$;


ALTER FUNCTION public.redeem_gift_code(p_code text) OWNER TO postgres;

--
-- TOC entry 1128 (class 1255 OID 40784)

--

CREATE FUNCTION public.referral_apply_code(p_code text) RETURNS TABLE(applied boolean, referrer_id uuid, campaign_key text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_uid uuid := (select auth.uid());
  v_code text := upper(trim(coalesce(p_code, '')));
  v_referrer uuid;
  v_campaign public.referral_campaigns%rowtype;
  v_existing uuid;
begin
  if v_uid is null then
    raise exception 'unauthorized';
  end if;
  if v_code = '' then
    raise exception 'invalid_code';
  end if;

  select user_id into v_referrer from public.referral_codes where code = v_code;
  if not found then
    raise exception 'code_not_found';
  end if;
  if v_referrer = v_uid then
    raise exception 'self_referral_not_allowed';
  end if;

  select * into v_campaign from public.referral_campaigns where key = 'default' and active;
  if not found then
    raise exception 'campaign_not_found';
  end if;

  select referred_id into v_existing from public.referral_redemptions where referred_id = v_uid;
  if found then
    -- already referred (idempotent)
    return query select false, v_referrer, v_campaign.key;
    return;
  end if;

  insert into public.referral_redemptions(campaign_id, referrer_id, referred_id, code, status)
  values (v_campaign.id, v_referrer, v_uid, v_code, 'pending');

  perform public.notify_user(v_uid, 'referral_applied', 'Referral applied', 'Referral code applied successfully.', jsonb_build_object('code', v_code));
  perform public.notify_user(v_referrer, 'referral_pending', 'New referral', 'A new user joined with your referral code.', jsonb_build_object('code', v_code, 'referred_id', v_uid));

  return query select true, v_referrer, v_campaign.key;
end;
$$;


ALTER FUNCTION public.referral_apply_code(p_code text) OWNER TO postgres;

--
-- TOC entry 1011 (class 1255 OID 41819)

--

CREATE FUNCTION public.referral_apply_rewards_for_ride(p_ride_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  r record;
  inv record;
  cfg record;
  v_rides int;
begin
  select * into r from public.rides where id = p_ride_id;
  if not found then
    return;
  end if;

  -- Find pending invite for rider
  select * into inv
  from public.referral_invites
  where referred_user_id = r.rider_id and status = 'pending'
  for update;

  if not found then
    return;
  end if;

  select * into cfg from public.referral_settings where id = 1;

  -- Check completed rides count for the referred user
  select count(*) into v_rides
  from public.rides
  where rider_id = r.rider_id and status = 'completed';

  if v_rides < cfg.min_completed_rides then
    return;
  end if;

  update public.referral_invites
  set status = 'qualified', qualified_at = now()
  where id = inv.id and status = 'pending';

  -- Credit referee
  insert into public.wallet_accounts(user_id) values (r.rider_id)
  on conflict (user_id) do nothing;

  update public.wallet_accounts
  set balance_iqd = balance_iqd + cfg.reward_referee_iqd,
      updated_at = now()
  where user_id = r.rider_id;

  insert into public.wallet_entries (user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
  values (
    r.rider_id, cfg.reward_referee_iqd, 'adjustment', 'Referral reward', 'referral', inv.id,
    jsonb_build_object('invite_id', inv.id, 'ride_id', p_ride_id, 'role', 'referee'),
    'referral:' || inv.id::text || ':referee'
  )
  on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

  -- Credit referrer
  insert into public.wallet_accounts(user_id) values (inv.referrer_id)
  on conflict (user_id) do nothing;

  update public.wallet_accounts
  set balance_iqd = balance_iqd + cfg.reward_referrer_iqd,
      updated_at = now()
  where user_id = inv.referrer_id;

  insert into public.wallet_entries (user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
  values (
    inv.referrer_id, cfg.reward_referrer_iqd, 'adjustment', 'Referral reward', 'referral', inv.id,
    jsonb_build_object('invite_id', inv.id, 'ride_id', p_ride_id, 'role', 'referrer'),
    'referral:' || inv.id::text || ':referrer'
  )
  on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

  update public.referral_invites
  set status = 'rewarded', rewarded_at = now()
  where id = inv.id and status in ('pending','qualified');

  perform public.notify_user(r.rider_id, 'referral_reward', 'Reward unlocked', 'Your referral reward has been added to your wallet', jsonb_build_object('amount_iqd', cfg.reward_referee_iqd, 'invite_id', inv.id));
  perform public.notify_user(inv.referrer_id, 'referral_reward', 'Reward unlocked', 'Your referral reward has been added to your wallet', jsonb_build_object('amount_iqd', cfg.reward_referrer_iqd, 'invite_id', inv.id));
end;
$$;


ALTER FUNCTION public.referral_apply_rewards_for_ride(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 685 (class 1255 OID 41817)

--

CREATE FUNCTION public.referral_claim(p_code text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v_uid uuid;
  v_referrer uuid;
  v_exists uuid;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  select user_id into v_referrer
  from public.referral_codes
  where code = upper(p_code);

  if not found then
    raise exception 'invalid_code';
  end if;

  if v_referrer = v_uid then
    raise exception 'cannot_self_refer';
  end if;

  select id into v_exists
  from public.referral_invites
  where referred_user_id = v_uid;

  if found then
    raise exception 'already_claimed';
  end if;

  insert into public.referral_invites (referrer_id, referred_user_id, code_used, status)
  values (v_referrer, v_uid, upper(p_code), 'pending');

  perform public.notify_user(v_referrer, 'referral_new', 'New referral', 'A new user joined using your code', jsonb_build_object('referred_user_id', v_uid));
  perform public.notify_user(v_uid, 'referral_applied', 'Referral applied', 'Complete your first ride to unlock your reward', jsonb_build_object('referrer_id', v_referrer));

  return jsonb_build_object('ok', true, 'referrer_id', v_referrer);
end;
$$;


ALTER FUNCTION public.referral_claim(p_code text) OWNER TO postgres;

--
-- TOC entry 1261 (class 1255 OID 41815)

--

CREATE FUNCTION public.referral_code_init() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
begin
  insert into public.referral_codes (user_id, code)
  values (new.id, public.referral_generate_code())
  on conflict (user_id) do nothing;
  return new;
end;
$$;


ALTER FUNCTION public.referral_code_init() OWNER TO postgres;

--
-- TOC entry 1050 (class 1255 OID 41814)

--

CREATE FUNCTION public.referral_generate_code() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v text;
begin
  loop
    v := upper(regexp_replace(substr(encode(gen_random_bytes(12),'base64'), 1, 12), '[^A-Z0-9]', '', 'g'));
    v := substr(v, 1, 8);
    exit when length(v) = 8 and not exists (select 1 from public.referral_codes where code = v);
  end loop;
  return v;
end;
$$;


ALTER FUNCTION public.referral_generate_code() OWNER TO postgres;

--
-- TOC entry 861 (class 1255 OID 41820)

--

CREATE FUNCTION public.referral_on_ride_completed() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
begin
  if (tg_op = 'UPDATE') and new.status = 'completed' and old.status is distinct from new.status then
    perform public.referral_apply_rewards_for_ride(new.id);
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.referral_on_ride_completed() OWNER TO postgres;

--
-- TOC entry 750 (class 1255 OID 41818)

--

CREATE FUNCTION public.referral_status() RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v_uid uuid;
  v_code text;
  v_pending int;
  v_rewarded int;
  v_earned bigint;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  select code into v_code
  from public.referral_codes
  where user_id = v_uid;

  select count(*) into v_pending
  from public.referral_invites
  where referrer_id = v_uid and status in ('pending','qualified');

  select count(*) into v_rewarded
  from public.referral_invites
  where referrer_id = v_uid and status = 'rewarded';

  select coalesce(sum(delta_iqd),0) into v_earned
  from public.wallet_entries
  where user_id = v_uid and source_type = 'referral';

  return jsonb_build_object(
    'code', v_code,
    'pending', v_pending,
    'rewarded', v_rewarded,
    'earned_iqd', v_earned
  );
end;
$$;


ALTER FUNCTION public.referral_status() OWNER TO postgres;

--
-- TOC entry 770 (class 1255 OID 40679)

--

CREATE FUNCTION public.refresh_driver_rank_snapshots(p_period text, p_period_start date, p_limit integer DEFAULT 200) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_period text := lower(coalesce(p_period, 'weekly'));
  v_start date := p_period_start;
  v_end date;
  v_limit integer := greatest(1, least(coalesce(p_limit, 200), 1000));
begin
  if v_period not in ('weekly','monthly') then
    raise exception 'invalid_period';
  end if;

  if v_start is null then
    raise exception 'period_start_required';
  end if;

  if v_period = 'weekly' then
    v_end := (v_start + interval '7 days')::date;
  else
    v_end := (date_trunc('month', v_start::timestamptz) + interval '1 month')::date;
  end if;

  delete from public.driver_rank_snapshots
  where period = v_period and period_start = v_start;

  insert into public.driver_rank_snapshots(period, period_start, period_end, driver_id, rank, score_iqd, rides_completed)
  select
    v_period,
    v_start,
    v_end,
    s.driver_id,
    row_number() over (order by s.earnings_iqd desc, s.rides_completed desc, s.driver_id)::int as rank,
    s.earnings_iqd,
    s.rides_completed
  from (
    select dsd.driver_id,
           sum(dsd.earnings_iqd)::bigint as earnings_iqd,
           sum(dsd.rides_completed)::int as rides_completed
    from public.driver_stats_daily dsd
    where dsd.day >= v_start and dsd.day < v_end
    group by dsd.driver_id
  ) s
  order by s.earnings_iqd desc, s.rides_completed desc, s.driver_id
  limit v_limit;
end;
$$;


ALTER FUNCTION public.refresh_driver_rank_snapshots(p_period text, p_period_start date, p_limit integer) OWNER TO postgres;

--
-- TOC entry 887 (class 1255 OID 43608)

--

CREATE FUNCTION public.resolve_service_area(p_lat double precision, p_lng double precision) RETURNS TABLE(id uuid, name text, governorate text, pricing_config_id uuid)
    LANGUAGE sql STABLE
    SET search_path TO 'pg_catalog, extensions, public'
    AS $$
  SELECT sa.id, sa.name, sa.governorate, sa.pricing_config_id
  FROM public.service_areas sa
  WHERE sa.is_active
    AND extensions.ST_Contains(sa.geom, extensions.ST_SetSRID(extensions.ST_Point(p_lng, p_lat), 4326))
  ORDER BY sa.priority DESC, sa.created_at DESC
  LIMIT 1;
$$;


ALTER FUNCTION public.resolve_service_area(p_lat double precision, p_lng double precision) OWNER TO postgres;

--
-- TOC entry 1068 (class 1255 OID 40987)

--

CREATE FUNCTION public.revoke_trip_share_tokens_on_ride_end() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
begin
  if new.status in ('completed', 'canceled') then
    update public.trip_share_tokens
       set revoked_at = now()
     where ride_id = new.id
       and revoked_at is null;
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.revoke_trip_share_tokens_on_ride_end() OWNER TO postgres;

--
-- TOC entry 1270 (class 1255 OID 41774)

--

CREATE FUNCTION public.ride_chat_get_or_create_thread(p_ride_id uuid) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v_uid uuid;
  r record;
  v_thread uuid;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  select id, rider_id, driver_id into r
  from public.rides
  where id = p_ride_id
    and (rider_id = v_uid or driver_id = v_uid);

  if not found then
    raise exception 'not_a_participant';
  end if;

  insert into public.ride_chat_threads (ride_id, rider_id, driver_id)
  values (p_ride_id, r.rider_id, r.driver_id)
  on conflict (ride_id) do update
    set updated_at = now()
  returning id into v_thread;

  return v_thread;
end;
$$;


ALTER FUNCTION public.ride_chat_get_or_create_thread(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 1097 (class 1255 OID 41775)

--

CREATE FUNCTION public.ride_chat_notify_on_message() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  t record;
  v_to uuid;
begin
  select ride_id, rider_id, driver_id into t
  from public.ride_chat_threads
  where id = new.thread_id;

  if not found then
    return new;
  end if;

  if new.sender_id = t.rider_id then
    v_to := t.driver_id;
  else
    v_to := t.rider_id;
  end if;

  perform public.notify_user(
    v_to,
    'chat_message',
    'New message',
    case when new.kind = 'text' then left(coalesce(new.body,''), 140) else 'Attachment' end,
    jsonb_build_object('ride_id', t.ride_id, 'thread_id', new.thread_id, 'message_id', new.id)
  );

  return new;
end;
$$;


ALTER FUNCTION public.ride_chat_notify_on_message() OWNER TO postgres;

--
-- TOC entry 1339 (class 1255 OID 39787)

--

CREATE FUNCTION public.ride_requests_clear_match_fields() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
begin
  if tg_op = 'UPDATE' then
    if new.status in ('cancelled','expired','no_driver') then
      new.assigned_driver_id := null;
      new.match_deadline := null;
    end if;
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.ride_requests_clear_match_fields() OWNER TO postgres;

--
-- TOC entry 1090 (class 1255 OID 39788)

--

CREATE FUNCTION public.ride_requests_release_driver_on_unmatch() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
begin
  if tg_op = 'UPDATE' then
    if old.status = 'matched'
       and new.status in ('cancelled','expired','no_driver')
       and old.assigned_driver_id is not null then
      update public.drivers
        set status = 'available'
      where id = old.assigned_driver_id
        and status in ('reserved', 'assigned');
    end if;
  end if;
  return null;
end;
$$;


ALTER FUNCTION public.ride_requests_release_driver_on_unmatch() OWNER TO postgres;

--
-- TOC entry 1307 (class 1255 OID 39789)

--

CREATE FUNCTION public.ride_requests_set_quote() RETURNS trigger
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


ALTER FUNCTION public.ride_requests_set_quote() OWNER TO postgres;

--
-- TOC entry 804 (class 1255 OID 39790)

--

CREATE FUNCTION public.ride_requests_set_status_timestamps() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
begin
  if tg_op = 'UPDATE' then
    if new.status = 'matched' and old.status = 'requested' and new.matched_at is null then
      new.matched_at := now();
    end if;

    if new.status = 'accepted' and old.status = 'matched' and new.accepted_at is null then
      new.accepted_at := now();
    end if;

    if new.status = 'cancelled' and old.status in ('requested','matched') and new.cancelled_at is null then
      new.cancelled_at := now();
    end if;
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.ride_requests_set_status_timestamps() OWNER TO postgres;

--
-- TOC entry 1333 (class 1255 OID 43879)

--

CREATE FUNCTION public.ridecheck_open_event_v1(p_ride_id uuid, p_kind text, p_metadata jsonb) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.ridecheck_open_event_v1(p_ride_id uuid, p_kind text, p_metadata jsonb) OWNER TO postgres;

--
-- TOC entry 630 (class 1255 OID 43880)

--

CREATE FUNCTION public.ridecheck_run_v1() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.ridecheck_run_v1() OWNER TO postgres;

--
-- TOC entry 671 (class 1255 OID 43575)

--

CREATE FUNCTION public.scheduled_rides_execute_due(p_limit integer DEFAULT 50) RETURNS integer
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public'
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


ALTER FUNCTION public.scheduled_rides_execute_due(p_limit integer) OWNER TO postgres;

--
-- TOC entry 903 (class 1255 OID 43609)

--

CREATE FUNCTION public.set_service_area_id_from_pickup() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public'
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


ALTER FUNCTION public.set_service_area_id_from_pickup() OWNER TO postgres;

--
-- TOC entry 678 (class 1255 OID 39791)

--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

--
-- TOC entry 1008 (class 1255 OID 39792)

--

CREATE FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    SET search_path TO 'pg_catalog, public, extensions'
    AS $_$
  SELECT extensions.st_dwithin($1, $2, $3::double precision);
$_$;


ALTER FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) OWNER TO postgres;

--
-- TOC entry 853 (class 1255 OID 39793)

--

CREATE FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_uid uuid;
  v_ride public.rides%rowtype;
  v_rater_role public.party_role;
  v_ratee_role public.party_role;
  v_ratee_id uuid;
  v_rating_id uuid;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  select * into v_ride
  from public.rides
  where id = p_ride_id
    and status = 'completed'
    and (rider_id = v_uid or driver_id = v_uid);

  if not found then
    raise exception 'not_allowed';
  end if;

  if v_ride.rider_id = v_uid then
    v_rater_role := 'rider';
    v_ratee_role := 'driver';
    v_ratee_id := v_ride.driver_id;
  else
    v_rater_role := 'driver';
    v_ratee_role := 'rider';
    v_ratee_id := v_ride.rider_id;
  end if;

  insert into public.ride_ratings (ride_id, rater_id, ratee_id, rater_role, ratee_role, rating, comment)
  values (p_ride_id, v_uid, v_ratee_id, v_rater_role, v_ratee_role, p_rating, p_comment)
  on conflict (ride_id, rater_id) do nothing;

  select id into v_rating_id
  from public.ride_ratings
  where ride_id = p_ride_id and rater_id = v_uid;

  return v_rating_id;
end;
$$;


ALTER FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) OWNER TO postgres;

--
-- TOC entry 734 (class 1255 OID 40888)

--

CREATE FUNCTION public.support_ticket_touch_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
begin
  update public.support_tickets
     set updated_at = now()
   where id = new.ticket_id;
  return new;
end;
$$;


ALTER FUNCTION public.support_ticket_touch_updated_at() OWNER TO postgres;

--
-- TOC entry 809 (class 1255 OID 41428)

--

CREATE FUNCTION public.sync_profile_kyc_from_submission() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public, auth, extensions'
    AS $$
declare
  v_user uuid;
  v_new public.kyc_status;
begin
  v_user := coalesce(new.profile_id, new.user_id);

  if new.status in ('submitted','in_review') then
    v_new := 'pending';
  elsif new.status = 'approved' then
    v_new := 'verified';
  elsif new.status in ('rejected','resubmit_required') then
    v_new := 'rejected';
  else
    v_new := 'unverified';
  end if;

  insert into public.profile_kyc (user_id, status, updated_at)
  values (v_user, v_new, now())
  on conflict (user_id) do update
    set status = excluded.status,
        updated_at = excluded.updated_at;

  return new;
end;
$$;


ALTER FUNCTION public.sync_profile_kyc_from_submission() OWNER TO postgres;

--
-- TOC entry 976 (class 1255 OID 40579)

--

CREATE FUNCTION public.sync_public_profile() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
begin
  insert into public.public_profiles(id, display_name, rating_avg, rating_count, created_at, updated_at)
  values (
    new.id,
    new.display_name,
    coalesce(new.rating_avg, 5.00),
    coalesce(new.rating_count, 0),
    coalesce(new.created_at, now()),
    now()
  )
  on conflict (id) do update
    set display_name = excluded.display_name,
        rating_avg = excluded.rating_avg,
        rating_count = excluded.rating_count,
        updated_at = now();

  return new;
end;
$$;


ALTER FUNCTION public.sync_public_profile() OWNER TO postgres;

--
-- TOC entry 622 (class 1255 OID 43923)

--

CREATE FUNCTION public.tg__set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public'
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.tg__set_updated_at() OWNER TO postgres;

--
-- TOC entry 411 (class 1259 OID 39794)

--

CREATE TABLE public.rides (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    request_id uuid NOT NULL,
    rider_id uuid DEFAULT auth.uid() NOT NULL,
    driver_id uuid NOT NULL,
    status public.ride_status DEFAULT 'assigned'::public.ride_status NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    fare_amount_iqd integer,
    currency text DEFAULT 'IQD'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    paid_at timestamp with time zone,
    payment_intent_id uuid,
    wallet_hold_id uuid,
    product_code text DEFAULT 'standard'::text NOT NULL,
    pickup_pin_required boolean DEFAULT false NOT NULL,
    pickup_pin_verified_at timestamp with time zone,
    pickup_pin_fail_count integer DEFAULT 0 NOT NULL,
    pickup_pin_locked_until timestamp with time zone,
    pickup_pin_last_attempt_at timestamp with time zone
);

ALTER TABLE ONLY public.rides REPLICA IDENTITY FULL;


ALTER TABLE public.rides OWNER TO postgres;

--
-- TOC entry 525 (class 1255 OID 39806)

--

CREATE FUNCTION public.transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer) RETURNS public.rides
    LANGUAGE plpgsql SECURITY DEFINER
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


ALTER FUNCTION public.transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer) OWNER TO postgres;

--
-- TOC entry 1299 (class 1255 OID 44008)

--

CREATE FUNCTION public.trusted_contact_outbox_claim(p_limit integer DEFAULT 50) RETURNS TABLE(id uuid, user_id uuid, contact_id uuid, sos_event_id uuid, ride_id uuid, channel text, to_phone text, payload jsonb, attempts integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
BEGIN
  RETURN QUERY
  WITH picked AS (
    SELECT o.id
    FROM public.trusted_contact_outbox o
    WHERE (
      (o.status = 'pending' AND o.next_attempt_at <= now())
      OR
      (o.status = 'processing' AND o.last_attempt_at < now() - interval '15 minutes')
    )
    ORDER BY o.created_at ASC
    LIMIT greatest(1, least(coalesce(p_limit, 50), 200))
    FOR UPDATE SKIP LOCKED
  )
  UPDATE public.trusted_contact_outbox o
    SET status = 'processing',
        attempts = o.attempts + 1,
        last_attempt_at = now(),
        updated_at = now()
  WHERE o.id IN (SELECT id FROM picked)
  RETURNING o.id, o.user_id, o.contact_id, o.sos_event_id, o.ride_id, o.channel, o.to_phone, o.payload, o.attempts;
END;
$$;


ALTER FUNCTION public.trusted_contact_outbox_claim(p_limit integer) OWNER TO postgres;

--
-- TOC entry 1214 (class 1255 OID 44009)

--

CREATE FUNCTION public.trusted_contact_outbox_mark(p_outbox_id uuid, p_status text, p_error text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
DECLARE
  v_status text := lower(coalesce(p_status, 'failed'));
BEGIN
  IF v_status NOT IN ('sent','failed','skipped') THEN
    RAISE EXCEPTION 'invalid_status';
  END IF;

  UPDATE public.trusted_contact_outbox
    SET status = v_status,
        last_error = CASE WHEN v_status IN ('failed','skipped') THEN left(coalesce(p_error,''), 1000) ELSE NULL END,
        updated_at = now()
  WHERE id = p_outbox_id;
END;
$$;


ALTER FUNCTION public.trusted_contact_outbox_mark(p_outbox_id uuid, p_status text, p_error text) OWNER TO postgres;

--
-- TOC entry 521 (class 1255 OID 44011)

--

CREATE FUNCTION public.trusted_contact_outbox_mark_v2(p_outbox_id uuid, p_result text, p_error text DEFAULT NULL::text, p_retry_in_seconds integer DEFAULT NULL::integer, p_http_status integer DEFAULT NULL::integer, p_provider_message_id text DEFAULT NULL::text, p_response text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
DECLARE
  v_result text := lower(coalesce(p_result, 'failed'));
  v_retry_seconds integer := greatest(10, least(coalesce(p_retry_in_seconds, 60), 86400)); -- 10s..24h
  v_attempts integer;
  v_max_attempts integer := 8;
BEGIN
  IF v_result NOT IN ('sent','retry','failed','skipped') THEN
    RAISE EXCEPTION 'invalid_result';
  END IF;

  SELECT attempts INTO v_attempts FROM public.trusted_contact_outbox WHERE id = p_outbox_id;

  IF v_attempts IS NULL THEN
    RETURN;
  END IF;

  IF v_result = 'sent' THEN
    UPDATE public.trusted_contact_outbox
      SET status = 'sent',
          last_error = NULL,
          last_http_status = p_http_status,
          provider_message_id = left(coalesce(p_provider_message_id,''), 200),
          last_response = left(coalesce(p_response,''), 1000),
          updated_at = now()
    WHERE id = p_outbox_id;
    RETURN;
  END IF;

  IF v_result = 'skipped' THEN
    UPDATE public.trusted_contact_outbox
      SET status = 'skipped',
          last_error = left(coalesce(p_error,''), 1000),
          last_http_status = p_http_status,
          last_response = left(coalesce(p_response,''), 1000),
          updated_at = now()
    WHERE id = p_outbox_id;
    RETURN;
  END IF;

  -- retry/failure
  IF v_result = 'retry' AND v_attempts < v_max_attempts THEN
    UPDATE public.trusted_contact_outbox
      SET status = 'pending',
          next_attempt_at = now() + make_interval(secs => v_retry_seconds),
          last_error = left(coalesce(p_error,''), 1000),
          last_http_status = p_http_status,
          last_response = left(coalesce(p_response,''), 1000),
          updated_at = now()
    WHERE id = p_outbox_id;
    RETURN;
  END IF;

  -- permanent failure or exceeded max retries
  UPDATE public.trusted_contact_outbox
    SET status = 'failed',
        last_error = left(coalesce(p_error,''), 1000),
        last_http_status = p_http_status,
        last_response = left(coalesce(p_response,''), 1000),
        updated_at = now()
  WHERE id = p_outbox_id;
END;
$$;


ALTER FUNCTION public.trusted_contact_outbox_mark_v2(p_outbox_id uuid, p_result text, p_error text, p_retry_in_seconds integer, p_http_status integer, p_provider_message_id text, p_response text) OWNER TO postgres;

--
-- TOC entry 578 (class 1255 OID 43796)

--

CREATE FUNCTION public.trusted_contacts_enforce_active_limit() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public'
    AS $$
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


ALTER FUNCTION public.trusted_contacts_enforce_active_limit() OWNER TO postgres;

--
-- TOC entry 1442 (class 1255 OID 39807)

--

CREATE FUNCTION public.try_get_vault_secret(p_name text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v text;
begin
  begin
    execute format('select decrypted_secret from vault.decrypted_secrets where name = %L limit 1', p_name)
      into v;
  exception when undefined_table or invalid_schema_name then
    return null;
  end;
  return v;
end;
$$;


ALTER FUNCTION public.try_get_vault_secret(p_name text) OWNER TO postgres;

--
-- TOC entry 620 (class 1255 OID 40720)

--

CREATE FUNCTION public.update_driver_achievements(p_driver_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v record;
  v_cnt bigint;
begin
  select completed_rides into v_cnt
  from public.driver_counters
  where driver_id = p_driver_id;

  if v_cnt is null then
    v_cnt := 0;
  end if;

  for v in
    select a.id, a.target
    from public.achievements a
    where a.active and a.role = 'driver' and a.metric = 'completed_rides'
    order by a.sort_order
  loop
    insert into public.achievement_progress(user_id, achievement_id, progress, completed_at, updated_at)
    values (
      p_driver_id,
      v.id,
      least(v_cnt, v.target),
      case when v_cnt >= v.target then now() else null end,
      now()
    )
    on conflict (user_id, achievement_id) do update
      set progress = greatest(achievement_progress.progress, least(v_cnt, v.target)),
          completed_at = case
            when achievement_progress.completed_at is not null then achievement_progress.completed_at
            when v_cnt >= v.target then now()
            else null
          end,
          updated_at = now();
  end loop;
end;
$$;


ALTER FUNCTION public.update_driver_achievements(p_driver_id uuid) OWNER TO postgres;

--
-- TOC entry 1289 (class 1255 OID 39808)

--

CREATE FUNCTION public.update_receipt_on_refund() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_total integer;
  v_refund integer;
begin
  -- Only act when a refund is recorded/updated
  if new.refunded_at is null and new.provider_refund_id is null then
    return new;
  end if;

  select rr.total_iqd into v_total
  from public.ride_receipts rr
  where rr.ride_id = new.ride_id;

  if v_total is null then
    return new;
  end if;

  v_refund := greatest(coalesce(new.refund_amount_iqd, 0), 0);

  update public.ride_receipts
  set
    refunded_iqd = greatest(refunded_iqd, v_refund),
    refunded_at = coalesce(new.refunded_at, refunded_at, now()),
    receipt_status = case
      when v_refund >= v_total then 'refunded'
      when v_refund > 0 then 'partially_refunded'
      else receipt_status
    end
  where ride_id = new.ride_id;

  return new;
end;
$$;


ALTER FUNCTION public.update_receipt_on_refund() OWNER TO postgres;

--
-- TOC entry 702 (class 1255 OID 40606)

--

CREATE FUNCTION public.upsert_device_token(p_token text, p_platform text DEFAULT 'android'::text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_user uuid := (select auth.uid());
  v_id bigint;
  v_platform text := lower(coalesce(nullif(trim(p_platform), ''), 'android'));
  v_token text := trim(coalesce(p_token, ''));
begin
  if v_user is null then
    raise exception 'unauthorized';
  end if;

  if length(v_token) < 10 then
    raise exception 'invalid_token';
  end if;

  if v_platform not in ('android','ios','web') then
    raise exception 'invalid_platform';
  end if;

  insert into public.device_tokens(user_id, token, platform, created_at, last_seen_at)
  values (v_user, v_token, v_platform, now(), now())
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        last_seen_at = now(),
        disabled_at = null
  returning id into v_id;

  return v_id;
end;
$$;


ALTER FUNCTION public.upsert_device_token(p_token text, p_platform text) OWNER TO postgres;

--
-- TOC entry 1099 (class 1255 OID 39809)

--

CREATE FUNCTION public.user_notifications_mark_all_read() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
DECLARE
  v_uid uuid;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  UPDATE public.user_notifications
  SET read_at = COALESCE(read_at, now())
  WHERE user_id = v_uid AND read_at IS NULL;
END;
$$;


ALTER FUNCTION public.user_notifications_mark_all_read() OWNER TO postgres;

--
-- TOC entry 611 (class 1255 OID 39810)

--

CREATE FUNCTION public.user_notifications_mark_read(p_notification_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
DECLARE
  v_uid uuid;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  UPDATE public.user_notifications
  SET read_at = COALESCE(read_at, now())
  WHERE id = p_notification_id AND user_id = v_uid;
END;
$$;


ALTER FUNCTION public.user_notifications_mark_read(p_notification_id uuid) OWNER TO postgres;

--
-- TOC entry 1151 (class 1255 OID 39811)

--

CREATE FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
DECLARE
  v_uid uuid;
  r record;
  h record;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  SELECT * INTO r
  FROM public.wallet_withdraw_requests
  WHERE id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'withdraw_request_not_found';
  END IF;

  IF r.user_id <> v_uid THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  IF r.status <> 'requested' THEN
    RAISE EXCEPTION 'withdraw_not_cancellable';
  END IF;

  SELECT * INTO h
  FROM public.wallet_holds
  WHERE withdraw_request_id = r.id AND status = 'active'
  ORDER BY created_at DESC
  LIMIT 1
  FOR UPDATE;

  UPDATE public.wallet_holds
  SET status = 'released', released_at = now(), updated_at = now()
  WHERE id = h.id AND status = 'active';

  UPDATE public.wallet_accounts
  SET held_iqd = GREATEST(held_iqd - r.amount_iqd, 0),
      updated_at = now()
  WHERE user_id = v_uid;

  UPDATE public.wallet_withdraw_requests
  SET status = 'cancelled', cancelled_at = now(), updated_at = now()
  WHERE id = r.id;

  PERFORM public.notify_user(v_uid, 'withdraw_cancelled', 'Withdrawal cancelled',
    'Your withdrawal request was cancelled and funds were released.',
    jsonb_build_object('request_id', r.id, 'amount_iqd', r.amount_iqd, 'payout_kind', r.payout_kind)
  );
END;
$$;


ALTER FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) OWNER TO postgres;

--
-- TOC entry 1181 (class 1255 OID 39812)

--

CREATE FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions, public'
    AS $$
declare
  r record;
  h record;
  v_amount bigint;
  v_balance bigint;
  v_held bigint;
begin
  -- Lock ride
  select * into r
  from public.rides
  where id = p_ride_id
  for update;

  if not found then
    raise exception 'ride_not_found';
  end if;

  -- Lock hold
  select * into h
  from public.wallet_holds
  where ride_id = p_ride_id
  for update;

  if not found then
    raise exception 'hold_not_found';
  end if;

  if h.status = 'captured' then
    return; -- idempotent
  end if;

  if h.status <> 'active' then
    raise exception 'hold_not_active';
  end if;

  v_amount := h.amount_iqd;
  if v_amount <= 0 then
    raise exception 'invalid_amount';
  end if;

  -- Validate wallet state
  select balance_iqd, held_iqd
    into v_balance, v_held
  from public.wallet_accounts
  where user_id = r.rider_id
  for update;

  if not found then
    raise exception 'wallet_missing';
  end if;

  if coalesce(v_held,0) < v_amount then
    raise exception 'wallet_insufficient_held';
  end if;

  if coalesce(v_balance,0) < v_amount then
    raise exception 'wallet_insufficient_balance';
  end if;

  -- Debit rider
  update public.wallet_accounts
    set held_iqd = held_iqd - v_amount,
        balance_iqd = balance_iqd - v_amount,
        updated_at = now()
  where user_id = r.rider_id;

  insert into public.wallet_entries (
    user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key
  )
  values (
    r.rider_id, -v_amount, 'ride_fare', 'Ride fare', 'ride', r.id,
    jsonb_build_object('ride_id', r.id, 'driver_id', r.driver_id),
    'ride:' || r.id::text || ':rider_debit'
  )
  on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

  -- Credit driver
  insert into public.wallet_accounts(user_id)
  values (r.driver_id)
  on conflict (user_id) do nothing;

  update public.wallet_accounts
    set balance_iqd = balance_iqd + v_amount,
        updated_at = now()
  where user_id = r.driver_id;

  insert into public.wallet_entries (
    user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key
  )
  values (
    r.driver_id, v_amount, 'ride_fare', 'Ride payout', 'ride', r.id,
    jsonb_build_object('ride_id', r.id, 'rider_id', r.rider_id),
    'ride:' || r.id::text || ':driver_credit'
  )
  on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

  -- Mark hold captured
  update public.wallet_holds
    set status = 'captured', captured_at = now(), updated_at = now()
  where id = h.id and status = 'active';

  -- Synthetic payment row (requires partial unique index on payments(ride_id) where status='succeeded')
  insert into public.payments (ride_id, provider, provider_ref, amount_iqd, currency, status)
  values (r.id, 'wallet', h.id::text, v_amount::integer, 'IQD', 'succeeded')
  on conflict (ride_id) where status = 'succeeded' do nothing;

  update public.rides
    set paid_at = coalesce(paid_at, now()),
        payment_intent_id = null
  where id = r.id;
end;
$$;


ALTER FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 412 (class 1259 OID 39813)

--

CREATE TABLE public.topup_intents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    provider_code text NOT NULL,
    package_id uuid,
    amount_iqd bigint NOT NULL,
    bonus_iqd bigint DEFAULT 0 NOT NULL,
    status public.topup_status DEFAULT 'created'::public.topup_status NOT NULL,
    idempotency_key text,
    provider_tx_id text,
    provider_payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    failure_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    CONSTRAINT topup_intents_amount_iqd_check CHECK ((amount_iqd > 0)),
    CONSTRAINT topup_intents_bonus_iqd_check CHECK ((bonus_iqd >= 0))
);

ALTER TABLE ONLY public.topup_intents REPLICA IDENTITY FULL;


ALTER TABLE public.topup_intents OWNER TO postgres;

--
-- TOC entry 902 (class 1255 OID 39826)

--

CREATE FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb DEFAULT '{}'::jsonb) RETURNS public.topup_intents
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
DECLARE
  v_intent public.topup_intents;
BEGIN
  SELECT * INTO v_intent
  FROM public.topup_intents
  WHERE id = p_intent_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'topup_intent_not_found' USING ERRCODE = 'P0002';
  END IF;

  IF v_intent.status IN ('failed','succeeded') THEN
    RETURN v_intent;
  END IF;

  UPDATE public.topup_intents
  SET
    status = 'failed',
    failure_reason = p_failure_reason,
    provider_payload = COALESCE(p_provider_payload, provider_payload),
    completed_at = now(),
    updated_at = now()
  WHERE id = p_intent_id;

  RETURN (SELECT ti FROM public.topup_intents ti WHERE ti.id = p_intent_id);
END;
$$;


ALTER FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) OWNER TO postgres;

--
-- TOC entry 1053 (class 1255 OID 39827)

--

CREATE FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb DEFAULT '{}'::jsonb) RETURNS public.topup_intents
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_intent public.topup_intents;
  v_total_iqd bigint;
begin
  select * into v_intent
  from public.topup_intents
  where id = p_intent_id
  for update;

  if not found then
    raise exception 'topup_intent_not_found' using errcode = 'P0002';
  end if;

  if v_intent.status = 'succeeded' then
    return v_intent;
  end if;

  v_total_iqd := v_intent.amount_iqd + v_intent.bonus_iqd;

  update public.topup_intents
  set
    status = 'succeeded',
    provider_tx_id = coalesce(p_provider_tx_id, provider_tx_id),
    provider_payload = coalesce(p_provider_payload, provider_payload),
    completed_at = now(),
    updated_at = now()
  where id = p_intent_id;

  insert into public.wallet_accounts(user_id)
  values (v_intent.user_id)
  on conflict (user_id) do nothing;

  update public.wallet_accounts
  set
    balance_iqd = balance_iqd + v_total_iqd,
    updated_at = now()
  where user_id = v_intent.user_id;

  insert into public.wallet_entries(
    user_id,
    kind,
    delta_iqd,
    memo,
    source_type,
    source_id,
    metadata,
    idempotency_key
  )
  values (
    v_intent.user_id,
    'topup',
    v_total_iqd,
    'Top-up',
    'topup_intent',
    v_intent.id,
    jsonb_build_object('provider', v_intent.provider_code, 'provider_tx_id', p_provider_tx_id),
    'topup:' || v_intent.id::text
  )
  on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

  return (select ti from public.topup_intents ti where ti.id = p_intent_id);
end;
$$;


ALTER FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) OWNER TO postgres;

--
-- TOC entry 413 (class 1259 OID 39828)

--

CREATE TABLE public.wallet_accounts (
    user_id uuid NOT NULL,
    balance_iqd bigint DEFAULT 0 NOT NULL,
    held_iqd bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT wallet_accounts_balance_iqd_check CHECK ((balance_iqd >= 0)),
    CONSTRAINT wallet_accounts_held_iqd_check CHECK ((held_iqd >= 0))
);


ALTER TABLE public.wallet_accounts OWNER TO postgres;

--
-- TOC entry 946 (class 1255 OID 39837)

--

CREATE FUNCTION public.wallet_get_my_account() RETURNS public.wallet_accounts
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  v_user uuid;
  r public.wallet_accounts;
begin
  v_user := auth.uid();
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select * into r
  from public.wallet_accounts
  where user_id = v_user;

  if not found then
    insert into public.wallet_accounts (user_id, balance_iqd)
    values (v_user, 0)
    returning * into r;
  end if;

  return r;
end;
$$;


ALTER FUNCTION public.wallet_get_my_account() OWNER TO postgres;

--
-- TOC entry 878 (class 1255 OID 39838)

--

CREATE FUNCTION public.wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  v_hold_id uuid;
  v_balance bigint;
  v_held bigint;
  v_available bigint;
  v_inserted boolean := false;
begin
  if p_amount_iqd <= 0 then
    raise exception 'invalid_amount';
  end if;

  -- Ensure wallet exists
  insert into public.wallet_accounts(user_id)
  values (p_user_id)
  on conflict (user_id) do nothing;

  -- Lock wallet row
  select balance_iqd, held_iqd
    into v_balance, v_held
  from public.wallet_accounts
  where user_id = p_user_id
  for update;

  v_available := coalesce(v_balance,0) - coalesce(v_held,0);
  if v_available < p_amount_iqd then
    raise exception 'insufficient_wallet_balance';
  end if;

  -- If already active hold exists, return it.
  select id into v_hold_id
  from public.wallet_holds
  where ride_id = p_ride_id and status = 'active'
  for update;

  if v_hold_id is null then
    begin
      insert into public.wallet_holds(user_id, ride_id, amount_iqd, status)
      values (p_user_id, p_ride_id, p_amount_iqd, 'active')
      returning id into v_hold_id;
      v_inserted := true;
    exception when unique_violation then
      select id into v_hold_id
      from public.wallet_holds
      where ride_id = p_ride_id and status = 'active'
      for update;
      v_inserted := false;
    end;
  end if;

  -- Only adjust held_iqd when we created the hold.
  if v_inserted then
    update public.wallet_accounts
      set held_iqd = held_iqd + p_amount_iqd,
          updated_at = now()
    where user_id = p_user_id;

    update public.rides
      set wallet_hold_id = v_hold_id
    where id = p_ride_id;
  end if;

  return v_hold_id;
end;
$$;


ALTER FUNCTION public.wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint) OWNER TO postgres;

--
-- TOC entry 720 (class 1255 OID 44233)

--

CREATE FUNCTION public.wallet_holds_normalize_status() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
BEGIN
  IF NEW.status = 'held' THEN
    NEW.status := 'active';
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.wallet_holds_normalize_status() OWNER TO postgres;

--
-- TOC entry 854 (class 1255 OID 39839)

--

CREATE FUNCTION public.wallet_release_ride_hold(p_ride_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  h record;
begin
  select * into h
  from public.wallet_holds
  where ride_id = p_ride_id and status = 'active'
  for update;

  if not found then
    return;
  end if;

  update public.wallet_holds
    set status = 'released', released_at = now(), updated_at = now()
  where id = h.id and status = 'active';

  update public.wallet_accounts
    set held_iqd = greatest(0, held_iqd - h.amount_iqd),
        updated_at = now()
  where user_id = h.user_id;
end;
$$;


ALTER FUNCTION public.wallet_release_ride_hold(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 1258 (class 1255 OID 39840)

--

CREATE FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb DEFAULT '{}'::jsonb, p_idempotency_key text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
DECLARE
  v_uid uuid;
  v_req_id uuid;
  v_available bigint;
  v_policy record;
  v_today date;
  v_day_sum bigint;
  v_day_count integer;
  v_driver record;
  v_kyc public.kyc_status;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  -- payout method enabled?
  IF NOT EXISTS (
    SELECT 1 FROM public.wallet_withdraw_payout_methods m
    WHERE m.payout_kind = p_payout_kind AND m.enabled = true
  ) THEN
    RAISE EXCEPTION 'payout_method_disabled';
  END IF;

  -- policy (single row)
  SELECT * INTO v_policy FROM public.wallet_withdrawal_policy WHERE id = 1;

  IF p_amount_iqd IS NULL OR p_amount_iqd <= 0 THEN
    RAISE EXCEPTION 'invalid_amount';
  END IF;
  IF p_amount_iqd < v_policy.min_amount_iqd THEN
    RAISE EXCEPTION 'below_min_withdrawal';
  END IF;
  IF p_amount_iqd > v_policy.max_amount_iqd THEN
    RAISE EXCEPTION 'above_max_withdrawal';
  END IF;

  -- only drivers can withdraw + eligibility rules
  SELECT d.status, d.trips_count INTO v_driver
  FROM public.drivers d
  WHERE d.id = v_uid;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_driver';
  END IF;

  IF v_policy.require_driver_not_suspended AND v_driver.status = 'suspended' THEN
    RAISE EXCEPTION 'driver_suspended';
  END IF;

  IF v_driver.trips_count < v_policy.min_trips_count THEN
    RAISE EXCEPTION 'driver_not_eligible_trips';
  END IF;

  IF v_policy.require_kyc THEN
    SELECT pk.status INTO v_kyc
    FROM public.profile_kyc pk
    WHERE pk.user_id = v_uid;
    IF coalesce(v_kyc, 'unverified') <> 'verified' THEN
      RAISE EXCEPTION 'kyc_required';
    END IF;
  END IF;

  -- destination validation
  PERFORM public.wallet_validate_withdraw_destination(p_payout_kind, COALESCE(p_destination, '{}'::jsonb));

  -- daily caps (based on Asia/Baghdad day boundary)
  v_today := (timezone('Asia/Baghdad', now()))::date;
  SELECT
    COALESCE(sum(w.amount_iqd), 0)::bigint,
    COALESCE(count(*), 0)::int
  INTO v_day_sum, v_day_count
  FROM public.wallet_withdraw_requests w
  WHERE w.user_id = v_uid
    AND w.status NOT IN ('rejected','cancelled')
    AND (timezone('Asia/Baghdad', w.created_at))::date = v_today;

  IF (v_day_count + 1) > v_policy.daily_cap_count THEN
    RAISE EXCEPTION 'daily_withdraw_count_cap';
  END IF;
  IF (v_day_sum + p_amount_iqd) > v_policy.daily_cap_amount_iqd THEN
    RAISE EXCEPTION 'daily_withdraw_amount_cap';
  END IF;

  -- lock wallet account row
  PERFORM 1 FROM public.wallet_accounts wa WHERE wa.user_id = v_uid FOR UPDATE;
  IF NOT FOUND THEN
    INSERT INTO public.wallet_accounts (user_id, balance_iqd, held_iqd)
    VALUES (v_uid, 0, 0)
    ON CONFLICT (user_id) DO NOTHING;
  END IF;

  SELECT (wa.balance_iqd - wa.held_iqd) INTO v_available
  FROM public.wallet_accounts wa
  WHERE wa.user_id = v_uid
  FOR UPDATE;

  IF v_available IS NULL THEN
    RAISE EXCEPTION 'wallet_account_missing';
  END IF;

  IF v_available < p_amount_iqd THEN
    RAISE EXCEPTION 'insufficient_wallet_balance';
  END IF;

  -- idempotency
  IF p_idempotency_key IS NOT NULL THEN
    SELECT id INTO v_req_id
    FROM public.wallet_withdraw_requests
    WHERE user_id = v_uid AND idempotency_key = p_idempotency_key
    LIMIT 1;

    IF v_req_id IS NOT NULL THEN
      RETURN v_req_id;
    END IF;
  END IF;

  INSERT INTO public.wallet_withdraw_requests (user_id, amount_iqd, payout_kind, destination, idempotency_key)
  VALUES (v_uid, p_amount_iqd, p_payout_kind, COALESCE(p_destination, '{}'::jsonb), p_idempotency_key)
  RETURNING id INTO v_req_id;

  -- create hold
  INSERT INTO public.wallet_holds (user_id, kind, withdraw_request_id, amount_iqd, status, reason, created_at, updated_at)
  VALUES (v_uid, 'withdraw', v_req_id, p_amount_iqd, 'active', 'Withdraw request', now(), now());

  UPDATE public.wallet_accounts
  SET held_iqd = held_iqd + p_amount_iqd,
      updated_at = now()
  WHERE user_id = v_uid;

  RETURN v_req_id;
END;
$$;


ALTER FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) OWNER TO postgres;

--
-- TOC entry 877 (class 1255 OID 39842)

--

CREATE FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $_$
DECLARE
  v_wallet text;
  v_card text;
  v_account text;
BEGIN
  IF p_payout_kind = 'zaincash' THEN
    v_wallet := trim(coalesce(p_destination->>'wallet_number', ''));
    IF v_wallet = '' THEN
      RAISE EXCEPTION 'missing_destination_wallet_number';
    END IF;
    -- Iraq mobile format: allow 07XXXXXXXXX, 7XXXXXXXXX, 9647XXXXXXXXX, +9647XXXXXXXXX
    IF v_wallet !~ '^(\+?964)?0?7\d{9}$' THEN
      RAISE EXCEPTION 'invalid_wallet_number_format';
    END IF;
  ELSIF p_payout_kind = 'qicard' THEN
    v_card := regexp_replace(trim(coalesce(p_destination->>'card_number', '')), '\s+', '', 'g');
    IF v_card = '' THEN
      RAISE EXCEPTION 'missing_destination_card_number';
    END IF;
    -- QiCard numbers vary by issuer; enforce digits-only with a safe length range.
    IF v_card !~ '^\d{12,19}$' THEN
      RAISE EXCEPTION 'invalid_card_number_format';
    END IF;
  ELSIF p_payout_kind = 'asiapay' THEN
    v_account := trim(coalesce(p_destination->>'account', coalesce(p_destination->>'wallet_number', '')));
    IF v_account = '' THEN
      RAISE EXCEPTION 'missing_destination_account';
    END IF;
    IF length(v_account) < 3 OR length(v_account) > 64 THEN
      RAISE EXCEPTION 'invalid_account_format';
    END IF;
  ELSE
    RAISE EXCEPTION 'invalid_payout_kind';
  END IF;
END;
$_$;


ALTER FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) OWNER TO postgres;

--
-- TOC entry 561 (class 1255 OID 44083)

--

CREATE FUNCTION public.whatsapp_booking_token_consume_v1(p_token text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
DECLARE
  v_uid uuid;
  v_row public.whatsapp_booking_tokens%ROWTYPE;
  v_intent_id uuid;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated' USING errcode = '28000';
  END IF;

  SELECT *
    INTO v_row
  FROM public.whatsapp_booking_tokens
  WHERE token = p_token
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'invalid_token' USING errcode = '22023';
  END IF;

  IF v_row.used_at IS NOT NULL THEN
    RAISE EXCEPTION 'token_used' USING errcode = '22023';
  END IF;

  IF v_row.expires_at <= now() THEN
    RAISE EXCEPTION 'token_expired' USING errcode = '22023';
  END IF;

  -- Mark used first to prevent races.
  UPDATE public.whatsapp_booking_tokens
     SET used_at = now(),
         used_by = v_uid
   WHERE id = v_row.id;

  -- Create ride intent for the authenticated rider.
  INSERT INTO public.ride_intents (
    rider_id,
    pickup_lat, pickup_lng,
    dropoff_lat, dropoff_lng,
    pickup_address, dropoff_address,
    product_code, source, status,
    notes
  ) VALUES (
    v_uid,
    v_row.pickup_lat, v_row.pickup_lng,
    v_row.dropoff_lat, v_row.dropoff_lng,
    v_row.pickup_address, v_row.dropoff_address,
    'standard', 'whatsapp', 'new',
    'Created via WhatsApp booking token'
  )
  RETURNING id INTO v_intent_id;

  RETURN v_intent_id;
END;
$$;


ALTER FUNCTION public.whatsapp_booking_token_consume_v1(p_token text) OWNER TO postgres;

--
-- TOC entry 684 (class 1255 OID 44081)

--

CREATE FUNCTION public.whatsapp_booking_token_create_v1(p_thread_id uuid, p_expires_minutes integer DEFAULT 30) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
DECLARE
  v_token text;
  v_hash text;
  v_thread public.whatsapp_threads%ROWTYPE;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not_admin' USING errcode = '42501';
  END IF;

  SELECT * INTO v_thread FROM public.whatsapp_threads WHERE id = p_thread_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'thread_not_found' USING errcode = '22023';
  END IF;

  IF v_thread.pickup_lat IS NULL OR v_thread.pickup_lng IS NULL OR v_thread.dropoff_lat IS NULL OR v_thread.dropoff_lng IS NULL THEN
    RAISE EXCEPTION 'thread_not_ready' USING errcode = '22023';
  END IF;

  v_token := encode(extensions.gen_random_bytes(32), 'hex');
  v_hash := encode(extensions.digest(v_token, 'sha256'), 'hex');

  INSERT INTO public.whatsapp_booking_tokens (
    thread_id, token, token_hash, expires_at,
    pickup_lat, pickup_lng, dropoff_lat, dropoff_lng,
    pickup_address, dropoff_address
  ) VALUES (
    p_thread_id, v_token, v_hash, now() + make_interval(mins => greatest(5, least(coalesce(p_expires_minutes, 30), 1440))),
    v_thread.pickup_lat, v_thread.pickup_lng, v_thread.dropoff_lat, v_thread.dropoff_lng,
    v_thread.pickup_address, v_thread.dropoff_address
  );

  RETURN v_token;
END;
$$;


ALTER FUNCTION public.whatsapp_booking_token_create_v1(p_thread_id uuid, p_expires_minutes integer) OWNER TO postgres;

--
-- TOC entry 1369 (class 1255 OID 44082)

--

CREATE FUNCTION public.whatsapp_booking_token_view_v1(p_token text) RETURNS TABLE(pickup_lat double precision, pickup_lng double precision, dropoff_lat double precision, dropoff_lng double precision, pickup_address text, dropoff_address text, expires_at timestamp with time zone, used_at timestamp with time zone)
    LANGUAGE sql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
  select
    t.pickup_lat,
    t.pickup_lng,
    t.dropoff_lat,
    t.dropoff_lng,
    t.pickup_address,
    t.dropoff_address,
    t.expires_at,
    t.used_at
  from public.whatsapp_booking_tokens t
  where t.token = p_token
    and t.used_at is null
    and t.expires_at > now()
  limit 1;
$$;


ALTER FUNCTION public.whatsapp_booking_token_view_v1(p_token text) OWNER TO postgres;

--
-- TOC entry 1322 (class 1255 OID 44090)

--

CREATE FUNCTION public.whatsapp_booking_tokens_cleanup_v1(p_limit integer DEFAULT 2000) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog', 'public'
    AS $$
DECLARE
  deleted_count int := 0;
BEGIN
  WITH doomed AS (
    SELECT id
    FROM public.whatsapp_booking_tokens
    WHERE used_at IS NULL
      AND expires_at < now()
    ORDER BY expires_at ASC
    LIMIT GREATEST(1, LEAST(p_limit, 50000))
  )
  DELETE FROM public.whatsapp_booking_tokens b
  USING doomed
  WHERE b.id = doomed.id;

  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$;


ALTER FUNCTION public.whatsapp_booking_tokens_cleanup_v1(p_limit integer) OWNER TO postgres;

--
-- TOC entry 1342 (class 1255 OID 44129)

--

CREATE FUNCTION public.whatsapp_messages_failed_outbound_to_followup_v1() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public'
    AS $$
BEGIN
  -- Only when outbound status transitions to failed
  IF (NEW.direction = 'out')
     AND (NEW.wa_status = 'failed')
     AND (OLD.wa_status IS DISTINCT FROM NEW.wa_status) THEN
    UPDATE public.whatsapp_threads
      SET needs_followup = true,
          followup_reason = COALESCE(followup_reason, 'outbound_failed'),
          followup_at = now(),
          last_failed_outbound_at = now(),
          last_failed_outbound_message_id = COALESCE(NEW.provider_message_id, NEW.wa_message_id),
          op_status = CASE WHEN op_status = 'resolved' THEN op_status ELSE 'waiting_operator' END,
          updated_at = now()
    WHERE id = NEW.thread_id;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION public.whatsapp_messages_failed_outbound_to_followup_v1() OWNER TO postgres;

--
-- TOC entry 761 (class 1255 OID 44094)

--

CREATE FUNCTION public.whatsapp_messages_touch_updated_at_v1() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog', 'public'
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.whatsapp_messages_touch_updated_at_v1() OWNER TO postgres;

--
-- TOC entry 526 (class 1255 OID 17157)

--

CREATE TABLE public.achievement_progress (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    achievement_id uuid NOT NULL,
    progress bigint DEFAULT 0 NOT NULL,
    completed_at timestamp with time zone,
    claimed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.achievement_progress OWNER TO postgres;

--
-- TOC entry 449 (class 1259 OID 40681)

--

CREATE TABLE public.achievements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL,
    role text NOT NULL,
    metric text DEFAULT 'completed_rides'::text NOT NULL,
    target bigint NOT NULL,
    title text NOT NULL,
    description text,
    reward_iqd integer DEFAULT 0 NOT NULL,
    badge_icon text,
    sort_order integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT achievements_role_check CHECK ((role = ANY (ARRAY['driver'::text, 'rider'::text])))
);


ALTER TABLE public.achievements OWNER TO postgres;

--
-- TOC entry 496 (class 1259 OID 44343)

--

CREATE VIEW public.admin_security_audit_functions_v1 WITH (security_invoker='true') AS
 SELECT ns.nspname AS schema,
    p.proname AS name,
    pg_get_function_identity_arguments(p.oid) AS identity_args,
    format('%I.%I(%s)'::text, ns.nspname, p.proname, pg_get_function_identity_arguments(p.oid)) AS signature,
    p.prosecdef AS is_security_definer,
    ( SELECT split_part(cfg.cfg, '='::text, 2) AS split_part
           FROM unnest(COALESCE(p.proconfig, ARRAY[]::text[])) cfg(cfg)
          WHERE (cfg.cfg ~~ 'search_path=%'::text)
         LIMIT 1) AS search_path,
    has_function_privilege('public'::name, p.oid, 'EXECUTE'::text) AS public_execute,
    has_function_privilege('anon'::name, p.oid, 'EXECUTE'::text) AS anon_execute,
    has_function_privilege('authenticated'::name, p.oid, 'EXECUTE'::text) AS authenticated_execute,
    has_function_privilege('service_role'::name, p.oid, 'EXECUTE'::text) AS service_role_execute
   FROM (pg_proc p
     JOIN pg_namespace ns ON ((ns.oid = p.pronamespace)))
  WHERE (ns.nspname = 'public'::name);


ALTER VIEW public.admin_security_audit_functions_v1 OWNER TO postgres;

--
-- TOC entry 498 (class 1259 OID 44352)

--

CREATE VIEW public.admin_security_audit_policies_v1 WITH (security_invoker='true') AS
 SELECT pn.nspname AS table_schema,
    pc.relname AS table_name,
    pol.polname AS policy_name,
    pol.polcmd AS command,
    pol.polpermissive AS permissive,
    COALESCE(( SELECT array_agg(r.rolname ORDER BY r.rolname) AS array_agg
           FROM (unnest(pol.polroles) role_oid(role_oid)
             JOIN pg_roles r ON ((r.oid = role_oid.role_oid)))), (ARRAY[]::text[])::name[]) AS roles,
    pg_get_expr(pol.polqual, pol.polrelid) AS using_expr,
    pg_get_expr(pol.polwithcheck, pol.polrelid) AS withcheck_expr,
    ((pg_get_expr(pol.polqual, pol.polrelid) ~~ '%auth.uid()%'::text) AND (pg_get_expr(pol.polqual, pol.polrelid) !~~ '%(select auth.uid())%'::text)) AS should_wrap_auth_uid_with_select,
    ((pg_get_expr(pol.polqual, pol.polrelid) ~~ '%auth.role()%'::text) AND (pg_get_expr(pol.polqual, pol.polrelid) !~~ '%(select auth.role())%'::text)) AS should_wrap_auth_role_with_select
   FROM ((pg_policy pol
     JOIN pg_class pc ON ((pc.oid = pol.polrelid)))
     JOIN pg_namespace pn ON ((pn.oid = pc.relnamespace)))
  WHERE (pn.nspname = 'public'::name);


ALTER VIEW public.admin_security_audit_policies_v1 OWNER TO postgres;

--
-- TOC entry 497 (class 1259 OID 44348)

--

CREATE VIEW public.admin_security_audit_schema_v1 WITH (security_invoker='true') AS
 SELECT nspname AS schema,
    has_schema_privilege('public'::name, oid, 'CREATE'::text) AS public_can_create,
    has_schema_privilege('anon'::name, oid, 'CREATE'::text) AS anon_can_create,
    has_schema_privilege('authenticated'::name, oid, 'CREATE'::text) AS authenticated_can_create,
    has_schema_privilege('service_role'::name, oid, 'CREATE'::text) AS service_role_can_create
   FROM pg_namespace n
  WHERE (nspname = 'public'::name);


ALTER VIEW public.admin_security_audit_schema_v1 OWNER TO postgres;

--
-- TOC entry 414 (class 1259 OID 39843)

--

CREATE TABLE public.api_rate_limits (
    key text NOT NULL,
    window_start timestamp with time zone NOT NULL,
    window_seconds integer NOT NULL,
    count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.api_rate_limits OWNER TO postgres;

--
-- TOC entry 415 (class 1259 OID 39849)

--

CREATE TABLE public.app_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    event_type text NOT NULL,
    level text DEFAULT 'info'::text NOT NULL,
    actor_id uuid,
    actor_type text,
    request_id text,
    ride_id uuid,
    payment_intent_id uuid,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.app_events OWNER TO postgres;

--
-- TOC entry 443 (class 1259 OID 40583)

--

CREATE TABLE public.device_tokens (
    id bigint NOT NULL,
    user_id uuid NOT NULL,
    token text NOT NULL,
    platform text DEFAULT 'android'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    disabled_at timestamp with time zone,
    enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.device_tokens OWNER TO postgres;

--
-- TOC entry 442 (class 1259 OID 40582)

--

CREATE SEQUENCE public.device_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.device_tokens_id_seq OWNER TO postgres;

--
-- TOC entry 7966 (class 0 OID 0)
-- Dependencies: 442

--

ALTER SEQUENCE public.device_tokens_id_seq OWNED BY public.device_tokens.id;


--
-- TOC entry 446 (class 1259 OID 40633)

--

CREATE TABLE public.driver_counters (
    driver_id uuid NOT NULL,
    completed_rides bigint DEFAULT 0 NOT NULL,
    earnings_iqd bigint DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.driver_counters OWNER TO postgres;

--
-- TOC entry 474 (class 1259 OID 41825)

--

CREATE TABLE public.driver_leaderboard_daily (
    day date NOT NULL,
    driver_id uuid NOT NULL,
    trips_count integer DEFAULT 0 NOT NULL,
    earnings_iqd bigint DEFAULT 0 NOT NULL,
    score numeric DEFAULT 0 NOT NULL,
    rank integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.driver_leaderboard_daily OWNER TO postgres;

--
-- TOC entry 416 (class 1259 OID 39858)

--

CREATE TABLE public.driver_locations (
    driver_id uuid DEFAULT auth.uid() NOT NULL,
    lat double precision NOT NULL,
    lng double precision NOT NULL,
    loc extensions.geography(Point,4326) GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(lng, lat), 4326))::extensions.geography) STORED,
    heading numeric,
    speed_mps numeric,
    accuracy_m numeric,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT driver_locations_lat_check CHECK (((lat >= ('-90'::integer)::double precision) AND (lat <= (90)::double precision))),
    CONSTRAINT driver_locations_lng_check CHECK (((lng >= ('-180'::integer)::double precision) AND (lng <= (180)::double precision)))
);

ALTER TABLE ONLY public.driver_locations REPLICA IDENTITY FULL;


ALTER TABLE public.driver_locations OWNER TO postgres;

--
-- TOC entry 448 (class 1259 OID 40660)

--

CREATE TABLE public.driver_rank_snapshots (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    period text NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    driver_id uuid NOT NULL,
    rank integer NOT NULL,
    score_iqd bigint NOT NULL,
    rides_completed integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    score numeric(12,2),
    earnings_iqd bigint,
    CONSTRAINT driver_rank_snapshots_period_check CHECK ((period = ANY (ARRAY['weekly'::text, 'monthly'::text])))
);


ALTER TABLE public.driver_rank_snapshots OWNER TO postgres;

--
-- TOC entry 447 (class 1259 OID 40646)

--

CREATE TABLE public.driver_stats_daily (
    driver_id uuid NOT NULL,
    day date NOT NULL,
    rides_completed integer DEFAULT 0 NOT NULL,
    earnings_iqd bigint DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    trips_count integer,
    created_at timestamp with time zone
);

ALTER TABLE ONLY public.driver_stats_daily REPLICA IDENTITY FULL;


ALTER TABLE public.driver_stats_daily OWNER TO postgres;

--
-- TOC entry 417 (class 1259 OID 39868)

--

CREATE TABLE public.driver_vehicles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    driver_id uuid NOT NULL,
    make text,
    model text,
    color text,
    plate_number text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    vehicle_type text,
    capacity integer,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.driver_vehicles OWNER TO postgres;

--
-- TOC entry 418 (class 1259 OID 39876)

--

CREATE TABLE public.drivers (
    id uuid NOT NULL,
    status public.driver_status DEFAULT 'offline'::public.driver_status NOT NULL,
    vehicle_type text,
    rating_avg numeric(3,2) DEFAULT 5.00 NOT NULL,
    trips_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    rating_count integer DEFAULT 0 NOT NULL,
    require_pickup_pin boolean DEFAULT false NOT NULL
);


ALTER TABLE public.drivers OWNER TO postgres;

--
-- TOC entry 465 (class 1259 OID 41373)

--

CREATE TABLE public.kyc_document_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL,
    title text NOT NULL,
    description text,
    role_required text NOT NULL,
    is_required boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    country_code text,
    allowed_mime text[] DEFAULT ARRAY['image/jpeg'::text, 'image/png'::text, 'application/pdf'::text] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT kyc_document_types_role_required_check CHECK ((role_required = ANY (ARRAY['rider'::text, 'driver'::text, 'both'::text])))
);


ALTER TABLE public.kyc_document_types OWNER TO postgres;

--
-- TOC entry 463 (class 1259 OID 41012)

--

CREATE TABLE public.kyc_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    submission_id uuid NOT NULL,
    user_id uuid NOT NULL,
    doc_type text NOT NULL,
    storage_bucket text DEFAULT 'kyc-documents'::text NOT NULL,
    storage_object_key text NOT NULL,
    mime_type text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    profile_id uuid,
    document_type_id uuid,
    object_key text,
    status text,
    rejection_reason text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.kyc_documents OWNER TO postgres;

--
-- TOC entry 466 (class 1259 OID 41392)

--

CREATE TABLE public.kyc_liveness_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    submission_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    provider text DEFAULT 'internal'::text NOT NULL,
    status text DEFAULT 'started'::text NOT NULL,
    provider_ref text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT kyc_liveness_sessions_status_check CHECK ((status = ANY (ARRAY['started'::text, 'passed'::text, 'failed'::text, 'expired'::text])))
);


ALTER TABLE public.kyc_liveness_sessions OWNER TO postgres;

--
-- TOC entry 462 (class 1259 OID 40989)

--

CREATE TABLE public.kyc_submissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    decision_note text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    submitted_at timestamp with time zone,
    reviewed_at timestamp with time zone,
    reviewer_id uuid,
    profile_id uuid,
    role_context text,
    role text,
    notes text,
    reviewer_note text
);


ALTER TABLE public.kyc_submissions OWNER TO postgres;

--
-- TOC entry 445 (class 1259 OID 40608)

--

CREATE TABLE public.notification_outbox (
    id bigint NOT NULL,
    notification_id uuid NOT NULL,
    user_id uuid NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT notification_outbox_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'sent'::text, 'failed'::text, 'skipped'::text])))
);


ALTER TABLE public.notification_outbox OWNER TO postgres;

--
-- TOC entry 444 (class 1259 OID 40607)

--

CREATE SEQUENCE public.notification_outbox_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_outbox_id_seq OWNER TO postgres;

--
-- TOC entry 7980 (class 0 OID 0)
-- Dependencies: 444

--

ALTER SEQUENCE public.notification_outbox_id_seq OWNED BY public.notification_outbox.id;


--
-- TOC entry 419 (class 1259 OID 39887)

--

CREATE TABLE public.payment_intents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    provider text DEFAULT 'stub'::text NOT NULL,
    provider_ref text,
    status public.payment_intent_status DEFAULT 'requires_payment_method'::public.payment_intent_status NOT NULL,
    amount_iqd integer NOT NULL,
    currency text DEFAULT 'IQD'::text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    idempotency_key text,
    provider_session_id text,
    provider_payment_intent_id text,
    last_error text,
    provider_charge_id text
);


ALTER TABLE public.payment_intents OWNER TO postgres;

--
-- TOC entry 420 (class 1259 OID 39899)

--

CREATE TABLE public.payment_providers (
    code text NOT NULL,
    name text NOT NULL,
    kind public.payment_provider_kind NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payment_providers OWNER TO postgres;

--
-- TOC entry 421 (class 1259 OID 39909)

--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    provider text NOT NULL,
    provider_ref text,
    status text NOT NULL,
    amount_iqd integer NOT NULL,
    currency text DEFAULT 'IQD'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    payment_intent_id uuid,
    provider_payment_intent_id text,
    provider_charge_id text,
    provider_refund_id text,
    method text,
    failure_code text,
    failure_message text,
    refunded_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    refund_amount_iqd integer,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);

ALTER TABLE ONLY public.payments REPLICA IDENTITY FULL;


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 422 (class 1259 OID 39919)

--

CREATE TABLE public.pricing_configs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    currency text DEFAULT 'IQD'::text NOT NULL,
    base_fare_iqd integer DEFAULT 200 NOT NULL,
    per_km_iqd integer DEFAULT 80 NOT NULL,
    per_min_iqd integer DEFAULT 15 NOT NULL,
    minimum_fare_iqd integer DEFAULT 300 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    max_surge_multiplier numeric DEFAULT 1.5 NOT NULL
);


ALTER TABLE public.pricing_configs OWNER TO postgres;

--
-- TOC entry 7985 (class 0 OID 0)
-- Dependencies: 422

--

COMMENT ON COLUMN public.pricing_configs.max_surge_multiplier IS 'Maximum allowed surge multiplier (demand-based). Does not cap product multipliers.';


--
-- TOC entry 423 (class 1259 OID 39933)

--

CREATE TABLE public.profile_kyc (
    user_id uuid NOT NULL,
    status public.kyc_status DEFAULT 'unverified'::public.kyc_status NOT NULL,
    note text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid
);


ALTER TABLE public.profile_kyc OWNER TO postgres;

--
-- TOC entry 424 (class 1259 OID 39940)

--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    display_name text,
    phone text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    rating_avg numeric(3,2) DEFAULT 5.00 NOT NULL,
    rating_count integer DEFAULT 0 NOT NULL,
    is_admin boolean DEFAULT false NOT NULL,
    avatar_object_key text,
    locale text DEFAULT 'en'::text NOT NULL,
    active_role text DEFAULT 'rider'::text NOT NULL,
    gender text,
    CONSTRAINT profiles_active_role_check CHECK ((active_role = ANY (ARRAY['rider'::text, 'driver'::text]))),
    CONSTRAINT profiles_gender_check CHECK (((gender IS NULL) OR (gender = ANY (ARRAY['male'::text, 'female'::text, 'unknown'::text]))))
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- TOC entry 425 (class 1259 OID 39950)

--

CREATE TABLE public.provider_events (
    id bigint NOT NULL,
    provider_code text NOT NULL,
    provider_event_id text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.provider_events OWNER TO postgres;

--
-- TOC entry 426 (class 1259 OID 39957)

--

CREATE SEQUENCE public.provider_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.provider_events_id_seq OWNER TO postgres;

--
-- TOC entry 7990 (class 0 OID 0)
-- Dependencies: 426

--

ALTER SEQUENCE public.provider_events_id_seq OWNED BY public.provider_events.id;


--
-- TOC entry 441 (class 1259 OID 40563)

--

CREATE TABLE public.public_profiles (
    id uuid NOT NULL,
    display_name text,
    rating_avg numeric(3,2) DEFAULT 5.00 NOT NULL,
    rating_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.public_profiles REPLICA IDENTITY FULL;


ALTER TABLE public.public_profiles OWNER TO postgres;

--
-- TOC entry 451 (class 1259 OID 40722)

--

CREATE TABLE public.referral_campaigns (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL,
    referrer_reward_iqd integer DEFAULT 0 NOT NULL,
    referred_reward_iqd integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.referral_campaigns OWNER TO postgres;

--
-- TOC entry 452 (class 1259 OID 40736)

--

CREATE TABLE public.referral_codes (
    code text NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.referral_codes OWNER TO postgres;

--
-- TOC entry 473 (class 1259 OID 41788)

--

CREATE TABLE public.referral_invites (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    referrer_id uuid NOT NULL,
    referred_user_id uuid NOT NULL,
    code_used text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    qualified_at timestamp with time zone,
    rewarded_at timestamp with time zone,
    CONSTRAINT referral_invites_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'qualified'::text, 'rewarded'::text, 'canceled'::text])))
);


ALTER TABLE public.referral_invites OWNER TO postgres;

--
-- TOC entry 453 (class 1259 OID 40752)

--

CREATE TABLE public.referral_redemptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    campaign_id uuid NOT NULL,
    referrer_id uuid NOT NULL,
    referred_id uuid NOT NULL,
    code text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    earned_at timestamp with time zone,
    rewarded_at timestamp with time zone,
    ride_id uuid,
    CONSTRAINT referral_redemptions_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'rewarded'::text, 'invalid'::text])))
);


ALTER TABLE public.referral_redemptions OWNER TO postgres;

--
-- TOC entry 472 (class 1259 OID 41777)

--

CREATE TABLE public.referral_settings (
    id integer DEFAULT 1 NOT NULL,
    reward_referrer_iqd integer DEFAULT 2000 NOT NULL,
    reward_referee_iqd integer DEFAULT 2000 NOT NULL,
    min_completed_rides integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.referral_settings OWNER TO postgres;

--
-- TOC entry 458 (class 1259 OID 40890)

--

CREATE TABLE public.ride_chat_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    message_type text DEFAULT 'text'::text NOT NULL,
    body text,
    media_object_key text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    thread_id uuid,
    kind text,
    message text,
    attachments jsonb DEFAULT '[]'::jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    attachment_bucket text,
    attachment_key text,
    metadata jsonb
);


ALTER TABLE public.ride_chat_messages OWNER TO postgres;

--
-- TOC entry 459 (class 1259 OID 40914)

--

CREATE TABLE public.ride_chat_read_receipts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    message_id uuid NOT NULL,
    reader_id uuid NOT NULL,
    read_at timestamp with time zone DEFAULT now() NOT NULL,
    thread_id uuid,
    user_id uuid,
    last_read_at timestamp with time zone,
    last_read_message_id uuid,
    updated_at timestamp with time zone
);


ALTER TABLE public.ride_chat_read_receipts OWNER TO postgres;

--
-- TOC entry 471 (class 1259 OID 41740)

--

CREATE TABLE public.ride_chat_threads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    rider_id uuid NOT NULL,
    driver_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ride_chat_threads OWNER TO postgres;

--
-- TOC entry 460 (class 1259 OID 40939)

--

CREATE TABLE public.ride_chat_typing (
    ride_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    is_typing boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ride_chat_typing OWNER TO postgres;

--
-- TOC entry 470 (class 1259 OID 41717)

--

CREATE TABLE public.ride_completion_log (
    ride_id uuid NOT NULL,
    processed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ride_completion_log OWNER TO postgres;

--
-- TOC entry 427 (class 1259 OID 39958)

--

CREATE TABLE public.ride_events (
    id bigint NOT NULL,
    ride_id uuid NOT NULL,
    actor_id uuid,
    actor_type public.ride_actor_type NOT NULL,
    event_type text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ride_events OWNER TO postgres;

--
-- TOC entry 428 (class 1259 OID 39965)

--

CREATE SEQUENCE public.ride_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ride_events_id_seq OWNER TO postgres;

--
-- TOC entry 8004 (class 0 OID 0)
-- Dependencies: 428

--

ALTER SEQUENCE public.ride_events_id_seq OWNED BY public.ride_events.id;


--
-- TOC entry 429 (class 1259 OID 39966)

--

CREATE TABLE public.ride_incidents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid,
    reporter_id uuid NOT NULL,
    severity public.incident_severity DEFAULT 'low'::public.incident_severity NOT NULL,
    status public.incident_status DEFAULT 'open'::public.incident_status NOT NULL,
    category text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    assigned_to uuid,
    reviewed_at timestamp with time zone,
    resolution_note text,
    reporter_type text,
    lat double precision,
    lng double precision,
    loc extensions.geography(Point,4326) GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(lng, lat), 4326))::extensions.geography) STORED,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.ride_incidents OWNER TO postgres;

--
-- TOC entry 478 (class 1259 OID 43615)

--

CREATE TABLE public.ride_intents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    rider_id uuid NOT NULL,
    pickup_lat double precision NOT NULL,
    pickup_lng double precision NOT NULL,
    pickup_loc extensions.geography(Point,4326) GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(pickup_lng, pickup_lat), 4326))::extensions.geography) STORED,
    dropoff_lat double precision NOT NULL,
    dropoff_lng double precision NOT NULL,
    dropoff_loc extensions.geography(Point,4326) GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(dropoff_lng, dropoff_lat), 4326))::extensions.geography) STORED,
    pickup_address text,
    dropoff_address text,
    service_area_id uuid,
    product_code text DEFAULT 'standard'::text NOT NULL,
    scheduled_at timestamp with time zone,
    source text DEFAULT 'whatsapp'::text NOT NULL,
    status text DEFAULT 'new'::text NOT NULL,
    converted_request_id uuid,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    preferences jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT ride_intents_dropoff_lat_check CHECK (((dropoff_lat >= ('-90'::integer)::double precision) AND (dropoff_lat <= (90)::double precision))),
    CONSTRAINT ride_intents_dropoff_lng_check CHECK (((dropoff_lng >= ('-180'::integer)::double precision) AND (dropoff_lng <= (180)::double precision))),
    CONSTRAINT ride_intents_pickup_lat_check CHECK (((pickup_lat >= ('-90'::integer)::double precision) AND (pickup_lat <= (90)::double precision))),
    CONSTRAINT ride_intents_pickup_lng_check CHECK (((pickup_lng >= ('-180'::integer)::double precision) AND (pickup_lng <= (180)::double precision))),
    CONSTRAINT ride_intents_status_check CHECK ((status = ANY (ARRAY['new'::text, 'converted'::text, 'closed'::text])))
);


ALTER TABLE public.ride_intents OWNER TO postgres;

--
-- TOC entry 464 (class 1259 OID 41198)

--

CREATE TABLE public.ride_products (
    code text NOT NULL,
    name text NOT NULL,
    description text,
    capacity_min integer DEFAULT 4 NOT NULL,
    price_multiplier numeric(6,3) DEFAULT 1.000 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ride_products OWNER TO postgres;

--
-- TOC entry 430 (class 1259 OID 39976)

--

CREATE TABLE public.ride_ratings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    rater_id uuid NOT NULL,
    ratee_id uuid NOT NULL,
    rater_role public.party_role NOT NULL,
    ratee_role public.party_role NOT NULL,
    rating smallint NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ride_ratings_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.ride_ratings OWNER TO postgres;

--
-- TOC entry 431 (class 1259 OID 39984)

--

CREATE TABLE public.ride_receipts (
    ride_id uuid NOT NULL,
    base_fare_iqd integer,
    tax_iqd integer DEFAULT 0 NOT NULL,
    tip_iqd integer DEFAULT 0 NOT NULL,
    total_iqd integer NOT NULL,
    currency text DEFAULT 'IQD'::text NOT NULL,
    generated_at timestamp with time zone DEFAULT now() NOT NULL,
    refunded_iqd integer DEFAULT 0 NOT NULL,
    refunded_at timestamp with time zone,
    receipt_status text DEFAULT 'paid'::text NOT NULL
);


ALTER TABLE public.ride_receipts OWNER TO postgres;

--
-- TOC entry 432 (class 1259 OID 39995)

--

CREATE TABLE public.ride_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    rider_id uuid DEFAULT auth.uid() NOT NULL,
    pickup_lat double precision NOT NULL,
    pickup_lng double precision NOT NULL,
    pickup_loc extensions.geography(Point,4326) GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(pickup_lng, pickup_lat), 4326))::extensions.geography) STORED,
    dropoff_lat double precision NOT NULL,
    dropoff_lng double precision NOT NULL,
    dropoff_loc extensions.geography(Point,4326) GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(dropoff_lng, dropoff_lat), 4326))::extensions.geography) STORED,
    pickup_address text,
    dropoff_address text,
    status public.ride_request_status DEFAULT 'requested'::public.ride_request_status NOT NULL,
    assigned_driver_id uuid,
    match_deadline timestamp with time zone,
    match_attempts integer DEFAULT 0 NOT NULL,
    quote_amount_iqd integer,
    currency text DEFAULT 'IQD'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    matched_at timestamp with time zone,
    accepted_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    product_code text DEFAULT 'standard'::text NOT NULL,
    service_area_id uuid,
    preferences jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT ride_requests_dropoff_lat_check CHECK (((dropoff_lat >= ('-90'::integer)::double precision) AND (dropoff_lat <= (90)::double precision))),
    CONSTRAINT ride_requests_dropoff_lng_check CHECK (((dropoff_lng >= ('-180'::integer)::double precision) AND (dropoff_lng <= (180)::double precision))),
    CONSTRAINT ride_requests_pickup_lat_check CHECK (((pickup_lat >= ('-90'::integer)::double precision) AND (pickup_lat <= (90)::double precision))),
    CONSTRAINT ride_requests_pickup_lng_check CHECK (((pickup_lng >= ('-180'::integer)::double precision) AND (pickup_lng <= (180)::double precision)))
);

ALTER TABLE ONLY public.ride_requests REPLICA IDENTITY FULL;


ALTER TABLE public.ride_requests OWNER TO postgres;

--
-- TOC entry 485 (class 1259 OID 43827)

--

CREATE TABLE public.ridecheck_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    kind text NOT NULL,
    status text DEFAULT 'open'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    resolved_at timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT ridecheck_events_status_check CHECK ((status = ANY (ARRAY['open'::text, 'resolved'::text, 'escalated'::text])))
);

ALTER TABLE ONLY public.ridecheck_events REPLICA IDENTITY FULL;


ALTER TABLE public.ridecheck_events OWNER TO postgres;

--
-- TOC entry 486 (class 1259 OID 43847)

--

CREATE TABLE public.ridecheck_responses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    ride_id uuid NOT NULL,
    user_id uuid NOT NULL,
    role text NOT NULL,
    response text NOT NULL,
    note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ridecheck_responses_response_check CHECK ((response = ANY (ARRAY['ok'::text, 'false_alarm'::text, 'need_help'::text]))),
    CONSTRAINT ridecheck_responses_role_check CHECK ((role = ANY (ARRAY['rider'::text, 'driver'::text])))
);

ALTER TABLE ONLY public.ridecheck_responses REPLICA IDENTITY FULL;


ALTER TABLE public.ridecheck_responses OWNER TO postgres;

--
-- TOC entry 484 (class 1259 OID 43811)

--

CREATE TABLE public.ridecheck_state (
    ride_id uuid NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    last_loc extensions.geography(Point,4326),
    last_distance_to_dropoff_m double precision,
    distance_increase_streak integer DEFAULT 0 NOT NULL,
    last_move_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ridecheck_state OWNER TO postgres;

--
-- TOC entry 476 (class 1259 OID 43545)

--

CREATE TABLE public.scheduled_rides (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    rider_id uuid NOT NULL,
    pickup_lat double precision NOT NULL,
    pickup_lng double precision NOT NULL,
    dropoff_lat double precision NOT NULL,
    dropoff_lng double precision NOT NULL,
    pickup_address text,
    dropoff_address text,
    product_code text DEFAULT 'standard'::text NOT NULL,
    scheduled_at timestamp with time zone NOT NULL,
    status public.scheduled_ride_status DEFAULT 'pending'::public.scheduled_ride_status NOT NULL,
    ride_request_id uuid,
    executed_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    failure_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    service_area_id uuid,
    preferences jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.scheduled_rides OWNER TO postgres;

--
-- TOC entry 477 (class 1259 OID 43576)

--

CREATE TABLE public.service_areas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    governorate text,
    is_active boolean DEFAULT true NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    pricing_config_id uuid,
    geom extensions.geometry(MultiPolygon,4326) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    min_base_fare_iqd integer,
    surge_multiplier numeric DEFAULT 1.0 NOT NULL,
    surge_reason text,
    CONSTRAINT service_areas_surge_multiplier_check CHECK ((surge_multiplier >= 1.0))
);


ALTER TABLE public.service_areas OWNER TO postgres;

--
-- TOC entry 8016 (class 0 OID 0)
-- Dependencies: 477

--

COMMENT ON COLUMN public.service_areas.min_base_fare_iqd IS 'Optional minimum base fare override (IQD) for rides in this service area.';


--
-- TOC entry 8017 (class 0 OID 0)
-- Dependencies: 477

--

COMMENT ON COLUMN public.service_areas.surge_multiplier IS 'Ops-controlled raw surge multiplier for this service area (>= 1.0). Capped by pricing_configs.max_surge_multiplier.';


--
-- TOC entry 479 (class 1259 OID 43676)

--

CREATE TABLE public.sos_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    ride_id uuid,
    lat double precision,
    lng double precision,
    status text DEFAULT 'triggered'::text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    resolved_at timestamp with time zone
);


ALTER TABLE public.sos_events OWNER TO postgres;

--
-- TOC entry 481 (class 1259 OID 43717)

--

CREATE TABLE public.support_articles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    section_id uuid,
    slug text NOT NULL,
    title text NOT NULL,
    summary text,
    body_md text DEFAULT ''::text NOT NULL,
    tags text[] DEFAULT ARRAY[]::text[] NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.support_articles OWNER TO postgres;

--
-- TOC entry 455 (class 1259 OID 40824)

--

CREATE TABLE public.support_categories (
    code text NOT NULL,
    title text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    id uuid DEFAULT gen_random_uuid(),
    description text,
    enabled boolean DEFAULT true NOT NULL,
    key text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.support_categories OWNER TO postgres;

--
-- TOC entry 457 (class 1259 OID 40861)

--

CREATE TABLE public.support_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ticket_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    sender_profile_id uuid,
    body text,
    attachments jsonb DEFAULT '[]'::jsonb NOT NULL
);


ALTER TABLE public.support_messages OWNER TO postgres;

--
-- TOC entry 480 (class 1259 OID 43703)

--

CREATE TABLE public.support_sections (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL,
    title text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.support_sections OWNER TO postgres;

--
-- TOC entry 456 (class 1259 OID 40833)

--

CREATE TABLE public.support_tickets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_by uuid NOT NULL,
    category_code text,
    subject text NOT NULL,
    ride_id uuid,
    status text DEFAULT 'open'::text NOT NULL,
    priority text DEFAULT 'normal'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    role_context text,
    category_id uuid,
    notes text,
    assigned_to uuid,
    resolved_at timestamp with time zone
);


ALTER TABLE public.support_tickets OWNER TO postgres;

--
-- TOC entry 467 (class 1259 OID 41439)

--

CREATE VIEW public.support_ticket_summaries WITH (security_invoker='on') AS
 SELECT id,
    category_code,
    subject,
    status,
    priority,
    ride_id,
    created_by,
    created_at,
    updated_at,
    ( SELECT m.message
           FROM public.support_messages m
          WHERE (m.ticket_id = t.id)
          ORDER BY m.created_at DESC
         LIMIT 1) AS last_message,
    ( SELECT m.created_at
           FROM public.support_messages m
          WHERE (m.ticket_id = t.id)
          ORDER BY m.created_at DESC
         LIMIT 1) AS last_message_at,
    ( SELECT (count(*))::integer AS count
           FROM public.support_messages m
          WHERE (m.ticket_id = t.id)) AS messages_count
   FROM public.support_tickets t;


ALTER VIEW public.support_ticket_summaries OWNER TO postgres;

--
-- TOC entry 433 (class 1259 OID 40013)

--

CREATE TABLE public.topup_packages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label text NOT NULL,
    amount_iqd bigint NOT NULL,
    bonus_iqd bigint DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT topup_packages_amount_iqd_check CHECK ((amount_iqd > 0)),
    CONSTRAINT topup_packages_bonus_iqd_check CHECK ((bonus_iqd >= 0))
);


ALTER TABLE public.topup_packages OWNER TO postgres;

--
-- TOC entry 461 (class 1259 OID 40961)

--

CREATE TABLE public.trip_share_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    created_by uuid NOT NULL,
    token text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    token_hash text
);


ALTER TABLE public.trip_share_tokens OWNER TO postgres;

--
-- TOC entry 483 (class 1259 OID 43767)

--

CREATE TABLE public.trusted_contact_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    contact_id uuid,
    ride_id uuid,
    event_type text NOT NULL,
    status text DEFAULT 'ok'::text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.trusted_contact_events OWNER TO postgres;

--
-- TOC entry 487 (class 1259 OID 43966)

--

CREATE TABLE public.trusted_contact_outbox (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    contact_id uuid NOT NULL,
    sos_event_id uuid NOT NULL,
    ride_id uuid,
    channel text DEFAULT 'whatsapp'::text NOT NULL,
    to_phone text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error text,
    next_attempt_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    provider_message_id text,
    last_http_status integer,
    last_response text,
    CONSTRAINT trusted_contact_outbox_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'sent'::text, 'failed'::text, 'skipped'::text])))
);


ALTER TABLE public.trusted_contact_outbox OWNER TO postgres;

--
-- TOC entry 454 (class 1259 OID 40790)

--

CREATE TABLE public.trusted_contacts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name text NOT NULL,
    phone text NOT NULL,
    relationship text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.trusted_contacts OWNER TO postgres;

--
-- TOC entry 469 (class 1259 OID 41699)

--

CREATE TABLE public.user_device_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    device_id text NOT NULL,
    platform text NOT NULL,
    token text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_device_tokens OWNER TO postgres;

--
-- TOC entry 434 (class 1259 OID 40026)

--

CREATE TABLE public.user_notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    kind text NOT NULL,
    title text NOT NULL,
    body text,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    read_at timestamp with time zone
);


ALTER TABLE public.user_notifications OWNER TO postgres;

--
-- TOC entry 482 (class 1259 OID 43747)

--

CREATE TABLE public.user_safety_settings (
    user_id uuid NOT NULL,
    auto_share_on_trip_start boolean DEFAULT false NOT NULL,
    auto_notify_on_sos boolean DEFAULT true NOT NULL,
    default_share_ttl_minutes integer DEFAULT 120 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    pin_verification_mode text DEFAULT 'off'::text NOT NULL,
    CONSTRAINT user_safety_settings_pin_verification_mode_check CHECK ((pin_verification_mode = ANY (ARRAY['off'::text, 'every_ride'::text, 'night_only'::text]))),
    CONSTRAINT user_safety_settings_ttl_ck CHECK (((default_share_ttl_minutes >= 5) AND (default_share_ttl_minutes <= 1440)))
);


ALTER TABLE public.user_safety_settings OWNER TO postgres;

--
-- TOC entry 435 (class 1259 OID 40034)

--

CREATE TABLE public.wallet_entries (
    id bigint NOT NULL,
    user_id uuid NOT NULL,
    kind public.wallet_entry_kind NOT NULL,
    delta_iqd bigint NOT NULL,
    memo text,
    source_type text,
    source_id uuid,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    idempotency_key text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.wallet_entries OWNER TO postgres;

--
-- TOC entry 436 (class 1259 OID 40041)

--

CREATE SEQUENCE public.wallet_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wallet_entries_id_seq OWNER TO postgres;

--
-- TOC entry 8035 (class 0 OID 0)
-- Dependencies: 436

--

ALTER SEQUENCE public.wallet_entries_id_seq OWNED BY public.wallet_entries.id;


--
-- TOC entry 437 (class 1259 OID 40042)

--

CREATE TABLE public.wallet_holds (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    ride_id uuid,
    amount_iqd bigint NOT NULL,
    status public.wallet_hold_status DEFAULT 'active'::public.wallet_hold_status NOT NULL,
    reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    captured_at timestamp with time zone,
    released_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    kind public.wallet_hold_kind DEFAULT 'ride'::public.wallet_hold_kind NOT NULL,
    withdraw_request_id uuid,
    CONSTRAINT wallet_holds_amount_iqd_check CHECK ((amount_iqd > 0))
);


ALTER TABLE public.wallet_holds OWNER TO postgres;

--
-- TOC entry 438 (class 1259 OID 40053)

--

CREATE TABLE public.wallet_withdraw_payout_methods (
    payout_kind public.withdraw_payout_kind NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid
);


ALTER TABLE public.wallet_withdraw_payout_methods OWNER TO postgres;

--
-- TOC entry 439 (class 1259 OID 40059)

--

CREATE TABLE public.wallet_withdraw_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    amount_iqd bigint NOT NULL,
    payout_kind public.withdraw_payout_kind NOT NULL,
    destination jsonb DEFAULT '{}'::jsonb NOT NULL,
    status public.withdraw_request_status DEFAULT 'requested'::public.withdraw_request_status NOT NULL,
    note text,
    payout_reference text,
    idempotency_key text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    approved_at timestamp with time zone,
    paid_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    rejected_at timestamp with time zone,
    CONSTRAINT wallet_withdraw_requests_amount_iqd_check CHECK ((amount_iqd > 0))
);


ALTER TABLE public.wallet_withdraw_requests OWNER TO postgres;

--
-- TOC entry 440 (class 1259 OID 40070)

--

CREATE TABLE public.wallet_withdrawal_policy (
    id integer DEFAULT 1 NOT NULL,
    min_amount_iqd bigint DEFAULT 5000 NOT NULL,
    max_amount_iqd bigint DEFAULT 2000000 NOT NULL,
    daily_cap_amount_iqd bigint DEFAULT 5000000 NOT NULL,
    daily_cap_count integer DEFAULT 5 NOT NULL,
    require_kyc boolean DEFAULT false NOT NULL,
    require_driver_not_suspended boolean DEFAULT true NOT NULL,
    min_trips_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid,
    CONSTRAINT wallet_withdrawal_policy_id_check CHECK ((id = 1))
);


ALTER TABLE public.wallet_withdrawal_policy OWNER TO postgres;

--
-- TOC entry 490 (class 1259 OID 44046)

--

CREATE TABLE public.whatsapp_booking_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    thread_id uuid NOT NULL,
    token text NOT NULL,
    token_hash text,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    used_by uuid,
    pickup_lat double precision NOT NULL,
    pickup_lng double precision NOT NULL,
    dropoff_lat double precision NOT NULL,
    dropoff_lng double precision NOT NULL,
    pickup_address text,
    dropoff_address text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT whatsapp_booking_tokens_dropoff_lat_check CHECK (((dropoff_lat >= ('-90'::integer)::double precision) AND (dropoff_lat <= (90)::double precision))),
    CONSTRAINT whatsapp_booking_tokens_dropoff_lng_check CHECK (((dropoff_lng >= ('-180'::integer)::double precision) AND (dropoff_lng <= (180)::double precision))),
    CONSTRAINT whatsapp_booking_tokens_pickup_lat_check CHECK (((pickup_lat >= ('-90'::integer)::double precision) AND (pickup_lat <= (90)::double precision))),
    CONSTRAINT whatsapp_booking_tokens_pickup_lng_check CHECK (((pickup_lng >= ('-180'::integer)::double precision) AND (pickup_lng <= (180)::double precision)))
);


ALTER TABLE public.whatsapp_booking_tokens OWNER TO postgres;

--
-- TOC entry 489 (class 1259 OID 44029)

--

CREATE TABLE public.whatsapp_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    thread_id uuid NOT NULL,
    wa_message_id text,
    direction text NOT NULL,
    msg_type text NOT NULL,
    body text,
    payload jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    template_name text,
    template_lang text,
    template_components jsonb,
    provider_message_id text,
    wa_status text,
    delivered_at timestamp with time zone,
    read_at timestamp with time zone,
    failed_at timestamp with time zone,
    status_payload jsonb,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT whatsapp_messages_direction_check CHECK ((direction = ANY (ARRAY['in'::text, 'out'::text])))
);


ALTER TABLE public.whatsapp_messages OWNER TO postgres;

--
-- TOC entry 492 (class 1259 OID 44107)

--

CREATE TABLE public.whatsapp_thread_notes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    thread_id uuid NOT NULL,
    author_id uuid NOT NULL,
    body text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.whatsapp_thread_notes OWNER TO postgres;

--
-- TOC entry 488 (class 1259 OID 44012)

--

CREATE TABLE public.whatsapp_threads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    wa_id text NOT NULL,
    phone_e164 text,
    stage text DEFAULT 'awaiting_pickup'::text NOT NULL,
    pickup_lat double precision,
    pickup_lng double precision,
    dropoff_lat double precision,
    dropoff_lng double precision,
    pickup_address text,
    dropoff_address text,
    last_inbound_at timestamp with time zone,
    last_outbound_at timestamp with time zone,
    last_message_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    op_status text DEFAULT 'open'::text NOT NULL,
    assigned_admin_id uuid,
    assigned_at timestamp with time zone,
    needs_followup boolean DEFAULT false NOT NULL,
    followup_reason text,
    followup_at timestamp with time zone,
    last_failed_outbound_at timestamp with time zone,
    last_failed_outbound_message_id text,
    CONSTRAINT whatsapp_threads_op_status_check CHECK ((op_status = ANY (ARRAY['open'::text, 'waiting_user'::text, 'waiting_operator'::text, 'resolved'::text]))),
    CONSTRAINT whatsapp_threads_stage_check CHECK ((stage = ANY (ARRAY['awaiting_pickup'::text, 'awaiting_dropoff'::text, 'ready'::text, 'closed'::text])))
);


ALTER TABLE public.whatsapp_threads OWNER TO postgres;

--
-- TOC entry 491 (class 1259 OID 44085)

--

CREATE VIEW public.whatsapp_threads_admin_v1 WITH (security_invoker='true') AS
 SELECT id,
    wa_id,
    phone_e164,
    stage,
    pickup_lat,
    pickup_lng,
    dropoff_lat,
    dropoff_lng,
    pickup_address,
    dropoff_address,
    last_inbound_at,
    last_outbound_at,
    last_message_at,
    created_at,
    updated_at,
        CASE
            WHEN (last_inbound_at IS NULL) THEN false
            WHEN (last_inbound_at >= (now() - '24:00:00'::interval)) THEN true
            ELSE false
        END AS csw_open,
        CASE
            WHEN (last_inbound_at IS NULL) THEN NULL::timestamp with time zone
            ELSE (last_inbound_at + '24:00:00'::interval)
        END AS csw_expires_at,
        CASE
            WHEN (last_inbound_at IS NULL) THEN NULL::bigint
            ELSE (GREATEST((0)::numeric, floor(EXTRACT(epoch FROM ((last_inbound_at + '24:00:00'::interval) - now())))))::bigint
        END AS csw_seconds_left
   FROM public.whatsapp_threads t;


ALTER VIEW public.whatsapp_threads_admin_v1 OWNER TO postgres;

--
-- TOC entry 493 (class 1259 OID 44131)

--

CREATE VIEW public.whatsapp_threads_admin_v2 WITH (security_invoker='true') AS
 SELECT id,
    wa_id,
    phone_e164,
    stage,
    pickup_lat,
    pickup_lng,
    dropoff_lat,
    dropoff_lng,
    pickup_address,
    dropoff_address,
    last_inbound_at,
    last_outbound_at,
    last_message_at,
    created_at,
    updated_at,
    op_status,
    assigned_admin_id,
    assigned_at,
    needs_followup,
    followup_reason,
    followup_at,
    last_failed_outbound_at,
    last_failed_outbound_message_id,
        CASE
            WHEN (last_inbound_at IS NULL) THEN false
            WHEN (last_inbound_at >= (now() - '24:00:00'::interval)) THEN true
            ELSE false
        END AS csw_open,
        CASE
            WHEN (last_inbound_at IS NULL) THEN NULL::timestamp with time zone
            ELSE (last_inbound_at + '24:00:00'::interval)
        END AS csw_expires_at,
        CASE
            WHEN (last_inbound_at IS NULL) THEN NULL::bigint
            ELSE (GREATEST((0)::numeric, floor(EXTRACT(epoch FROM ((last_inbound_at + '24:00:00'::interval) - now())))))::bigint
        END AS csw_seconds_left,
        CASE
            WHEN (last_inbound_at IS NULL) THEN NULL::bigint
            ELSE (floor(EXTRACT(epoch FROM (now() - last_inbound_at))))::bigint
        END AS sla_seconds_since_last_inbound,
        CASE
            WHEN (last_message_at IS NULL) THEN NULL::bigint
            ELSE (floor(EXTRACT(epoch FROM (now() - last_message_at))))::bigint
        END AS sla_seconds_since_last_message
   FROM public.whatsapp_threads t;


ALTER VIEW public.whatsapp_threads_admin_v2 OWNER TO postgres;

--
-- TOC entry 383 (class 1259 OID 17239)

--

ALTER TABLE ONLY public.device_tokens ALTER COLUMN id SET DEFAULT nextval('public.device_tokens_id_seq'::regclass);


--
-- TOC entry 5357 (class 2604 OID 40611)

--

ALTER TABLE ONLY public.notification_outbox ALTER COLUMN id SET DEFAULT nextval('public.notification_outbox_id_seq'::regclass);


--
-- TOC entry 5281 (class 2604 OID 40084)

--

ALTER TABLE ONLY public.provider_events ALTER COLUMN id SET DEFAULT nextval('public.provider_events_id_seq'::regclass);


--
-- TOC entry 5284 (class 2604 OID 40085)

--

ALTER TABLE ONLY public.ride_events ALTER COLUMN id SET DEFAULT nextval('public.ride_events_id_seq'::regclass);


--
-- TOC entry 5322 (class 2604 OID 40086)

--

ALTER TABLE ONLY public.wallet_entries ALTER COLUMN id SET DEFAULT nextval('public.wallet_entries_id_seq'::regclass);


--
-- TOC entry 5683 (class 2606 OID 16783)

--

ALTER TABLE ONLY public.achievement_progress
    ADD CONSTRAINT achievement_progress_pkey PRIMARY KEY (id);


--
-- TOC entry 5983 (class 2606 OID 40706)

--

ALTER TABLE ONLY public.achievement_progress
    ADD CONSTRAINT achievement_progress_user_id_achievement_id_key UNIQUE (user_id, achievement_id);


--
-- TOC entry 5976 (class 2606 OID 41850)

--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_key_unique UNIQUE (key);


--
-- TOC entry 5978 (class 2606 OID 40693)

--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- TOC entry 5827 (class 2606 OID 40088)

--

ALTER TABLE ONLY public.api_rate_limits
    ADD CONSTRAINT api_rate_limits_pkey PRIMARY KEY (key, window_start, window_seconds);


--
-- TOC entry 5829 (class 2606 OID 40090)

--

ALTER TABLE ONLY public.app_events
    ADD CONSTRAINT app_events_pkey PRIMARY KEY (id);


--
-- TOC entry 5950 (class 2606 OID 40593)

--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5952 (class 2606 OID 40595)

--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_token_key UNIQUE (token);


--
-- TOC entry 5963 (class 2606 OID 40640)

--

ALTER TABLE ONLY public.driver_counters
    ADD CONSTRAINT driver_counters_pkey PRIMARY KEY (driver_id);


--
-- TOC entry 6093 (class 2606 OID 41836)

--

ALTER TABLE ONLY public.driver_leaderboard_daily
    ADD CONSTRAINT driver_leaderboard_daily_pkey PRIMARY KEY (day, driver_id);


--
-- TOC entry 5838 (class 2606 OID 40092)

--

ALTER TABLE ONLY public.driver_locations
    ADD CONSTRAINT driver_locations_pkey PRIMARY KEY (driver_id);


--
-- TOC entry 5969 (class 2606 OID 40671)

--

ALTER TABLE ONLY public.driver_rank_snapshots
    ADD CONSTRAINT driver_rank_snapshots_period_period_start_driver_id_key UNIQUE (period, period_start, driver_id);


--
-- TOC entry 5971 (class 2606 OID 40669)

--

ALTER TABLE ONLY public.driver_rank_snapshots
    ADD CONSTRAINT driver_rank_snapshots_pkey PRIMARY KEY (id);


--
-- TOC entry 5965 (class 2606 OID 40653)

--

ALTER TABLE ONLY public.driver_stats_daily
    ADD CONSTRAINT driver_stats_daily_pkey PRIMARY KEY (driver_id, day);


--
-- TOC entry 5843 (class 2606 OID 40094)

--

ALTER TABLE ONLY public.driver_vehicles
    ADD CONSTRAINT driver_vehicles_driver_id_key UNIQUE (driver_id);


--
-- TOC entry 5845 (class 2606 OID 40096)

--

ALTER TABLE ONLY public.driver_vehicles
    ADD CONSTRAINT driver_vehicles_pkey PRIMARY KEY (id);


--
-- TOC entry 5848 (class 2606 OID 40098)

--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (id);


--
-- TOC entry 5792 (class 2606 OID 40100)

--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_pkey PRIMARY KEY (code);


--
-- TOC entry 6062 (class 2606 OID 41388)

--

ALTER TABLE ONLY public.kyc_document_types
    ADD CONSTRAINT kyc_document_types_key_key UNIQUE (key);


--
-- TOC entry 6064 (class 2606 OID 41386)

--

ALTER TABLE ONLY public.kyc_document_types
    ADD CONSTRAINT kyc_document_types_pkey PRIMARY KEY (id);


--
-- TOC entry 6058 (class 2606 OID 41022)

--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_pkey PRIMARY KEY (id);


--
-- TOC entry 6068 (class 2606 OID 41404)

--

ALTER TABLE ONLY public.kyc_liveness_sessions
    ADD CONSTRAINT kyc_liveness_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 6051 (class 2606 OID 41000)

--

ALTER TABLE ONLY public.kyc_submissions
    ADD CONSTRAINT kyc_submissions_pkey PRIMARY KEY (id);


--
-- TOC entry 5959 (class 2606 OID 40621)

--

ALTER TABLE ONLY public.notification_outbox
    ADD CONSTRAINT notification_outbox_notification_id_key UNIQUE (notification_id);


--
-- TOC entry 5961 (class 2606 OID 40619)

--

ALTER TABLE ONLY public.notification_outbox
    ADD CONSTRAINT notification_outbox_pkey PRIMARY KEY (id);


--
-- TOC entry 5856 (class 2606 OID 40102)

--

ALTER TABLE ONLY public.payment_intents
    ADD CONSTRAINT payment_intents_pkey PRIMARY KEY (id);


--
-- TOC entry 5859 (class 2606 OID 40104)

--

ALTER TABLE ONLY public.payment_providers
    ADD CONSTRAINT payment_providers_pkey PRIMARY KEY (code);


--
-- TOC entry 5864 (class 2606 OID 40106)

--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 5868 (class 2606 OID 40108)

--

ALTER TABLE ONLY public.pricing_configs
    ADD CONSTRAINT pricing_configs_pkey PRIMARY KEY (id);


--
-- TOC entry 5872 (class 2606 OID 40110)

--

ALTER TABLE ONLY public.profile_kyc
    ADD CONSTRAINT profile_kyc_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5876 (class 2606 OID 40112)

--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 5879 (class 2606 OID 40114)

--

ALTER TABLE ONLY public.provider_events
    ADD CONSTRAINT provider_events_pkey PRIMARY KEY (id);


--
-- TOC entry 5948 (class 2606 OID 40573)

--

ALTER TABLE ONLY public.public_profiles
    ADD CONSTRAINT public_profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 5987 (class 2606 OID 40735)

--

ALTER TABLE ONLY public.referral_campaigns
    ADD CONSTRAINT referral_campaigns_key_key UNIQUE (key);


--
-- TOC entry 5989 (class 2606 OID 40733)

--

ALTER TABLE ONLY public.referral_campaigns
    ADD CONSTRAINT referral_campaigns_pkey PRIMARY KEY (id);


--
-- TOC entry 5992 (class 2606 OID 40743)

--

ALTER TABLE ONLY public.referral_codes
    ADD CONSTRAINT referral_codes_pkey PRIMARY KEY (code);


--
-- TOC entry 5994 (class 2606 OID 40745)

--

ALTER TABLE ONLY public.referral_codes
    ADD CONSTRAINT referral_codes_user_id_key UNIQUE (user_id);


--
-- TOC entry 6089 (class 2606 OID 41798)

--

ALTER TABLE ONLY public.referral_invites
    ADD CONSTRAINT referral_invites_pkey PRIMARY KEY (id);


--
-- TOC entry 6091 (class 2606 OID 41800)

--

ALTER TABLE ONLY public.referral_invites
    ADD CONSTRAINT referral_invites_referred_user_id_key UNIQUE (referred_user_id);


--
-- TOC entry 5998 (class 2606 OID 40762)

--

ALTER TABLE ONLY public.referral_redemptions
    ADD CONSTRAINT referral_redemptions_pkey PRIMARY KEY (id);


--
-- TOC entry 6000 (class 2606 OID 40764)

--

ALTER TABLE ONLY public.referral_redemptions
    ADD CONSTRAINT referral_redemptions_referred_id_key UNIQUE (referred_id);


--
-- TOC entry 6086 (class 2606 OID 41787)

--

ALTER TABLE ONLY public.referral_settings
    ADD CONSTRAINT referral_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 6026 (class 2606 OID 40899)

--

ALTER TABLE ONLY public.ride_chat_messages
    ADD CONSTRAINT ride_chat_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 6030 (class 2606 OID 40922)

--

ALTER TABLE ONLY public.ride_chat_read_receipts
    ADD CONSTRAINT ride_chat_read_receipts_message_id_reader_id_key UNIQUE (message_id, reader_id);


--
-- TOC entry 6032 (class 2606 OID 40920)

--

ALTER TABLE ONLY public.ride_chat_read_receipts
    ADD CONSTRAINT ride_chat_read_receipts_pkey PRIMARY KEY (id);


--
-- TOC entry 6082 (class 2606 OID 41747)

--

ALTER TABLE ONLY public.ride_chat_threads
    ADD CONSTRAINT ride_chat_threads_pkey PRIMARY KEY (id);


--
-- TOC entry 6084 (class 2606 OID 41749)

--

ALTER TABLE ONLY public.ride_chat_threads
    ADD CONSTRAINT ride_chat_threads_ride_id_key UNIQUE (ride_id);


--
-- TOC entry 6036 (class 2606 OID 40945)

--

ALTER TABLE ONLY public.ride_chat_typing
    ADD CONSTRAINT ride_chat_typing_pkey PRIMARY KEY (ride_id, profile_id);


--
-- TOC entry 6078 (class 2606 OID 41722)

--

ALTER TABLE ONLY public.ride_completion_log
    ADD CONSTRAINT ride_completion_log_pkey PRIMARY KEY (ride_id);


--
-- TOC entry 5885 (class 2606 OID 40116)

--

ALTER TABLE ONLY public.ride_events
    ADD CONSTRAINT ride_events_pkey PRIMARY KEY (id);


--
-- TOC entry 5895 (class 2606 OID 40118)

--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_pkey PRIMARY KEY (id);


--
-- TOC entry 6119 (class 2606 OID 43634)

--

ALTER TABLE ONLY public.ride_intents
    ADD CONSTRAINT ride_intents_pkey PRIMARY KEY (id);


--
-- TOC entry 6060 (class 2606 OID 41210)

--

ALTER TABLE ONLY public.ride_products
    ADD CONSTRAINT ride_products_pkey PRIMARY KEY (code);


--
-- TOC entry 5900 (class 2606 OID 40120)

--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_pkey PRIMARY KEY (id);


--
-- TOC entry 5905 (class 2606 OID 40122)

--

ALTER TABLE ONLY public.ride_receipts
    ADD CONSTRAINT ride_receipts_pkey PRIMARY KEY (ride_id);


--
-- TOC entry 5913 (class 2606 OID 40124)

--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_pkey PRIMARY KEY (id);


--
-- TOC entry 6146 (class 2606 OID 43838)

--

ALTER TABLE ONLY public.ridecheck_events
    ADD CONSTRAINT ridecheck_events_pkey PRIMARY KEY (id);


--
-- TOC entry 6152 (class 2606 OID 43855)

--

ALTER TABLE ONLY public.ridecheck_responses
    ADD CONSTRAINT ridecheck_responses_pkey PRIMARY KEY (id);


--
-- TOC entry 6143 (class 2606 OID 43821)

--

ALTER TABLE ONLY public.ridecheck_state
    ADD CONSTRAINT ridecheck_state_pkey PRIMARY KEY (ride_id);


--
-- TOC entry 5811 (class 2606 OID 40126)

--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_pkey PRIMARY KEY (id);


--
-- TOC entry 5813 (class 2606 OID 40128)

--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_request_id_key UNIQUE (request_id);


--
-- TOC entry 6105 (class 2606 OID 43556)

--

ALTER TABLE ONLY public.scheduled_rides
    ADD CONSTRAINT scheduled_rides_pkey PRIMARY KEY (id);


--
-- TOC entry 6110 (class 2606 OID 43589)

--

ALTER TABLE ONLY public.service_areas
    ADD CONSTRAINT service_areas_name_governorate_key UNIQUE (name, governorate);


--
-- TOC entry 6112 (class 2606 OID 43587)

--

ALTER TABLE ONLY public.service_areas
    ADD CONSTRAINT service_areas_pkey PRIMARY KEY (id);


--
-- TOC entry 6123 (class 2606 OID 43686)

--

ALTER TABLE ONLY public.sos_events
    ADD CONSTRAINT sos_events_pkey PRIMARY KEY (id);


--
-- TOC entry 6132 (class 2606 OID 43729)

--

ALTER TABLE ONLY public.support_articles
    ADD CONSTRAINT support_articles_pkey PRIMARY KEY (id);


--
-- TOC entry 6134 (class 2606 OID 43731)

--

ALTER TABLE ONLY public.support_articles
    ADD CONSTRAINT support_articles_slug_key UNIQUE (slug);


--
-- TOC entry 6005 (class 2606 OID 41329)

--

ALTER TABLE ONLY public.support_categories
    ADD CONSTRAINT support_categories_id_unique UNIQUE (id);


--
-- TOC entry 6007 (class 2606 OID 41331)

--

ALTER TABLE ONLY public.support_categories
    ADD CONSTRAINT support_categories_key_unique UNIQUE (key);


--
-- TOC entry 6009 (class 2606 OID 40832)

--

ALTER TABLE ONLY public.support_categories
    ADD CONSTRAINT support_categories_pkey PRIMARY KEY (code);


--
-- TOC entry 6021 (class 2606 OID 40869)

--

ALTER TABLE ONLY public.support_messages
    ADD CONSTRAINT support_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 6126 (class 2606 OID 43716)

--

ALTER TABLE ONLY public.support_sections
    ADD CONSTRAINT support_sections_key_key UNIQUE (key);


--
-- TOC entry 6128 (class 2606 OID 43714)

--

ALTER TABLE ONLY public.support_sections
    ADD CONSTRAINT support_sections_pkey PRIMARY KEY (id);


--
-- TOC entry 6016 (class 2606 OID 40844)

--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_pkey PRIMARY KEY (id);


--
-- TOC entry 5821 (class 2606 OID 40130)

--

ALTER TABLE ONLY public.topup_intents
    ADD CONSTRAINT topup_intents_pkey PRIMARY KEY (id);


--
-- TOC entry 5916 (class 2606 OID 40132)

--

ALTER TABLE ONLY public.topup_packages
    ADD CONSTRAINT topup_packages_pkey PRIMARY KEY (id);


--
-- TOC entry 6042 (class 2606 OID 40969)

--

ALTER TABLE ONLY public.trip_share_tokens
    ADD CONSTRAINT trip_share_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 6044 (class 2606 OID 40971)

--

ALTER TABLE ONLY public.trip_share_tokens
    ADD CONSTRAINT trip_share_tokens_token_key UNIQUE (token);


--
-- TOC entry 6141 (class 2606 OID 43777)

--

ALTER TABLE ONLY public.trusted_contact_events
    ADD CONSTRAINT trusted_contact_events_pkey PRIMARY KEY (id);


--
-- TOC entry 6159 (class 2606 OID 43981)

--

ALTER TABLE ONLY public.trusted_contact_outbox
    ADD CONSTRAINT trusted_contact_outbox_pkey PRIMARY KEY (id);


--
-- TOC entry 6003 (class 2606 OID 40799)

--

ALTER TABLE ONLY public.trusted_contacts
    ADD CONSTRAINT trusted_contacts_pkey PRIMARY KEY (id);


--
-- TOC entry 6074 (class 2606 OID 41709)

--

ALTER TABLE ONLY public.user_device_tokens
    ADD CONSTRAINT user_device_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 6076 (class 2606 OID 41711)

--

ALTER TABLE ONLY public.user_device_tokens
    ADD CONSTRAINT user_device_tokens_user_id_device_id_key UNIQUE (user_id, device_id);


--
-- TOC entry 5921 (class 2606 OID 40134)

--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 6136 (class 2606 OID 43757)

--

ALTER TABLE ONLY public.user_safety_settings
    ADD CONSTRAINT user_safety_settings_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5825 (class 2606 OID 40136)

--

ALTER TABLE ONLY public.wallet_accounts
    ADD CONSTRAINT wallet_accounts_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5926 (class 2606 OID 40138)

--

ALTER TABLE ONLY public.wallet_entries
    ADD CONSTRAINT wallet_entries_pkey PRIMARY KEY (id);


--
-- TOC entry 5934 (class 2606 OID 40140)

--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_pkey PRIMARY KEY (id);


--
-- TOC entry 5937 (class 2606 OID 40142)

--

ALTER TABLE ONLY public.wallet_withdraw_payout_methods
    ADD CONSTRAINT wallet_withdraw_payout_methods_pkey PRIMARY KEY (payout_kind);


--
-- TOC entry 5943 (class 2606 OID 40144)

--

ALTER TABLE ONLY public.wallet_withdraw_requests
    ADD CONSTRAINT wallet_withdraw_requests_pkey PRIMARY KEY (id);


--
-- TOC entry 5946 (class 2606 OID 40146)

--

ALTER TABLE ONLY public.wallet_withdrawal_policy
    ADD CONSTRAINT wallet_withdrawal_policy_pkey PRIMARY KEY (id);


--
-- TOC entry 6182 (class 2606 OID 44058)

--

ALTER TABLE ONLY public.whatsapp_booking_tokens
    ADD CONSTRAINT whatsapp_booking_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 6184 (class 2606 OID 44062)

--

ALTER TABLE ONLY public.whatsapp_booking_tokens
    ADD CONSTRAINT whatsapp_booking_tokens_token_hash_uniq UNIQUE (token_hash);


--
-- TOC entry 6186 (class 2606 OID 44060)

--

ALTER TABLE ONLY public.whatsapp_booking_tokens
    ADD CONSTRAINT whatsapp_booking_tokens_token_uniq UNIQUE (token);


--
-- TOC entry 6176 (class 2606 OID 44038)

--

ALTER TABLE ONLY public.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 6190 (class 2606 OID 44115)

--

ALTER TABLE ONLY public.whatsapp_thread_notes
    ADD CONSTRAINT whatsapp_thread_notes_pkey PRIMARY KEY (id);


--
-- TOC entry 6167 (class 2606 OID 44023)

--

ALTER TABLE ONLY public.whatsapp_threads
    ADD CONSTRAINT whatsapp_threads_pkey PRIMARY KEY (id);


--
-- TOC entry 6169 (class 2606 OID 44025)

--

ALTER TABLE ONLY public.whatsapp_threads
    ADD CONSTRAINT whatsapp_threads_wa_id_uniq UNIQUE (wa_id);


--
-- TOC entry 5742 (class 2606 OID 17253)

--

CREATE UNIQUE INDEX achievements_unique_active_scope ON public.achievements USING btree (role, metric, target) WHERE (active = true);


--
-- TOC entry 6113 (class 1259 OID 43649)

--

CREATE INDEX idx_ride_intents_pickup_loc_gist ON public.ride_intents USING gist (pickup_loc);


--
-- TOC entry 6114 (class 1259 OID 43646)

--

CREATE INDEX idx_ride_intents_rider_created_at ON public.ride_intents USING btree (rider_id, created_at DESC);


--
-- TOC entry 6115 (class 1259 OID 43648)

--

CREATE INDEX idx_ride_intents_service_area ON public.ride_intents USING btree (service_area_id);


--
-- TOC entry 6116 (class 1259 OID 43647)

--

CREATE INDEX idx_ride_intents_status_created_at ON public.ride_intents USING btree (status, created_at DESC);


--
-- TOC entry 6099 (class 1259 OID 43568)

--

CREATE INDEX idx_scheduled_rides_due ON public.scheduled_rides USING btree (scheduled_at) WHERE (status = 'pending'::public.scheduled_ride_status);


--
-- TOC entry 6100 (class 1259 OID 43569)

--

CREATE UNIQUE INDEX idx_scheduled_rides_request_id ON public.scheduled_rides USING btree (ride_request_id) WHERE (ride_request_id IS NOT NULL);


--
-- TOC entry 6101 (class 1259 OID 43567)

--

CREATE INDEX idx_scheduled_rides_rider_time ON public.scheduled_rides USING btree (rider_id, scheduled_at DESC);


--
-- TOC entry 6102 (class 1259 OID 43674)

--

CREATE INDEX idx_scheduled_rides_status_time ON public.scheduled_rides USING btree (status, scheduled_at DESC);


--
-- TOC entry 6106 (class 1259 OID 43596)

--

CREATE INDEX idx_service_areas_active_priority ON public.service_areas USING btree (is_active, priority DESC);


--
-- TOC entry 6107 (class 1259 OID 43597)

--

CREATE INDEX idx_service_areas_geom_gist ON public.service_areas USING gist (geom);


--
-- TOC entry 6153 (class 1259 OID 44003)

--

CREATE INDEX idx_trusted_contact_outbox_pending ON public.trusted_contact_outbox USING btree (status, next_attempt_at, created_at);


--
-- TOC entry 6154 (class 1259 OID 44010)

--

CREATE INDEX idx_trusted_contact_outbox_status_next ON public.trusted_contact_outbox USING btree (status, next_attempt_at);


--
-- TOC entry 6155 (class 1259 OID 44004)

--

CREATE INDEX idx_trusted_contact_outbox_user ON public.trusted_contact_outbox USING btree (user_id, created_at DESC);


--
-- TOC entry 6177 (class 1259 OID 44073)

--

CREATE INDEX idx_whatsapp_booking_tokens_expires_at ON public.whatsapp_booking_tokens USING btree (expires_at);


--
-- TOC entry 6178 (class 1259 OID 44074)

--

CREATE INDEX idx_whatsapp_booking_tokens_used_at ON public.whatsapp_booking_tokens USING btree (used_at);


--
-- TOC entry 6170 (class 1259 OID 44092)

--

CREATE INDEX idx_whatsapp_messages_provider_message_id ON public.whatsapp_messages USING btree (provider_message_id) WHERE (provider_message_id IS NOT NULL);


--
-- TOC entry 6171 (class 1259 OID 44084)

--

CREATE INDEX idx_whatsapp_messages_template_name ON public.whatsapp_messages USING btree (template_name) WHERE (template_name IS NOT NULL);


--
-- TOC entry 6172 (class 1259 OID 44045)

--

CREATE INDEX idx_whatsapp_messages_thread_created_at ON public.whatsapp_messages USING btree (thread_id, created_at DESC);


--
-- TOC entry 6173 (class 1259 OID 44093)

--

CREATE INDEX idx_whatsapp_messages_wa_status ON public.whatsapp_messages USING btree (wa_status) WHERE (wa_status IS NOT NULL);


--
-- TOC entry 6187 (class 1259 OID 44128)

--

CREATE INDEX idx_whatsapp_thread_notes_thread_created_at ON public.whatsapp_thread_notes USING btree (thread_id, created_at DESC);


--
-- TOC entry 6161 (class 1259 OID 44104)

--

CREATE INDEX idx_whatsapp_threads_assigned_admin ON public.whatsapp_threads USING btree (assigned_admin_id) WHERE (assigned_admin_id IS NOT NULL);


--
-- TOC entry 6162 (class 1259 OID 44027)

--

CREATE INDEX idx_whatsapp_threads_last_message_at ON public.whatsapp_threads USING btree (last_message_at DESC);


--
-- TOC entry 6163 (class 1259 OID 44105)

--

CREATE INDEX idx_whatsapp_threads_needs_followup ON public.whatsapp_threads USING btree (needs_followup) WHERE (needs_followup = true);


--
-- TOC entry 6164 (class 1259 OID 44106)

--

CREATE INDEX idx_whatsapp_threads_op_status_last_message ON public.whatsapp_threads USING btree (op_status, last_message_at DESC);


--
-- TOC entry 6165 (class 1259 OID 44028)

--

CREATE INDEX idx_whatsapp_threads_stage_last_message_at ON public.whatsapp_threads USING btree (stage, last_message_at DESC);


--
-- TOC entry 5984 (class 1259 OID 42071)

--

CREATE INDEX ix_achievement_progress_achievement_id ON public.achievement_progress USING btree (achievement_id);


--
-- TOC entry 5985 (class 1259 OID 40717)

--

CREATE INDEX ix_achievement_progress_user ON public.achievement_progress USING btree (user_id);


--
-- TOC entry 5830 (class 1259 OID 40147)

--

CREATE INDEX ix_app_events_actor_id ON public.app_events USING btree (actor_id);


--
-- TOC entry 5831 (class 1259 OID 40148)

--

CREATE INDEX ix_app_events_created_at ON public.app_events USING btree (created_at DESC);


--
-- TOC entry 5832 (class 1259 OID 40149)

--

CREATE INDEX ix_app_events_event_type ON public.app_events USING btree (event_type);


--
-- TOC entry 5833 (class 1259 OID 40150)

--

CREATE INDEX ix_app_events_level ON public.app_events USING btree (level);


--
-- TOC entry 5834 (class 1259 OID 40151)

--

CREATE INDEX ix_app_events_payment_intent_id ON public.app_events USING btree (payment_intent_id);


--
-- TOC entry 5835 (class 1259 OID 40152)

--

CREATE INDEX ix_app_events_request_id ON public.app_events USING btree (request_id);


--
-- TOC entry 5836 (class 1259 OID 40153)

--

CREATE INDEX ix_app_events_ride_id ON public.app_events USING btree (ride_id);


--
-- TOC entry 5953 (class 1259 OID 41735)

--

CREATE INDEX ix_device_tokens_user_enabled ON public.device_tokens USING btree (user_id, enabled) WHERE (enabled = true);


--
-- TOC entry 5954 (class 1259 OID 40601)

--

CREATE INDEX ix_device_tokens_user_id ON public.device_tokens USING btree (user_id);


--
-- TOC entry 6094 (class 1259 OID 41842)

--

CREATE INDEX ix_driver_leaderboard_daily_day_rank ON public.driver_leaderboard_daily USING btree (day DESC, rank);


--
-- TOC entry 6095 (class 1259 OID 42072)

--

CREATE INDEX ix_driver_leaderboard_daily_driver_id ON public.driver_leaderboard_daily USING btree (driver_id);


--
-- TOC entry 5839 (class 1259 OID 40154)

--

CREATE INDEX ix_driver_locations_driver_locations_driver_id_fkey_fkey ON public.driver_locations USING btree (driver_id);


--
-- TOC entry 5840 (class 1259 OID 40155)

--

CREATE INDEX ix_driver_locations_loc_gist ON public.driver_locations USING gist (loc);


--
-- TOC entry 5841 (class 1259 OID 40156)

--

CREATE INDEX ix_driver_locations_updated_at ON public.driver_locations USING btree (updated_at DESC);


--
-- TOC entry 5972 (class 1259 OID 42073)

--

CREATE INDEX ix_driver_rank_snapshots_driver_id ON public.driver_rank_snapshots USING btree (driver_id);


--
-- TOC entry 5973 (class 1259 OID 40677)

--

CREATE INDEX ix_driver_rank_snapshots_period ON public.driver_rank_snapshots USING btree (period, period_start, rank);


--
-- TOC entry 5974 (class 1259 OID 41697)

--

CREATE INDEX ix_driver_rank_snapshots_period_start ON public.driver_rank_snapshots USING btree (period, period_start, score DESC);


--
-- TOC entry 5966 (class 1259 OID 40659)

--

CREATE INDEX ix_driver_stats_daily_day ON public.driver_stats_daily USING btree (day);


--
-- TOC entry 5967 (class 1259 OID 41822)

--

CREATE INDEX ix_driver_stats_daily_driver_day ON public.driver_stats_daily USING btree (driver_id, day DESC);


--
-- TOC entry 5846 (class 1259 OID 40157)

--

CREATE INDEX ix_driver_vehicles_driver_id ON public.driver_vehicles USING btree (driver_id);


--
-- TOC entry 5849 (class 1259 OID 40158)

--

CREATE INDEX ix_drivers_drivers_id_fkey_fkey ON public.drivers USING btree (id);


--
-- TOC entry 5850 (class 1259 OID 40159)

--

CREATE INDEX ix_drivers_rating_avg ON public.drivers USING btree (rating_avg DESC);


--
-- TOC entry 5793 (class 1259 OID 40160)

--

CREATE INDEX ix_gift_codes_created_at ON public.gift_codes USING btree (created_at DESC);


--
-- TOC entry 5794 (class 1259 OID 40161)

--

CREATE INDEX ix_gift_codes_created_by ON public.gift_codes USING btree (created_by);


--
-- TOC entry 5795 (class 1259 OID 40162)

--

CREATE INDEX ix_gift_codes_gift_codes_redeemed_by_fkey_fkey ON public.gift_codes USING btree (redeemed_by);


--
-- TOC entry 5796 (class 1259 OID 40163)

--

CREATE INDEX ix_gift_codes_redeemed_by ON public.gift_codes USING btree (redeemed_by, redeemed_at DESC);


--
-- TOC entry 5797 (class 1259 OID 40164)

--

CREATE INDEX ix_gift_codes_redeemed_entry_id ON public.gift_codes USING btree (redeemed_entry_id);


--
-- TOC entry 6052 (class 1259 OID 41427)

--

CREATE INDEX ix_kyc_documents_document_type_id ON public.kyc_documents USING btree (document_type_id);


--
-- TOC entry 6053 (class 1259 OID 41391)

--

CREATE INDEX ix_kyc_documents_profile_id ON public.kyc_documents USING btree (profile_id);


--
-- TOC entry 6054 (class 1259 OID 41390)

--

CREATE INDEX ix_kyc_documents_submission_id ON public.kyc_documents USING btree (submission_id);


--
-- TOC entry 6055 (class 1259 OID 41033)

--

CREATE INDEX ix_kyc_documents_submission_id_created_at ON public.kyc_documents USING btree (submission_id, created_at);


--
-- TOC entry 6056 (class 1259 OID 41034)

--

CREATE INDEX ix_kyc_documents_user_id_doc_type ON public.kyc_documents USING btree (user_id, doc_type);


--
-- TOC entry 6065 (class 1259 OID 41410)

--

CREATE INDEX ix_kyc_liveness_profile_id ON public.kyc_liveness_sessions USING btree (profile_id);


--
-- TOC entry 6066 (class 1259 OID 42074)

--

CREATE INDEX ix_kyc_liveness_sessions_submission_id ON public.kyc_liveness_sessions USING btree (submission_id);


--
-- TOC entry 6046 (class 1259 OID 41389)

--

CREATE INDEX ix_kyc_submissions_profile_id ON public.kyc_submissions USING btree (profile_id);


--
-- TOC entry 6047 (class 1259 OID 42075)

--

CREATE INDEX ix_kyc_submissions_reviewer_id ON public.kyc_submissions USING btree (reviewer_id);


--
-- TOC entry 6048 (class 1259 OID 41421)

--

CREATE INDEX ix_kyc_submissions_role_context ON public.kyc_submissions USING btree (role_context);


--
-- TOC entry 6049 (class 1259 OID 41011)

--

CREATE INDEX ix_kyc_submissions_user_id_created_at ON public.kyc_submissions USING btree (user_id, created_at DESC);


--
-- TOC entry 5956 (class 1259 OID 40627)

--

CREATE INDEX ix_notification_outbox_status ON public.notification_outbox USING btree (status, id);


--
-- TOC entry 5957 (class 1259 OID 40628)

--

CREATE INDEX ix_notification_outbox_user_id ON public.notification_outbox USING btree (user_id);


--
-- TOC entry 5851 (class 1259 OID 40165)

--

CREATE INDEX ix_payment_intents_provider_charge_id ON public.payment_intents USING btree (provider_charge_id);


--
-- TOC entry 5852 (class 1259 OID 40166)

--

CREATE INDEX ix_payment_intents_provider_payment_intent_id ON public.payment_intents USING btree (provider_payment_intent_id);


--
-- TOC entry 5853 (class 1259 OID 40167)

--

CREATE INDEX ix_payment_intents_provider_session_id ON public.payment_intents USING btree (provider_session_id);


--
-- TOC entry 5854 (class 1259 OID 40168)

--

CREATE INDEX ix_payment_intents_ride_id ON public.payment_intents USING btree (ride_id);


--
-- TOC entry 5860 (class 1259 OID 40169)

--

CREATE INDEX ix_payments_payment_intent_id ON public.payments USING btree (payment_intent_id);


--
-- TOC entry 5861 (class 1259 OID 40170)

--

CREATE INDEX ix_payments_provider_payment_intent_id ON public.payments USING btree (provider_payment_intent_id);


--
-- TOC entry 5862 (class 1259 OID 40171)

--

CREATE INDEX ix_payments_ride_id ON public.payments USING btree (ride_id);


--
-- TOC entry 5869 (class 1259 OID 40172)

--

CREATE INDEX ix_profile_kyc_profile_kyc_user_id_fkey_fkey ON public.profile_kyc USING btree (user_id);


--
-- TOC entry 5870 (class 1259 OID 40173)

--

CREATE INDEX ix_profile_kyc_updated_by ON public.profile_kyc USING btree (updated_by);


--
-- TOC entry 5873 (class 1259 OID 40174)

--

CREATE INDEX ix_profiles_profiles_id_fkey_fkey ON public.profiles USING btree (id);


--
-- TOC entry 5874 (class 1259 OID 40175)

--

CREATE INDEX ix_profiles_rating_avg ON public.profiles USING btree (rating_avg DESC);


--
-- TOC entry 5877 (class 1259 OID 40176)

--

CREATE INDEX ix_provider_events_provider_events_provider_code_fkey_fkey ON public.provider_events USING btree (provider_code);


--
-- TOC entry 5990 (class 1259 OID 40751)

--

CREATE INDEX ix_referral_codes_user_id ON public.referral_codes USING btree (user_id);


--
-- TOC entry 6087 (class 1259 OID 41811)

--

CREATE INDEX ix_referral_invites_referrer_created ON public.referral_invites USING btree (referrer_id, created_at DESC);


--
-- TOC entry 5995 (class 1259 OID 42076)

--

CREATE INDEX ix_referral_redemptions_campaign_id ON public.referral_redemptions USING btree (campaign_id);


--
-- TOC entry 5996 (class 1259 OID 40780)

--

CREATE INDEX ix_referral_redemptions_referrer ON public.referral_redemptions USING btree (referrer_id);


--
-- TOC entry 6022 (class 1259 OID 40910)

--

CREATE INDEX ix_ride_chat_messages_ride_id_created_at ON public.ride_chat_messages USING btree (ride_id, created_at DESC);


--
-- TOC entry 6023 (class 1259 OID 40911)

--

CREATE INDEX ix_ride_chat_messages_sender_id ON public.ride_chat_messages USING btree (sender_id);


--
-- TOC entry 6024 (class 1259 OID 41766)

--

CREATE INDEX ix_ride_chat_messages_thread_created ON public.ride_chat_messages USING btree (thread_id, created_at DESC);


--
-- TOC entry 6027 (class 1259 OID 42077)

--

CREATE INDEX ix_ride_chat_read_receipts_reader_id ON public.ride_chat_read_receipts USING btree (reader_id);


--
-- TOC entry 6028 (class 1259 OID 40938)

--

CREATE INDEX ix_ride_chat_read_receipts_ride_id_reader_id ON public.ride_chat_read_receipts USING btree (ride_id, reader_id);


--
-- TOC entry 6079 (class 1259 OID 42078)

--

CREATE INDEX ix_ride_chat_threads_driver_id ON public.ride_chat_threads USING btree (driver_id);


--
-- TOC entry 6080 (class 1259 OID 42079)

--

CREATE INDEX ix_ride_chat_threads_rider_id ON public.ride_chat_threads USING btree (rider_id);


--
-- TOC entry 6033 (class 1259 OID 42080)

--

CREATE INDEX ix_ride_chat_typing_profile_id ON public.ride_chat_typing USING btree (profile_id);


--
-- TOC entry 6034 (class 1259 OID 40956)

--

CREATE INDEX ix_ride_chat_typing_ride_id_updated_at ON public.ride_chat_typing USING btree (ride_id, updated_at DESC);


--
-- TOC entry 5882 (class 1259 OID 40177)

--

CREATE INDEX ix_ride_events_created_at ON public.ride_events USING btree (created_at DESC);


--
-- TOC entry 5883 (class 1259 OID 40178)

--

CREATE INDEX ix_ride_events_ride_id ON public.ride_events USING btree (ride_id);


--
-- TOC entry 5886 (class 1259 OID 40179)

--

CREATE INDEX ix_ride_incidents_assigned_to ON public.ride_incidents USING btree (assigned_to);


--
-- TOC entry 5887 (class 1259 OID 40180)

--

CREATE INDEX ix_ride_incidents_created_at ON public.ride_incidents USING btree (created_at DESC);


--
-- TOC entry 5888 (class 1259 OID 40823)

--

CREATE INDEX ix_ride_incidents_loc ON public.ride_incidents USING gist (loc);


--
-- TOC entry 5889 (class 1259 OID 40181)

--

CREATE INDEX ix_ride_incidents_reporter_id ON public.ride_incidents USING btree (reporter_id);


--
-- TOC entry 5890 (class 1259 OID 40182)

--

CREATE INDEX ix_ride_incidents_ride_id ON public.ride_incidents USING btree (ride_id);


--
-- TOC entry 5891 (class 1259 OID 40822)

--

CREATE INDEX ix_ride_incidents_ride_id_created_at ON public.ride_incidents USING btree (ride_id, created_at DESC);


--
-- TOC entry 5892 (class 1259 OID 40183)

--

CREATE INDEX ix_ride_incidents_severity ON public.ride_incidents USING btree (severity);


--
-- TOC entry 5893 (class 1259 OID 40184)

--

CREATE INDEX ix_ride_incidents_status ON public.ride_incidents USING btree (status);


--
-- TOC entry 6117 (class 1259 OID 44169)

--

CREATE INDEX ix_ride_intents_converted_request_id_fkey ON public.ride_intents USING btree (converted_request_id);


--
-- TOC entry 5896 (class 1259 OID 40185)

--

CREATE INDEX ix_ride_ratings_ratee_id ON public.ride_ratings USING btree (ratee_id);


--
-- TOC entry 5897 (class 1259 OID 40186)

--

CREATE INDEX ix_ride_ratings_rater_id ON public.ride_ratings USING btree (rater_id);


--
-- TOC entry 5898 (class 1259 OID 40187)

--

CREATE INDEX ix_ride_ratings_ride_id ON public.ride_ratings USING btree (ride_id);


--
-- TOC entry 5902 (class 1259 OID 40188)

--

CREATE INDEX ix_ride_receipts_generated_at ON public.ride_receipts USING btree (generated_at DESC);


--
-- TOC entry 5903 (class 1259 OID 40189)

--

CREATE INDEX ix_ride_receipts_ride_receipts_ride_id_fkey_fkey ON public.ride_receipts USING btree (ride_id);


--
-- TOC entry 5906 (class 1259 OID 40190)

--

CREATE INDEX ix_ride_requests_assigned_driver_id ON public.ride_requests USING btree (assigned_driver_id);


--
-- TOC entry 5907 (class 1259 OID 40191)

--

CREATE INDEX ix_ride_requests_created_at ON public.ride_requests USING btree (created_at DESC);


--
-- TOC entry 5908 (class 1259 OID 42081)

--

CREATE INDEX ix_ride_requests_product_code ON public.ride_requests USING btree (product_code);


--
-- TOC entry 5909 (class 1259 OID 40192)

--

CREATE INDEX ix_ride_requests_rider_id ON public.ride_requests USING btree (rider_id);


--
-- TOC entry 5910 (class 1259 OID 44170)

--

CREATE INDEX ix_ride_requests_service_area_id_fkey ON public.ride_requests USING btree (service_area_id);


--
-- TOC entry 5911 (class 1259 OID 40193)

--

CREATE INDEX ix_ride_requests_status ON public.ride_requests USING btree (status);


--
-- TOC entry 6144 (class 1259 OID 43845)

--

CREATE INDEX ix_ridecheck_events_ride_status_time ON public.ridecheck_events USING btree (ride_id, status, created_at DESC);


--
-- TOC entry 6148 (class 1259 OID 43873)

--

CREATE INDEX ix_ridecheck_responses_event_created ON public.ridecheck_responses USING btree (event_id, created_at DESC);


--
-- TOC entry 6149 (class 1259 OID 44171)

--

CREATE INDEX ix_ridecheck_responses_ride_id_fkey ON public.ridecheck_responses USING btree (ride_id);


--
-- TOC entry 6150 (class 1259 OID 44172)

--

CREATE INDEX ix_ridecheck_responses_user_id_fkey ON public.ridecheck_responses USING btree (user_id);


--
-- TOC entry 5798 (class 1259 OID 40194)

--

CREATE INDEX ix_rides_created_at ON public.rides USING btree (created_at DESC);


--
-- TOC entry 5799 (class 1259 OID 40195)

--

CREATE INDEX ix_rides_driver_created_at ON public.rides USING btree (driver_id, created_at DESC);


--
-- TOC entry 5800 (class 1259 OID 40196)

--

CREATE INDEX ix_rides_driver_id ON public.rides USING btree (driver_id);


--
-- TOC entry 5801 (class 1259 OID 40197)

--

CREATE INDEX ix_rides_paid_at ON public.rides USING btree (paid_at DESC);


--
-- TOC entry 5802 (class 1259 OID 40198)

--

CREATE INDEX ix_rides_payment_intent_id ON public.rides USING btree (payment_intent_id);


--
-- TOC entry 5803 (class 1259 OID 43809)

--

CREATE INDEX ix_rides_pickup_pin_required_status ON public.rides USING btree (pickup_pin_required, status);


--
-- TOC entry 5804 (class 1259 OID 42082)

--

CREATE INDEX ix_rides_product_code ON public.rides USING btree (product_code);


--
-- TOC entry 5805 (class 1259 OID 40199)

--

CREATE INDEX ix_rides_rider_created_at ON public.rides USING btree (rider_id, created_at DESC);


--
-- TOC entry 5806 (class 1259 OID 40200)

--

CREATE INDEX ix_rides_rider_id ON public.rides USING btree (rider_id);


--
-- TOC entry 5807 (class 1259 OID 40201)

--

CREATE INDEX ix_rides_rides_request_id_fkey_fkey ON public.rides USING btree (request_id);


--
-- TOC entry 5808 (class 1259 OID 40202)

--

CREATE INDEX ix_rides_status ON public.rides USING btree (status);


--
-- TOC entry 5809 (class 1259 OID 40203)

--

CREATE INDEX ix_rides_wallet_hold_id ON public.rides USING btree (wallet_hold_id);


--
-- TOC entry 6103 (class 1259 OID 44173)

--

CREATE INDEX ix_scheduled_rides_service_area_id_fkey ON public.scheduled_rides USING btree (service_area_id);


--
-- TOC entry 6108 (class 1259 OID 44174)

--

CREATE INDEX ix_service_areas_pricing_config_id_fkey ON public.service_areas USING btree (pricing_config_id);


--
-- TOC entry 6120 (class 1259 OID 43698)

--

CREATE INDEX ix_sos_events_ride_created ON public.sos_events USING btree (ride_id, created_at DESC);


--
-- TOC entry 6121 (class 1259 OID 43697)

--

CREATE INDEX ix_sos_events_user_created ON public.sos_events USING btree (user_id, created_at DESC);


--
-- TOC entry 6129 (class 1259 OID 43738)

--

CREATE INDEX ix_support_articles_enabled_updated ON public.support_articles USING btree (enabled, updated_at DESC);


--
-- TOC entry 6130 (class 1259 OID 43739)

--

CREATE INDEX ix_support_articles_section ON public.support_articles USING btree (section_id, enabled, updated_at DESC);


--
-- TOC entry 6017 (class 1259 OID 41432)

--

CREATE INDEX ix_support_messages_sender_id ON public.support_messages USING btree (sender_id);


--
-- TOC entry 6018 (class 1259 OID 41431)

--

CREATE INDEX ix_support_messages_ticket_id ON public.support_messages USING btree (ticket_id);


--
-- TOC entry 6019 (class 1259 OID 40880)

--

CREATE INDEX ix_support_messages_ticket_id_created_at ON public.support_messages USING btree (ticket_id, created_at);


--
-- TOC entry 6124 (class 1259 OID 43737)

--

CREATE INDEX ix_support_sections_sort ON public.support_sections USING btree (enabled, sort_order, key);


--
-- TOC entry 6010 (class 1259 OID 42083)

--

CREATE INDEX ix_support_tickets_category_code ON public.support_tickets USING btree (category_code);


--
-- TOC entry 6011 (class 1259 OID 42084)

--

CREATE INDEX ix_support_tickets_category_id ON public.support_tickets USING btree (category_id);


--
-- TOC entry 6012 (class 1259 OID 41430)

--

CREATE INDEX ix_support_tickets_created_by ON public.support_tickets USING btree (created_by);


--
-- TOC entry 6013 (class 1259 OID 40860)

--

CREATE INDEX ix_support_tickets_created_by_status_updated_at ON public.support_tickets USING btree (created_by, status, updated_at DESC);


--
-- TOC entry 6014 (class 1259 OID 42085)

--

CREATE INDEX ix_support_tickets_ride_id ON public.support_tickets USING btree (ride_id);


--
-- TOC entry 5815 (class 1259 OID 40204)

--

CREATE INDEX ix_topup_intents_package_id ON public.topup_intents USING btree (package_id);


--
-- TOC entry 5816 (class 1259 OID 40205)

--

CREATE INDEX ix_topup_intents_provider_code ON public.topup_intents USING btree (provider_code);


--
-- TOC entry 5817 (class 1259 OID 40206)

--

CREATE INDEX ix_topup_intents_status ON public.topup_intents USING btree (status);


--
-- TOC entry 5818 (class 1259 OID 40207)

--

CREATE INDEX ix_topup_intents_topup_intents_user_id_fkey_fkey ON public.topup_intents USING btree (user_id);


--
-- TOC entry 5819 (class 1259 OID 40208)

--

CREATE INDEX ix_topup_intents_user_created ON public.topup_intents USING btree (user_id, created_at DESC);


--
-- TOC entry 6037 (class 1259 OID 42086)

--

CREATE INDEX ix_trip_share_tokens_created_by ON public.trip_share_tokens USING btree (created_by);


--
-- TOC entry 6038 (class 1259 OID 41372)

--

CREATE INDEX ix_trip_share_tokens_ride_id ON public.trip_share_tokens USING btree (ride_id);


--
-- TOC entry 6039 (class 1259 OID 40983)

--

CREATE INDEX ix_trip_share_tokens_ride_id_active ON public.trip_share_tokens USING btree (ride_id, expires_at) WHERE (revoked_at IS NULL);


--
-- TOC entry 6040 (class 1259 OID 40982)

--

CREATE INDEX ix_trip_share_tokens_token ON public.trip_share_tokens USING btree (token);


--
-- TOC entry 6137 (class 1259 OID 44175)

--

CREATE INDEX ix_trusted_contact_events_contact_id_fkey ON public.trusted_contact_events USING btree (contact_id);


--
-- TOC entry 6138 (class 1259 OID 43794)

--

CREATE INDEX ix_trusted_contact_events_ride_id_created_at ON public.trusted_contact_events USING btree (ride_id, created_at DESC);


--
-- TOC entry 6139 (class 1259 OID 43793)

--

CREATE INDEX ix_trusted_contact_events_user_id_created_at ON public.trusted_contact_events USING btree (user_id, created_at DESC);


--
-- TOC entry 6156 (class 1259 OID 44176)

--

CREATE INDEX ix_trusted_contact_outbox_ride_id_fkey ON public.trusted_contact_outbox USING btree (ride_id);


--
-- TOC entry 6157 (class 1259 OID 44177)

--

CREATE INDEX ix_trusted_contact_outbox_sos_event_id_fkey ON public.trusted_contact_outbox USING btree (sos_event_id);


--
-- TOC entry 6001 (class 1259 OID 40805)

--

CREATE INDEX ix_trusted_contacts_user_id_active ON public.trusted_contacts USING btree (user_id, is_active);


--
-- TOC entry 6072 (class 1259 OID 41712)

--

CREATE INDEX ix_user_device_tokens_user_id ON public.user_device_tokens USING btree (user_id);


--
-- TOC entry 5918 (class 1259 OID 43666)

--

CREATE INDEX ix_user_notifications_unread ON public.user_notifications USING btree (user_id) WHERE (read_at IS NULL);


--
-- TOC entry 5919 (class 1259 OID 40209)

--

CREATE INDEX ix_user_notifications_user_created ON public.user_notifications USING btree (user_id, created_at DESC);


--
-- TOC entry 5823 (class 1259 OID 40211)

--

CREATE INDEX ix_wallet_accounts_wallet_accounts_user_id_fkey_fkey ON public.wallet_accounts USING btree (user_id);


--
-- TOC entry 5922 (class 1259 OID 40212)

--

CREATE INDEX ix_wallet_entries_user_created ON public.wallet_entries USING btree (user_id, created_at DESC);


--
-- TOC entry 5923 (class 1259 OID 40213)

--

CREATE INDEX ix_wallet_entries_wallet_entries_user_id_fkey_fkey ON public.wallet_entries USING btree (user_id);


--
-- TOC entry 5927 (class 1259 OID 40214)

--

CREATE INDEX ix_wallet_holds_ride_id ON public.wallet_holds USING btree (ride_id);


--
-- TOC entry 5928 (class 1259 OID 40215)

--

CREATE INDEX ix_wallet_holds_user_created ON public.wallet_holds USING btree (user_id, created_at DESC);


--
-- TOC entry 5929 (class 1259 OID 40216)

--

CREATE INDEX ix_wallet_holds_wallet_holds_user_id_fkey_fkey ON public.wallet_holds USING btree (user_id);


--
-- TOC entry 5930 (class 1259 OID 40217)

--

CREATE INDEX ix_wallet_holds_withdraw_request ON public.wallet_holds USING btree (withdraw_request_id);


--
-- TOC entry 5935 (class 1259 OID 40218)

--

CREATE INDEX ix_wallet_withdraw_payout_methods_updated_by ON public.wallet_withdraw_payout_methods USING btree (updated_by);


--
-- TOC entry 5938 (class 1259 OID 40219)

--

CREATE INDEX ix_wallet_withdraw_requ_67e67264c160fa61_fkey ON public.wallet_withdraw_requests USING btree (user_id);


--
-- TOC entry 5939 (class 1259 OID 40220)

--

CREATE INDEX ix_wallet_withdraw_requests_status_created ON public.wallet_withdraw_requests USING btree (status, created_at DESC);


--
-- TOC entry 5940 (class 1259 OID 40221)

--

CREATE INDEX ix_wallet_withdraw_requests_user_created ON public.wallet_withdraw_requests USING btree (user_id, created_at DESC);


--
-- TOC entry 5944 (class 1259 OID 40222)

--

CREATE INDEX ix_wallet_withdrawal_policy_updated_by ON public.wallet_withdrawal_policy USING btree (updated_by);


--
-- TOC entry 6179 (class 1259 OID 44178)

--

CREATE INDEX ix_whatsapp_booking_tokens_thread_id_fkey ON public.whatsapp_booking_tokens USING btree (thread_id);


--
-- TOC entry 6180 (class 1259 OID 44179)

--

CREATE INDEX ix_whatsapp_booking_tokens_used_by_fkey ON public.whatsapp_booking_tokens USING btree (used_by);


--
-- TOC entry 6188 (class 1259 OID 44180)

--

CREATE INDEX ix_whatsapp_thread_notes_author_id_fkey ON public.whatsapp_thread_notes USING btree (author_id);


--
-- TOC entry 5880 (class 1259 OID 40223)

--

CREATE UNIQUE INDEX provider_events_provider_code_provider_event_id_key ON public.provider_events USING btree (provider_code, provider_event_id);


--
-- TOC entry 5881 (class 1259 OID 40224)

--

CREATE INDEX provider_events_provider_code_received_at_idx ON public.provider_events USING btree (provider_code, received_at DESC);


--
-- TOC entry 6174 (class 1259 OID 44044)

--

CREATE UNIQUE INDEX uq_whatsapp_messages_wa_message_id ON public.whatsapp_messages USING btree (wa_message_id) WHERE (wa_message_id IS NOT NULL);


--
-- TOC entry 5955 (class 1259 OID 41734)

--

CREATE UNIQUE INDEX ux_device_tokens_user_token ON public.device_tokens USING btree (user_id, token);


--
-- TOC entry 5857 (class 1259 OID 40225)

--

CREATE UNIQUE INDEX ux_payment_intents_ride_active ON public.payment_intents USING btree (ride_id) WHERE (status = ANY (ARRAY['requires_payment_method'::public.payment_intent_status, 'requires_confirmation'::public.payment_intent_status, 'requires_capture'::public.payment_intent_status]));


--
-- TOC entry 5865 (class 1259 OID 40226)

--

CREATE UNIQUE INDEX ux_payments_provider_refund_id ON public.payments USING btree (provider_refund_id) WHERE (provider_refund_id IS NOT NULL);


--
-- TOC entry 5866 (class 1259 OID 40227)

--

CREATE UNIQUE INDEX ux_payments_ride_succeeded ON public.payments USING btree (ride_id) WHERE (status = 'succeeded'::text);


--
-- TOC entry 5901 (class 1259 OID 40228)

--

CREATE UNIQUE INDEX ux_ride_ratings_ride_rater ON public.ride_ratings USING btree (ride_id, rater_id);


--
-- TOC entry 5914 (class 1259 OID 40229)

--

CREATE UNIQUE INDEX ux_ride_requests_driver_matched ON public.ride_requests USING btree (assigned_driver_id) WHERE ((status = 'matched'::public.ride_request_status) AND (assigned_driver_id IS NOT NULL));


--
-- TOC entry 6147 (class 1259 OID 43846)

--

CREATE UNIQUE INDEX ux_ridecheck_events_open_kind ON public.ridecheck_events USING btree (ride_id, kind) WHERE (status = 'open'::text);


--
-- TOC entry 5814 (class 1259 OID 40230)

--

CREATE UNIQUE INDEX ux_rides_driver_active ON public.rides USING btree (driver_id) WHERE (status = ANY (ARRAY['assigned'::public.ride_status, 'arrived'::public.ride_status, 'in_progress'::public.ride_status]));


--
-- TOC entry 5822 (class 1259 OID 40231)

--

CREATE UNIQUE INDEX ux_topup_intents_user_idempotency ON public.topup_intents USING btree (user_id, idempotency_key) WHERE (idempotency_key IS NOT NULL);


--
-- TOC entry 5917 (class 1259 OID 40232)

--

CREATE UNIQUE INDEX ux_topup_packages_label ON public.topup_packages USING btree (label);


--
-- TOC entry 6045 (class 1259 OID 41371)

--

CREATE UNIQUE INDEX ux_trip_share_tokens_token_hash ON public.trip_share_tokens USING btree (token_hash) WHERE (token_hash IS NOT NULL);


--
-- TOC entry 6160 (class 1259 OID 44002)

--

CREATE UNIQUE INDEX ux_trusted_contact_outbox_contact_sos ON public.trusted_contact_outbox USING btree (contact_id, sos_event_id);


--
-- TOC entry 5924 (class 1259 OID 40233)

--

CREATE UNIQUE INDEX ux_wallet_entries_user_idempotency ON public.wallet_entries USING btree (user_id, idempotency_key) WHERE (idempotency_key IS NOT NULL);


--
-- TOC entry 5931 (class 1259 OID 40234)

--

CREATE UNIQUE INDEX ux_wallet_holds_active_per_ride ON public.wallet_holds USING btree (ride_id) WHERE ((ride_id IS NOT NULL) AND (status = 'active'::public.wallet_hold_status));


--
-- TOC entry 5932 (class 1259 OID 40235)

--

CREATE UNIQUE INDEX ux_wallet_holds_active_per_withdraw ON public.wallet_holds USING btree (withdraw_request_id) WHERE ((withdraw_request_id IS NOT NULL) AND (status = 'active'::public.wallet_hold_status));


--
-- TOC entry 5941 (class 1259 OID 40236)

--

CREATE UNIQUE INDEX ux_wallet_withdraw_requests_user_idempotency ON public.wallet_withdraw_requests USING btree (user_id, idempotency_key) WHERE (idempotency_key IS NOT NULL);


--
-- TOC entry 5736 (class 1259 OID 17254)

--

CREATE TRIGGER driver_locations_set_updated_at BEFORE UPDATE ON public.driver_locations FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6360 (class 2620 OID 40238)

--

CREATE TRIGGER driver_vehicles_set_updated_at BEFORE UPDATE ON public.driver_vehicles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6361 (class 2620 OID 40239)

--

CREATE TRIGGER drivers_set_updated_at BEFORE UPDATE ON public.drivers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6363 (class 2620 OID 40240)

--

CREATE TRIGGER payment_intents_set_updated_at BEFORE UPDATE ON public.payment_intents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6364 (class 2620 OID 40241)

--

CREATE TRIGGER payment_providers_set_updated_at BEFORE UPDATE ON public.payment_providers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6365 (class 2620 OID 40242)

--

CREATE TRIGGER payments_generate_receipt AFTER INSERT ON public.payments FOR EACH ROW EXECUTE FUNCTION public.create_receipt_from_payment();


--
-- TOC entry 6366 (class 2620 OID 40243)

--

CREATE TRIGGER payments_set_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6367 (class 2620 OID 40244)

--

CREATE TRIGGER payments_update_receipt_on_refund AFTER UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.update_receipt_on_refund();


--
-- TOC entry 6368 (class 2620 OID 40245)

--

CREATE TRIGGER pricing_configs_set_updated_at BEFORE UPDATE ON public.pricing_configs FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6369 (class 2620 OID 40246)

--

CREATE TRIGGER profile_kyc_set_updated_at BEFORE UPDATE ON public.profile_kyc FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6370 (class 2620 OID 40247)

--

CREATE TRIGGER profiles_after_insert_profile_kyc AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.profile_kyc_init();


--
-- TOC entry 6371 (class 2620 OID 41816)

--

CREATE TRIGGER profiles_after_insert_referral_code AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.referral_code_init();


--
-- TOC entry 6372 (class 2620 OID 40248)

--

CREATE TRIGGER profiles_ensure_wallet_account AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.ensure_wallet_account();


--
-- TOC entry 6373 (class 2620 OID 40249)

--

CREATE TRIGGER profiles_set_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6397 (class 2620 OID 41765)

--

CREATE TRIGGER ride_chat_threads_set_updated_at BEFORE UPDATE ON public.ride_chat_threads FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6375 (class 2620 OID 40250)

--

CREATE TRIGGER ride_incidents_set_updated_at BEFORE UPDATE ON public.ride_incidents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6376 (class 2620 OID 40251)

--

CREATE TRIGGER ride_ratings_apply_aggregate AFTER INSERT ON public.ride_ratings FOR EACH ROW EXECUTE FUNCTION public.apply_rating_aggregate();


--
-- TOC entry 6377 (class 2620 OID 40252)

--

CREATE TRIGGER ride_requests_clear_match_fields BEFORE UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_clear_match_fields();


--
-- TOC entry 6378 (class 2620 OID 40253)

--

CREATE TRIGGER ride_requests_release_driver_on_unmatch AFTER UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_release_driver_on_unmatch();


--
-- TOC entry 6379 (class 2620 OID 40254)

--

CREATE TRIGGER ride_requests_set_quote BEFORE INSERT ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_set_quote();


--
-- TOC entry 6380 (class 2620 OID 40255)

--

CREATE TRIGGER ride_requests_set_updated_at BEFORE UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6381 (class 2620 OID 40256)

--

CREATE TRIGGER ride_requests_status_timestamps BEFORE UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_set_status_timestamps();


--
-- TOC entry 6353 (class 2620 OID 41821)

--

CREATE TRIGGER rides_after_completed_referral AFTER UPDATE ON public.rides FOR EACH ROW EXECUTE FUNCTION public.referral_on_ride_completed();


--
-- TOC entry 6354 (class 2620 OID 40257)

--

CREATE TRIGGER rides_set_updated_at BEFORE UPDATE ON public.rides FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6398 (class 2620 OID 43570)

--

CREATE TRIGGER scheduled_rides_set_updated_at BEFORE UPDATE ON public.scheduled_rides FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6395 (class 2620 OID 41231)

--

CREATE TRIGGER set_updated_at_kyc_documents BEFORE UPDATE ON public.kyc_documents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6393 (class 2620 OID 41230)

--

CREATE TRIGGER set_updated_at_kyc_submissions BEFORE UPDATE ON public.kyc_submissions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6396 (class 2620 OID 41211)

--

CREATE TRIGGER set_updated_at_ride_products BEFORE UPDATE ON public.ride_products FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6403 (class 2620 OID 43741)

--

CREATE TRIGGER support_articles_set_updated_at BEFORE UPDATE ON public.support_articles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6402 (class 2620 OID 43740)

--

CREATE TRIGGER support_sections_set_updated_at BEFORE UPDATE ON public.support_sections FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6357 (class 2620 OID 40258)

--

CREATE TRIGGER topup_intents_set_updated_at BEFORE UPDATE ON public.topup_intents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6383 (class 2620 OID 40259)

--

CREATE TRIGGER topup_packages_set_updated_at BEFORE UPDATE ON public.topup_packages FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6362 (class 2620 OID 42212)

--

CREATE TRIGGER trg_drivers_force_id_from_auth_uid BEFORE INSERT ON public.drivers FOR EACH ROW EXECUTE FUNCTION public.drivers_force_id_from_auth_uid();


--
-- TOC entry 6384 (class 2620 OID 41739)

--

CREATE TRIGGER trg_enqueue_notification_outbox AFTER INSERT ON public.user_notifications FOR EACH ROW EXECUTE FUNCTION public.enqueue_notification_outbox();


--
-- TOC entry 6355 (class 2620 OID 41316)

--

CREATE TRIGGER trg_on_ride_completed_side_effects AFTER UPDATE OF status ON public.rides FOR EACH ROW WHEN (((new.status = 'completed'::public.ride_status) AND (old.status IS DISTINCT FROM 'completed'::public.ride_status))) EXECUTE FUNCTION public.on_ride_completed_side_effects();


--
-- TOC entry 6356 (class 2620 OID 41357)

--

CREATE TRIGGER trg_revoke_trip_share_tokens_on_ride_end AFTER UPDATE OF status ON public.rides FOR EACH ROW EXECUTE FUNCTION public.revoke_trip_share_tokens_on_ride_end();


--
-- TOC entry 6392 (class 2620 OID 41776)

--

CREATE TRIGGER trg_ride_chat_notify_on_message AFTER INSERT ON public.ride_chat_messages FOR EACH ROW EXECUTE FUNCTION public.ride_chat_notify_on_message();


--
-- TOC entry 6401 (class 2620 OID 43645)

--

CREATE TRIGGER trg_ride_intents_set_updated_at BEFORE UPDATE ON public.ride_intents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6382 (class 2620 OID 43610)

--

CREATE TRIGGER trg_ride_requests_set_service_area BEFORE INSERT OR UPDATE OF pickup_lat, pickup_lng ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.set_service_area_id_from_pickup();


--
-- TOC entry 6399 (class 2620 OID 43611)

--

CREATE TRIGGER trg_scheduled_rides_set_service_area BEFORE INSERT OR UPDATE OF pickup_lat, pickup_lng ON public.scheduled_rides FOR EACH ROW EXECUTE FUNCTION public.set_service_area_id_from_pickup();


--
-- TOC entry 6400 (class 2620 OID 43595)

--

CREATE TRIGGER trg_service_areas_set_updated_at BEFORE UPDATE ON public.service_areas FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6391 (class 2620 OID 41345)

--

CREATE TRIGGER trg_support_ticket_touch AFTER INSERT ON public.support_messages FOR EACH ROW EXECUTE FUNCTION public.support_ticket_touch_updated_at();


--
-- TOC entry 6394 (class 2620 OID 41429)

--

CREATE TRIGGER trg_sync_profile_kyc_from_submission AFTER INSERT OR UPDATE OF status ON public.kyc_submissions FOR EACH ROW EXECUTE FUNCTION public.sync_profile_kyc_from_submission();


--
-- TOC entry 6374 (class 2620 OID 41309)

--

CREATE TRIGGER trg_sync_public_profile AFTER INSERT OR UPDATE OF display_name, rating_avg, rating_count ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.sync_public_profile();


--
-- TOC entry 6405 (class 2620 OID 44005)

--

CREATE TRIGGER trg_trusted_contact_outbox_set_updated_at BEFORE UPDATE ON public.trusted_contact_outbox FOR EACH ROW EXECUTE FUNCTION public.tg__set_updated_at();


--
-- TOC entry 6390 (class 2620 OID 43797)

--

CREATE TRIGGER trg_trusted_contacts_active_limit BEFORE INSERT OR UPDATE OF is_active, user_id ON public.trusted_contacts FOR EACH ROW EXECUTE FUNCTION public.trusted_contacts_enforce_active_limit();


--
-- TOC entry 6404 (class 2620 OID 43801)

--

CREATE TRIGGER trg_user_safety_settings_updated_at BEFORE UPDATE ON public.user_safety_settings FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6407 (class 2620 OID 44130)

--

CREATE TRIGGER trg_whatsapp_messages_failed_outbound_followup AFTER UPDATE OF wa_status ON public.whatsapp_messages FOR EACH ROW EXECUTE FUNCTION public.whatsapp_messages_failed_outbound_to_followup_v1();


--
-- TOC entry 6408 (class 2620 OID 44095)

--

CREATE TRIGGER trg_whatsapp_messages_touch_updated_at BEFORE UPDATE ON public.whatsapp_messages FOR EACH ROW EXECUTE FUNCTION public.whatsapp_messages_touch_updated_at_v1();


--
-- TOC entry 6406 (class 2620 OID 44026)

--

CREATE TRIGGER trg_whatsapp_threads_set_updated_at BEFORE UPDATE ON public.whatsapp_threads FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6358 (class 2620 OID 40260)

--

CREATE TRIGGER wallet_accounts_set_updated_at BEFORE UPDATE ON public.wallet_accounts FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6385 (class 2620 OID 44234)

--

CREATE TRIGGER wallet_holds_normalize_status BEFORE INSERT OR UPDATE ON public.wallet_holds FOR EACH ROW EXECUTE FUNCTION public.wallet_holds_normalize_status();


--
-- TOC entry 6386 (class 2620 OID 40261)

--

CREATE TRIGGER wallet_holds_set_updated_at BEFORE UPDATE ON public.wallet_holds FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6387 (class 2620 OID 40262)

--

CREATE TRIGGER wallet_withdraw_payout_methods_set_updated_at BEFORE UPDATE ON public.wallet_withdraw_payout_methods FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6388 (class 2620 OID 40263)

--

CREATE TRIGGER wallet_withdraw_requests_set_updated_at BEFORE UPDATE ON public.wallet_withdraw_requests FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6389 (class 2620 OID 40264)

--

CREATE TRIGGER wallet_withdrawal_policy_set_updated_at BEFORE UPDATE ON public.wallet_withdrawal_policy FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6345 (class 2620 OID 17112)

--

ALTER TABLE ONLY public.achievement_progress
    ADD CONSTRAINT achievement_progress_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES public.achievements(id) ON DELETE CASCADE;


--
-- TOC entry 6282 (class 2606 OID 40707)

--

ALTER TABLE ONLY public.achievement_progress
    ADD CONSTRAINT achievement_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6244 (class 2606 OID 40265)

--

ALTER TABLE ONLY public.app_events
    ADD CONSTRAINT app_events_payment_intent_id_fkey FOREIGN KEY (payment_intent_id) REFERENCES public.payment_intents(id) ON DELETE SET NULL;


--
-- TOC entry 6245 (class 2606 OID 40270)

--

ALTER TABLE ONLY public.app_events
    ADD CONSTRAINT app_events_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE SET NULL;


--
-- TOC entry 6276 (class 2606 OID 40596)

--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6278 (class 2606 OID 40641)

--

ALTER TABLE ONLY public.driver_counters
    ADD CONSTRAINT driver_counters_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 6315 (class 2606 OID 41837)

--

ALTER TABLE ONLY public.driver_leaderboard_daily
    ADD CONSTRAINT driver_leaderboard_daily_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6246 (class 2606 OID 40275)

--

ALTER TABLE ONLY public.driver_locations
    ADD CONSTRAINT driver_locations_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 6280 (class 2606 OID 40672)

--

ALTER TABLE ONLY public.driver_rank_snapshots
    ADD CONSTRAINT driver_rank_snapshots_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 6279 (class 2606 OID 40654)

--

ALTER TABLE ONLY public.driver_stats_daily
    ADD CONSTRAINT driver_stats_daily_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 6247 (class 2606 OID 40280)

--

ALTER TABLE ONLY public.driver_vehicles
    ADD CONSTRAINT driver_vehicles_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 6248 (class 2606 OID 40285)

--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_id_fkey FOREIGN KEY (id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6233 (class 2606 OID 40290)

--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 6234 (class 2606 OID 40295)

--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_redeemed_by_fkey FOREIGN KEY (redeemed_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 6235 (class 2606 OID 40300)

--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_redeemed_entry_id_fkey FOREIGN KEY (redeemed_entry_id) REFERENCES public.wallet_entries(id) ON DELETE SET NULL;


--
-- TOC entry 6305 (class 2606 OID 41422)

--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_document_type_id_fkey FOREIGN KEY (document_type_id) REFERENCES public.kyc_document_types(id) ON DELETE SET NULL;


--
-- TOC entry 6306 (class 2606 OID 41023)

--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.kyc_submissions(id) ON DELETE CASCADE;


--
-- TOC entry 6307 (class 2606 OID 41028)

--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6308 (class 2606 OID 41405)

--

ALTER TABLE ONLY public.kyc_liveness_sessions
    ADD CONSTRAINT kyc_liveness_sessions_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.kyc_submissions(id) ON DELETE CASCADE;


--
-- TOC entry 6303 (class 2606 OID 41006)

--

ALTER TABLE ONLY public.kyc_submissions
    ADD CONSTRAINT kyc_submissions_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 6304 (class 2606 OID 41001)

--

ALTER TABLE ONLY public.kyc_submissions
    ADD CONSTRAINT kyc_submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6277 (class 2606 OID 40622)

--

ALTER TABLE ONLY public.notification_outbox
    ADD CONSTRAINT notification_outbox_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.user_notifications(id) ON DELETE CASCADE;


--
-- TOC entry 6249 (class 2606 OID 40305)

--

ALTER TABLE ONLY public.payment_intents
    ADD CONSTRAINT payment_intents_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6250 (class 2606 OID 40310)

--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_payment_intent_id_fkey FOREIGN KEY (payment_intent_id) REFERENCES public.payment_intents(id) ON DELETE SET NULL;


--
-- TOC entry 6251 (class 2606 OID 40315)

--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6252 (class 2606 OID 40320)

--

ALTER TABLE ONLY public.profile_kyc
    ADD CONSTRAINT profile_kyc_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 6253 (class 2606 OID 40325)

--

ALTER TABLE ONLY public.profile_kyc
    ADD CONSTRAINT profile_kyc_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6254 (class 2606 OID 40330)

--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 6275 (class 2606 OID 40574)

--

ALTER TABLE ONLY public.public_profiles
    ADD CONSTRAINT public_profiles_id_fkey FOREIGN KEY (id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6283 (class 2606 OID 40746)

--

ALTER TABLE ONLY public.referral_codes
    ADD CONSTRAINT referral_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6313 (class 2606 OID 41806)

--

ALTER TABLE ONLY public.referral_invites
    ADD CONSTRAINT referral_invites_referred_user_id_fkey FOREIGN KEY (referred_user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6314 (class 2606 OID 41801)

--

ALTER TABLE ONLY public.referral_invites
    ADD CONSTRAINT referral_invites_referrer_id_fkey FOREIGN KEY (referrer_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6284 (class 2606 OID 40765)

--

ALTER TABLE ONLY public.referral_redemptions
    ADD CONSTRAINT referral_redemptions_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.referral_campaigns(id);


--
-- TOC entry 6285 (class 2606 OID 40775)

--

ALTER TABLE ONLY public.referral_redemptions
    ADD CONSTRAINT referral_redemptions_referred_id_fkey FOREIGN KEY (referred_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6286 (class 2606 OID 40770)

--

ALTER TABLE ONLY public.referral_redemptions
    ADD CONSTRAINT referral_redemptions_referrer_id_fkey FOREIGN KEY (referrer_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6294 (class 2606 OID 40900)

--

ALTER TABLE ONLY public.ride_chat_messages
    ADD CONSTRAINT ride_chat_messages_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6295 (class 2606 OID 40905)

--

ALTER TABLE ONLY public.ride_chat_messages
    ADD CONSTRAINT ride_chat_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6296 (class 2606 OID 40928)

--

ALTER TABLE ONLY public.ride_chat_read_receipts
    ADD CONSTRAINT ride_chat_read_receipts_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.ride_chat_messages(id) ON DELETE CASCADE;


--
-- TOC entry 6297 (class 2606 OID 40933)

--

ALTER TABLE ONLY public.ride_chat_read_receipts
    ADD CONSTRAINT ride_chat_read_receipts_reader_id_fkey FOREIGN KEY (reader_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6298 (class 2606 OID 40923)

--

ALTER TABLE ONLY public.ride_chat_read_receipts
    ADD CONSTRAINT ride_chat_read_receipts_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6310 (class 2606 OID 41760)

--

ALTER TABLE ONLY public.ride_chat_threads
    ADD CONSTRAINT ride_chat_threads_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6311 (class 2606 OID 41750)

--

ALTER TABLE ONLY public.ride_chat_threads
    ADD CONSTRAINT ride_chat_threads_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6312 (class 2606 OID 41755)

--

ALTER TABLE ONLY public.ride_chat_threads
    ADD CONSTRAINT ride_chat_threads_rider_id_fkey FOREIGN KEY (rider_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6299 (class 2606 OID 40951)

--

ALTER TABLE ONLY public.ride_chat_typing
    ADD CONSTRAINT ride_chat_typing_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6300 (class 2606 OID 40946)

--

ALTER TABLE ONLY public.ride_chat_typing
    ADD CONSTRAINT ride_chat_typing_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6309 (class 2606 OID 41723)

--

ALTER TABLE ONLY public.ride_completion_log
    ADD CONSTRAINT ride_completion_log_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6255 (class 2606 OID 40340)

--

ALTER TABLE ONLY public.ride_events
    ADD CONSTRAINT ride_events_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6256 (class 2606 OID 40345)

--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 6257 (class 2606 OID 40350)

--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6258 (class 2606 OID 40355)

--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6320 (class 2606 OID 43640)

--

ALTER TABLE ONLY public.ride_intents
    ADD CONSTRAINT ride_intents_converted_request_id_fkey FOREIGN KEY (converted_request_id) REFERENCES public.ride_requests(id) ON DELETE SET NULL;


--
-- TOC entry 6321 (class 2606 OID 43635)

--

ALTER TABLE ONLY public.ride_intents
    ADD CONSTRAINT ride_intents_service_area_id_fkey FOREIGN KEY (service_area_id) REFERENCES public.service_areas(id) ON DELETE SET NULL;


--
-- TOC entry 6259 (class 2606 OID 40360)

--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_ratee_id_fkey FOREIGN KEY (ratee_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6260 (class 2606 OID 40365)

--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_rater_id_fkey FOREIGN KEY (rater_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6261 (class 2606 OID 40370)

--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6262 (class 2606 OID 40375)

--

ALTER TABLE ONLY public.ride_receipts
    ADD CONSTRAINT ride_receipts_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6263 (class 2606 OID 40380)

--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_assigned_driver_id_fkey FOREIGN KEY (assigned_driver_id) REFERENCES public.drivers(id) ON DELETE SET NULL;


--
-- TOC entry 6264 (class 2606 OID 41213)

--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_product_code_fkey FOREIGN KEY (product_code) REFERENCES public.ride_products(code);


--
-- TOC entry 6265 (class 2606 OID 40385)

--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_rider_id_fkey FOREIGN KEY (rider_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6266 (class 2606 OID 43598)

--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_service_area_id_fkey FOREIGN KEY (service_area_id) REFERENCES public.service_areas(id) ON DELETE SET NULL;


--
-- TOC entry 6330 (class 2606 OID 43839)

--

ALTER TABLE ONLY public.ridecheck_events
    ADD CONSTRAINT ridecheck_events_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6331 (class 2606 OID 43856)

--

ALTER TABLE ONLY public.ridecheck_responses
    ADD CONSTRAINT ridecheck_responses_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.ridecheck_events(id) ON DELETE CASCADE;


--
-- TOC entry 6332 (class 2606 OID 43861)

--

ALTER TABLE ONLY public.ridecheck_responses
    ADD CONSTRAINT ridecheck_responses_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6333 (class 2606 OID 43866)

--

ALTER TABLE ONLY public.ridecheck_responses
    ADD CONSTRAINT ridecheck_responses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6329 (class 2606 OID 43822)

--

ALTER TABLE ONLY public.ridecheck_state
    ADD CONSTRAINT ridecheck_state_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6236 (class 2606 OID 40390)

--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 6237 (class 2606 OID 40395)

--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_payment_intent_id_fkey FOREIGN KEY (payment_intent_id) REFERENCES public.payment_intents(id) ON DELETE SET NULL;


--
-- TOC entry 6238 (class 2606 OID 41219)

--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_product_code_fkey FOREIGN KEY (product_code) REFERENCES public.ride_products(code);


--
-- TOC entry 6239 (class 2606 OID 40400)

--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.ride_requests(id) ON DELETE CASCADE;


--
-- TOC entry 6240 (class 2606 OID 40405)

--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_rider_id_fkey FOREIGN KEY (rider_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6241 (class 2606 OID 40410)

--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_wallet_hold_id_fkey FOREIGN KEY (wallet_hold_id) REFERENCES public.wallet_holds(id) ON DELETE SET NULL;


--
-- TOC entry 6316 (class 2606 OID 43562)

--

ALTER TABLE ONLY public.scheduled_rides
    ADD CONSTRAINT scheduled_rides_ride_request_id_fkey FOREIGN KEY (ride_request_id) REFERENCES public.ride_requests(id) ON DELETE SET NULL;


--
-- TOC entry 6317 (class 2606 OID 43557)

--

ALTER TABLE ONLY public.scheduled_rides
    ADD CONSTRAINT scheduled_rides_rider_id_fkey FOREIGN KEY (rider_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6318 (class 2606 OID 43603)

--

ALTER TABLE ONLY public.scheduled_rides
    ADD CONSTRAINT scheduled_rides_service_area_id_fkey FOREIGN KEY (service_area_id) REFERENCES public.service_areas(id) ON DELETE SET NULL;


--
-- TOC entry 6319 (class 2606 OID 43590)

--

ALTER TABLE ONLY public.service_areas
    ADD CONSTRAINT service_areas_pricing_config_id_fkey FOREIGN KEY (pricing_config_id) REFERENCES public.pricing_configs(id) ON DELETE SET NULL;


--
-- TOC entry 6322 (class 2606 OID 43692)

--

ALTER TABLE ONLY public.sos_events
    ADD CONSTRAINT sos_events_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE SET NULL;


--
-- TOC entry 6323 (class 2606 OID 43687)

--

ALTER TABLE ONLY public.sos_events
    ADD CONSTRAINT sos_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6324 (class 2606 OID 43732)

--

ALTER TABLE ONLY public.support_articles
    ADD CONSTRAINT support_articles_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.support_sections(id) ON DELETE SET NULL;


--
-- TOC entry 6292 (class 2606 OID 40875)

--

ALTER TABLE ONLY public.support_messages
    ADD CONSTRAINT support_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6293 (class 2606 OID 40870)

--

ALTER TABLE ONLY public.support_messages
    ADD CONSTRAINT support_messages_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id) ON DELETE CASCADE;


--
-- TOC entry 6288 (class 2606 OID 40850)

--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_category_code_fkey FOREIGN KEY (category_code) REFERENCES public.support_categories(code);


--
-- TOC entry 6289 (class 2606 OID 41332)

--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.support_categories(id) ON DELETE SET NULL;


--
-- TOC entry 6290 (class 2606 OID 40845)

--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6291 (class 2606 OID 40855)

--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE SET NULL;


--
-- TOC entry 6242 (class 2606 OID 40425)

--

ALTER TABLE ONLY public.topup_intents
    ADD CONSTRAINT topup_intents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6301 (class 2606 OID 40977)

--

ALTER TABLE ONLY public.trip_share_tokens
    ADD CONSTRAINT trip_share_tokens_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6302 (class 2606 OID 40972)

--

ALTER TABLE ONLY public.trip_share_tokens
    ADD CONSTRAINT trip_share_tokens_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 6326 (class 2606 OID 43783)

--

ALTER TABLE ONLY public.trusted_contact_events
    ADD CONSTRAINT trusted_contact_events_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.trusted_contacts(id) ON DELETE SET NULL;


--
-- TOC entry 6327 (class 2606 OID 43788)

--

ALTER TABLE ONLY public.trusted_contact_events
    ADD CONSTRAINT trusted_contact_events_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE SET NULL;


--
-- TOC entry 6328 (class 2606 OID 43778)

--

ALTER TABLE ONLY public.trusted_contact_events
    ADD CONSTRAINT trusted_contact_events_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6334 (class 2606 OID 43987)

--

ALTER TABLE ONLY public.trusted_contact_outbox
    ADD CONSTRAINT trusted_contact_outbox_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES public.trusted_contacts(id) ON DELETE CASCADE;


--
-- TOC entry 6335 (class 2606 OID 43997)

--

ALTER TABLE ONLY public.trusted_contact_outbox
    ADD CONSTRAINT trusted_contact_outbox_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE SET NULL;


--
-- TOC entry 6336 (class 2606 OID 43992)

--

ALTER TABLE ONLY public.trusted_contact_outbox
    ADD CONSTRAINT trusted_contact_outbox_sos_event_id_fkey FOREIGN KEY (sos_event_id) REFERENCES public.sos_events(id) ON DELETE CASCADE;


--
-- TOC entry 6337 (class 2606 OID 43982)

--

ALTER TABLE ONLY public.trusted_contact_outbox
    ADD CONSTRAINT trusted_contact_outbox_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6287 (class 2606 OID 40800)

--

ALTER TABLE ONLY public.trusted_contacts
    ADD CONSTRAINT trusted_contacts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6267 (class 2606 OID 40430)

--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6325 (class 2606 OID 43758)

--

ALTER TABLE ONLY public.user_safety_settings
    ADD CONSTRAINT user_safety_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6243 (class 2606 OID 40435)

--

ALTER TABLE ONLY public.wallet_accounts
    ADD CONSTRAINT wallet_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6268 (class 2606 OID 40440)

--

ALTER TABLE ONLY public.wallet_entries
    ADD CONSTRAINT wallet_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6269 (class 2606 OID 40445)

--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE SET NULL;


--
-- TOC entry 6270 (class 2606 OID 40450)

--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6271 (class 2606 OID 40455)

--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_withdraw_request_id_fkey FOREIGN KEY (withdraw_request_id) REFERENCES public.wallet_withdraw_requests(id) ON DELETE SET NULL;


--
-- TOC entry 6272 (class 2606 OID 40460)

--

ALTER TABLE ONLY public.wallet_withdraw_payout_methods
    ADD CONSTRAINT wallet_withdraw_payout_methods_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 6273 (class 2606 OID 40465)

--

ALTER TABLE ONLY public.wallet_withdraw_requests
    ADD CONSTRAINT wallet_withdraw_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6274 (class 2606 OID 40470)

--

ALTER TABLE ONLY public.wallet_withdrawal_policy
    ADD CONSTRAINT wallet_withdrawal_policy_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 6340 (class 2606 OID 44063)

--

ALTER TABLE ONLY public.whatsapp_booking_tokens
    ADD CONSTRAINT whatsapp_booking_tokens_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.whatsapp_threads(id) ON DELETE CASCADE;


--
-- TOC entry 6341 (class 2606 OID 44068)

--

ALTER TABLE ONLY public.whatsapp_booking_tokens
    ADD CONSTRAINT whatsapp_booking_tokens_used_by_fkey FOREIGN KEY (used_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 6339 (class 2606 OID 44039)

--

ALTER TABLE ONLY public.whatsapp_messages
    ADD CONSTRAINT whatsapp_messages_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.whatsapp_threads(id) ON DELETE CASCADE;


--
-- TOC entry 6342 (class 2606 OID 44121)

--

ALTER TABLE ONLY public.whatsapp_thread_notes
    ADD CONSTRAINT whatsapp_thread_notes_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6343 (class 2606 OID 44116)

--

ALTER TABLE ONLY public.whatsapp_thread_notes
    ADD CONSTRAINT whatsapp_thread_notes_thread_id_fkey FOREIGN KEY (thread_id) REFERENCES public.whatsapp_threads(id) ON DELETE CASCADE;


--
-- TOC entry 6338 (class 2606 OID 44098)

--

ALTER TABLE ONLY public.whatsapp_threads
    ADD CONSTRAINT whatsapp_threads_assigned_admin_id_fkey FOREIGN KEY (assigned_admin_id) REFERENCES public.profiles(id);


--
-- TOC entry 6227 (class 2606 OID 17285)

--

ALTER TABLE public.achievement_progress ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6628 (class 0 OID 40681)
-- Dependencies: 449

--

ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6598 (class 0 OID 39843)
-- Dependencies: 414

--

ALTER TABLE public.api_rate_limits ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6599 (class 0 OID 39849)
-- Dependencies: 415

--

ALTER TABLE public.app_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6623 (class 0 OID 40583)
-- Dependencies: 443

--

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6671 (class 3256 OID 42012)

--

CREATE POLICY device_tokens_delete_own ON public.device_tokens FOR DELETE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6669 (class 3256 OID 42010)

--

CREATE POLICY device_tokens_insert_own ON public.device_tokens FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6668 (class 3256 OID 42009)

--

CREATE POLICY device_tokens_select_own_or_admin ON public.device_tokens FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6670 (class 3256 OID 42011)

--

CREATE POLICY device_tokens_update_own ON public.device_tokens FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6625 (class 0 OID 40633)
-- Dependencies: 446

--

ALTER TABLE public.driver_counters ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6651 (class 0 OID 41825)
-- Dependencies: 474

--

ALTER TABLE public.driver_leaderboard_daily ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6672 (class 3256 OID 42013)

--

CREATE POLICY driver_leaderboard_daily_select_all ON public.driver_leaderboard_daily FOR SELECT TO authenticated USING (true);


--
-- TOC entry 6600 (class 0 OID 39858)
-- Dependencies: 416

--

ALTER TABLE public.driver_locations ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6627 (class 0 OID 40660)
-- Dependencies: 448

--

ALTER TABLE public.driver_rank_snapshots ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6673 (class 3256 OID 42014)

--

CREATE POLICY driver_rank_snapshots_select_authenticated ON public.driver_rank_snapshots FOR SELECT TO authenticated USING (true);


--
-- TOC entry 6626 (class 0 OID 40646)
-- Dependencies: 447

--

ALTER TABLE public.driver_stats_daily ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6674 (class 3256 OID 42015)

--

CREATE POLICY driver_stats_daily_select_own_or_admin ON public.driver_stats_daily FOR SELECT TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6601 (class 0 OID 39868)
-- Dependencies: 417

--

ALTER TABLE public.driver_vehicles ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6602 (class 0 OID 39876)
-- Dependencies: 418

--

ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6833 (class 3256 OID 42214)

--

CREATE POLICY drivers_insert_self ON public.drivers FOR INSERT TO authenticated WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));


--
-- TOC entry 6832 (class 3256 OID 42213)

--

CREATE POLICY drivers_select_self ON public.drivers FOR SELECT TO authenticated USING ((id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6865 (class 3256 OID 43663)

--

CREATE POLICY drivers_update_self ON public.drivers FOR UPDATE TO authenticated USING ((id = ( SELECT auth.uid() AS uid))) WITH CHECK (((id = ( SELECT auth.uid() AS uid)) AND ((status <> 'available'::public.driver_status) OR (EXISTS ( SELECT 1
   FROM public.profile_kyc pk
  WHERE ((pk.user_id = ( SELECT auth.uid() AS uid)) AND (pk.status = 'verified'::public.kyc_status)))))));


--
-- TOC entry 6594 (class 0 OID 39757)
-- Dependencies: 410

--

ALTER TABLE public.gift_codes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6679 (class 3256 OID 42019)

--

CREATE POLICY gift_codes_admin_delete ON public.gift_codes FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6677 (class 3256 OID 42017)

--

CREATE POLICY gift_codes_admin_insert ON public.gift_codes FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6678 (class 3256 OID 42018)

--

CREATE POLICY gift_codes_admin_update ON public.gift_codes FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6676 (class 3256 OID 42016)

--

CREATE POLICY gift_codes_select_admin_or_redeemer_or_creator ON public.gift_codes FOR SELECT TO authenticated USING ((( SELECT public.is_admin() AS is_admin) OR (redeemed_by = ( SELECT auth.uid() AS uid)) OR (created_by = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6644 (class 0 OID 41373)
-- Dependencies: 465

--

ALTER TABLE public.kyc_document_types ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6642 (class 0 OID 41012)
-- Dependencies: 463

--

ALTER TABLE public.kyc_documents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6685 (class 3256 OID 42024)

--

CREATE POLICY kyc_documents_delete_owner_or_admin ON public.kyc_documents FOR DELETE TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6681 (class 3256 OID 42021)

--

CREATE POLICY kyc_documents_insert_owner ON public.kyc_documents FOR INSERT TO authenticated WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6680 (class 3256 OID 42020)

--

CREATE POLICY kyc_documents_select_owner_or_admin ON public.kyc_documents FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6683 (class 3256 OID 42022)

--

CREATE POLICY kyc_documents_update_owner_or_admin ON public.kyc_documents FOR UPDATE TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))) WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6645 (class 0 OID 41392)
-- Dependencies: 466

--

ALTER TABLE public.kyc_liveness_sessions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6641 (class 0 OID 40989)
-- Dependencies: 462

--

ALTER TABLE public.kyc_submissions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6688 (class 3256 OID 42029)

--

CREATE POLICY kyc_submissions_delete_owner_or_admin ON public.kyc_submissions FOR DELETE TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6687 (class 3256 OID 42026)

--

CREATE POLICY kyc_submissions_insert_owner ON public.kyc_submissions FOR INSERT TO authenticated WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6686 (class 3256 OID 42025)

--

CREATE POLICY kyc_submissions_select_owner_or_admin ON public.kyc_submissions FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6912 (class 3256 OID 44181)

--

CREATE POLICY kyc_submissions_update_authenticated ON public.kyc_submissions FOR UPDATE TO authenticated USING ((( SELECT public.is_admin() AS is_admin) OR (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid))) AND (status = ANY (ARRAY['draft'::text, 'submitted'::text]))))) WITH CHECK ((( SELECT public.is_admin() AS is_admin) OR (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid))) AND (status = ANY (ARRAY['draft'::text, 'submitted'::text])) AND (reviewer_id IS NULL) AND (reviewed_at IS NULL))));


--
-- TOC entry 6624 (class 0 OID 40608)
-- Dependencies: 445

--

ALTER TABLE public.notification_outbox ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6603 (class 0 OID 39887)
-- Dependencies: 419

--

ALTER TABLE public.payment_intents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6848 (class 3256 OID 42244)

--

CREATE POLICY payment_intents_select_anon_none ON public.payment_intents FOR SELECT TO anon USING (false);


--
-- TOC entry 6847 (class 3256 OID 42243)

--

CREATE POLICY payment_intents_select_participants ON public.payment_intents FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = payment_intents.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6604 (class 0 OID 39899)
-- Dependencies: 420

--

ALTER TABLE public.payment_providers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6818 (class 3256 OID 42198)

--

CREATE POLICY payment_providers_delete_admin ON public.payment_providers FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6812 (class 3256 OID 42196)

--

CREATE POLICY payment_providers_insert_admin ON public.payment_providers FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6806 (class 3256 OID 42195)

--

CREATE POLICY payment_providers_select_public ON public.payment_providers FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6817 (class 3256 OID 42197)

--

CREATE POLICY payment_providers_update_admin ON public.payment_providers FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6605 (class 0 OID 39909)
-- Dependencies: 421

--

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6850 (class 3256 OID 42246)

--

CREATE POLICY payments_select_anon_none ON public.payments FOR SELECT TO anon USING (false);


--
-- TOC entry 6849 (class 3256 OID 42245)

--

CREATE POLICY payments_select_participants ON public.payments FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = payments.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6606 (class 0 OID 39919)
-- Dependencies: 422

--

ALTER TABLE public.pricing_configs ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6607 (class 0 OID 39933)
-- Dependencies: 423

--

ALTER TABLE public.profile_kyc ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6864 (class 3256 OID 43659)

--

CREATE POLICY profile_kyc_admin_delete ON public.profile_kyc FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6863 (class 3256 OID 43658)

--

CREATE POLICY profile_kyc_admin_update ON public.profile_kyc FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6608 (class 0 OID 39940)
-- Dependencies: 424

--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6689 (class 3256 OID 42030)

--

CREATE POLICY profiles_insert_self ON public.profiles FOR INSERT TO authenticated WITH CHECK ((id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6690 (class 3256 OID 42031)

--

CREATE POLICY profiles_select_own_or_admin ON public.profiles FOR SELECT TO authenticated USING (((id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6691 (class 3256 OID 42032)

--

CREATE POLICY profiles_update_own ON public.profiles FOR UPDATE TO authenticated USING ((id = ( SELECT auth.uid() AS uid))) WITH CHECK ((id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6609 (class 0 OID 39950)
-- Dependencies: 425

--

ALTER TABLE public.provider_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6854 (class 3256 OID 42249)

--

CREATE POLICY provider_events_admin_insert ON public.provider_events FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6824 (class 3256 OID 42203)

--

CREATE POLICY provider_events_select_admin ON public.provider_events FOR SELECT TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6825 (class 3256 OID 42204)

--

CREATE POLICY provider_events_select_anon_none ON public.provider_events FOR SELECT TO anon USING (false);


--
-- TOC entry 6622 (class 0 OID 40563)
-- Dependencies: 441

--

ALTER TABLE public.public_profiles ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6692 (class 3256 OID 42033)

--

CREATE POLICY public_profiles_select_all ON public.public_profiles FOR SELECT TO authenticated USING (true);


--
-- TOC entry 6630 (class 0 OID 40722)
-- Dependencies: 451

--

ALTER TABLE public.referral_campaigns ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6631 (class 0 OID 40736)
-- Dependencies: 452

--

ALTER TABLE public.referral_codes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6650 (class 0 OID 41788)
-- Dependencies: 473

--

ALTER TABLE public.referral_invites ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6632 (class 0 OID 40752)
-- Dependencies: 453

--

ALTER TABLE public.referral_redemptions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6649 (class 0 OID 41777)
-- Dependencies: 472

--

ALTER TABLE public.referral_settings ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6637 (class 0 OID 40890)
-- Dependencies: 458

--

ALTER TABLE public.ride_chat_messages ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6697 (class 3256 OID 42037)

--

CREATE POLICY ride_chat_messages_delete_own ON public.ride_chat_messages FOR DELETE TO authenticated USING ((sender_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6695 (class 3256 OID 42035)

--

CREATE POLICY ride_chat_messages_insert_sender ON public.ride_chat_messages FOR INSERT TO authenticated WITH CHECK (((sender_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM public.ride_chat_threads t
  WHERE ((t.id = ride_chat_messages.thread_id) AND (t.ride_id = ride_chat_messages.ride_id) AND ((t.rider_id = ( SELECT auth.uid() AS uid)) OR (t.driver_id = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6693 (class 3256 OID 42034)

--

CREATE POLICY ride_chat_messages_select_participants ON public.ride_chat_messages FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.ride_chat_threads t
  WHERE ((t.id = ride_chat_messages.thread_id) AND ((t.rider_id = ( SELECT auth.uid() AS uid)) OR (t.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6696 (class 3256 OID 42036)

--

CREATE POLICY ride_chat_messages_update_own ON public.ride_chat_messages FOR UPDATE TO authenticated USING ((sender_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((sender_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6698 (class 3256 OID 42038)

--

CREATE POLICY ride_chat_read_insert_self ON public.ride_chat_read_receipts FOR INSERT TO authenticated WITH CHECK (((reader_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM (public.ride_chat_messages m
     JOIN public.rides r ON ((r.id = m.ride_id)))
  WHERE ((m.id = ride_chat_read_receipts.message_id) AND (m.ride_id = ride_chat_read_receipts.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6638 (class 0 OID 40914)
-- Dependencies: 459

--

ALTER TABLE public.ride_chat_read_receipts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6699 (class 3256 OID 42040)

--

CREATE POLICY ride_chat_read_select_participants ON public.ride_chat_read_receipts FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.ride_chat_threads t
  WHERE ((t.id = ride_chat_read_receipts.thread_id) AND ((t.rider_id = ( SELECT auth.uid() AS uid)) OR (t.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6648 (class 0 OID 41740)
-- Dependencies: 471

--

ALTER TABLE public.ride_chat_threads ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6639 (class 0 OID 40939)
-- Dependencies: 460

--

ALTER TABLE public.ride_chat_typing ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6647 (class 0 OID 41717)
-- Dependencies: 470

--

ALTER TABLE public.ride_completion_log ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6610 (class 0 OID 39958)
-- Dependencies: 427

--

ALTER TABLE public.ride_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6611 (class 0 OID 39966)
-- Dependencies: 429

--

ALTER TABLE public.ride_incidents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6829 (class 3256 OID 42208)

--

CREATE POLICY ride_incidents_insert_reporter ON public.ride_incidents FOR INSERT TO authenticated WITH CHECK (((reporter_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_incidents.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6831 (class 3256 OID 42210)

--

CREATE POLICY ride_incidents_select_anon_none ON public.ride_incidents FOR SELECT TO anon USING (false);


--
-- TOC entry 6828 (class 3256 OID 42207)

--

CREATE POLICY ride_incidents_select_participant ON public.ride_incidents FOR SELECT TO authenticated USING (((reporter_id = ( SELECT auth.uid() AS uid)) OR (assigned_to = ( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_incidents.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6830 (class 3256 OID 42209)

--

CREATE POLICY ride_incidents_update_reporter_or_assignee ON public.ride_incidents FOR UPDATE TO authenticated USING (((reporter_id = ( SELECT auth.uid() AS uid)) OR (assigned_to = ( SELECT auth.uid() AS uid)))) WITH CHECK (((reporter_id = ( SELECT auth.uid() AS uid)) OR (assigned_to = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6654 (class 0 OID 43615)
-- Dependencies: 478

--

ALTER TABLE public.ride_intents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6862 (class 3256 OID 43653)

--

CREATE POLICY ride_intents_delete_admin ON public.ride_intents FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6855 (class 3256 OID 43651)

--

CREATE POLICY ride_intents_insert_self_or_admin ON public.ride_intents FOR INSERT TO authenticated WITH CHECK ((((rider_id = ( SELECT auth.uid() AS uid)) AND (status = 'new'::text)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6851 (class 3256 OID 43650)

--

CREATE POLICY ride_intents_select_self_or_admin ON public.ride_intents FOR SELECT TO authenticated USING (((rider_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6861 (class 3256 OID 43652)

--

CREATE POLICY ride_intents_update_admin ON public.ride_intents FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6643 (class 0 OID 41198)
-- Dependencies: 464

--

ALTER TABLE public.ride_products ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6612 (class 0 OID 39976)
-- Dependencies: 430

--

ALTER TABLE public.ride_ratings ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6853 (class 3256 OID 42248)

--

CREATE POLICY ride_ratings_select_anon_none ON public.ride_ratings FOR SELECT TO anon USING (false);


--
-- TOC entry 6852 (class 3256 OID 42247)

--

CREATE POLICY ride_ratings_select_participants ON public.ride_ratings FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_ratings.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6613 (class 0 OID 39984)
-- Dependencies: 431

--

ALTER TABLE public.ride_receipts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6827 (class 3256 OID 42206)

--

CREATE POLICY ride_receipts_select_anon_none ON public.ride_receipts FOR SELECT TO anon USING (false);


--
-- TOC entry 6826 (class 3256 OID 42205)

--

CREATE POLICY ride_receipts_select_participant ON public.ride_receipts FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_receipts.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6614 (class 0 OID 39995)
-- Dependencies: 432

--

ALTER TABLE public.ride_requests ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6700 (class 3256 OID 42041)

--

CREATE POLICY ride_requests_insert_own ON public.ride_requests FOR INSERT TO authenticated WITH CHECK ((rider_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6701 (class 3256 OID 42042)

--

CREATE POLICY ride_requests_select_own_or_assigned_driver ON public.ride_requests FOR SELECT TO authenticated USING (((rider_id = ( SELECT auth.uid() AS uid)) OR (assigned_driver_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6702 (class 3256 OID 42043)

--

CREATE POLICY ride_requests_update_own_cancel ON public.ride_requests FOR UPDATE TO authenticated USING (((rider_id = ( SELECT auth.uid() AS uid)) AND (status = ANY (ARRAY['requested'::public.ride_request_status, 'matched'::public.ride_request_status])))) WITH CHECK (((rider_id = ( SELECT auth.uid() AS uid)) AND (status = 'cancelled'::public.ride_request_status)));


--
-- TOC entry 6661 (class 0 OID 43827)
-- Dependencies: 485

--

ALTER TABLE public.ridecheck_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6879 (class 3256 OID 43877)

--

CREATE POLICY ridecheck_events_select_participants ON public.ridecheck_events FOR SELECT TO authenticated USING ((( SELECT public.is_admin() AS is_admin) OR (EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ridecheck_events.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6662 (class 0 OID 43847)
-- Dependencies: 486

--

ALTER TABLE public.ridecheck_responses ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6880 (class 3256 OID 43878)

--

CREATE POLICY ridecheck_responses_select_participants ON public.ridecheck_responses FOR SELECT TO authenticated USING ((( SELECT public.is_admin() AS is_admin) OR (EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ridecheck_responses.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6660 (class 0 OID 43811)
-- Dependencies: 484

--

ALTER TABLE public.ridecheck_state ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6595 (class 0 OID 39794)
-- Dependencies: 411

--

ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6735 (class 3256 OID 42091)

--

CREATE POLICY rls_delete ON public.achievement_progress FOR DELETE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6743 (class 3256 OID 42104)

--

CREATE POLICY rls_delete ON public.driver_locations FOR DELETE TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6751 (class 3256 OID 42109)

--

CREATE POLICY rls_delete ON public.driver_vehicles FOR DELETE TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6758 (class 3256 OID 42118)

--

CREATE POLICY rls_delete ON public.kyc_liveness_sessions FOR DELETE TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6769 (class 3256 OID 42142)

--

CREATE POLICY rls_delete ON public.referral_codes FOR DELETE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6780 (class 3256 OID 42153)

--

CREATE POLICY rls_delete ON public.ride_chat_threads FOR DELETE TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6787 (class 3256 OID 42158)

--

CREATE POLICY rls_delete ON public.ride_chat_typing FOR DELETE TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6794 (class 3256 OID 42165)

--

CREATE POLICY rls_delete ON public.ride_events FOR DELETE TO authenticated USING ((actor_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6801 (class 3256 OID 42178)

--

CREATE POLICY rls_delete ON public.rides FOR DELETE TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6810 (class 3256 OID 42187)

--

CREATE POLICY rls_delete ON public.user_device_tokens FOR DELETE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6816 (class 3256 OID 42192)

--

CREATE POLICY rls_delete ON public.wallet_accounts FOR DELETE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6739 (class 3256 OID 42095)

--

CREATE POLICY rls_deny_all ON public.api_rate_limits TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6718 (class 3256 OID 42097)

--

CREATE POLICY rls_deny_all ON public.app_events TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6730 (class 3256 OID 42099)

--

CREATE POLICY rls_deny_all ON public.driver_counters TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6760 (class 3256 OID 42120)

--

CREATE POLICY rls_deny_all ON public.notification_outbox TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6771 (class 3256 OID 42144)

--

CREATE POLICY rls_deny_all ON public.referral_invites TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6773 (class 3256 OID 42146)

--

CREATE POLICY rls_deny_all ON public.referral_redemptions TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6789 (class 3256 OID 42160)

--

CREATE POLICY rls_deny_all ON public.ride_completion_log TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6733 (class 3256 OID 42089)

--

CREATE POLICY rls_insert ON public.achievement_progress FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6741 (class 3256 OID 42102)

--

CREATE POLICY rls_insert ON public.driver_locations FOR INSERT TO authenticated WITH CHECK ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6749 (class 3256 OID 42107)

--

CREATE POLICY rls_insert ON public.driver_vehicles FOR INSERT TO authenticated WITH CHECK ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6756 (class 3256 OID 42116)

--

CREATE POLICY rls_insert ON public.kyc_liveness_sessions FOR INSERT TO authenticated WITH CHECK ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6767 (class 3256 OID 42140)

--

CREATE POLICY rls_insert ON public.referral_codes FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6778 (class 3256 OID 42151)

--

CREATE POLICY rls_insert ON public.ride_chat_threads FOR INSERT TO authenticated WITH CHECK (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6785 (class 3256 OID 42156)

--

CREATE POLICY rls_insert ON public.ride_chat_typing FOR INSERT TO authenticated WITH CHECK ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6792 (class 3256 OID 42163)

--

CREATE POLICY rls_insert ON public.ride_events FOR INSERT TO authenticated WITH CHECK ((actor_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6800 (class 3256 OID 42176)

--

CREATE POLICY rls_insert ON public.rides FOR INSERT TO authenticated WITH CHECK (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6808 (class 3256 OID 42185)

--

CREATE POLICY rls_insert ON public.user_device_tokens FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6814 (class 3256 OID 42190)

--

CREATE POLICY rls_insert ON public.wallet_accounts FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6737 (class 3256 OID 42093)

--

CREATE POLICY rls_public_select ON public.achievements FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6754 (class 3256 OID 42113)

--

CREATE POLICY rls_public_select ON public.kyc_document_types FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6707 (class 3256 OID 42128)

--

CREATE POLICY rls_public_select ON public.pricing_configs FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6765 (class 3256 OID 42137)

--

CREATE POLICY rls_public_select ON public.referral_campaigns FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6775 (class 3256 OID 42148)

--

CREATE POLICY rls_public_select ON public.referral_settings FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6797 (class 3256 OID 42169)

--

CREATE POLICY rls_public_select ON public.ride_products FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6803 (class 3256 OID 42180)

--

CREATE POLICY rls_public_select ON public.support_categories FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6732 (class 3256 OID 42088)

--

CREATE POLICY rls_select ON public.achievement_progress FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6740 (class 3256 OID 42101)

--

CREATE POLICY rls_select ON public.driver_locations FOR SELECT TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6748 (class 3256 OID 42106)

--

CREATE POLICY rls_select ON public.driver_vehicles FOR SELECT TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6755 (class 3256 OID 42115)

--

CREATE POLICY rls_select ON public.kyc_liveness_sessions FOR SELECT TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6762 (class 3256 OID 42130)

--

CREATE POLICY rls_select ON public.profile_kyc FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6766 (class 3256 OID 42139)

--

CREATE POLICY rls_select ON public.referral_codes FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6777 (class 3256 OID 42150)

--

CREATE POLICY rls_select ON public.ride_chat_threads FOR SELECT TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6784 (class 3256 OID 42155)

--

CREATE POLICY rls_select ON public.ride_chat_typing FOR SELECT TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6791 (class 3256 OID 42162)

--

CREATE POLICY rls_select ON public.ride_events FOR SELECT TO authenticated USING ((actor_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6799 (class 3256 OID 42175)

--

CREATE POLICY rls_select ON public.rides FOR SELECT TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6807 (class 3256 OID 42184)

--

CREATE POLICY rls_select ON public.user_device_tokens FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6813 (class 3256 OID 42189)

--

CREATE POLICY rls_select ON public.wallet_accounts FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6705 (class 3256 OID 42087)

--

CREATE POLICY rls_service_role_all ON public.achievement_progress TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6736 (class 3256 OID 42092)

--

CREATE POLICY rls_service_role_all ON public.achievements TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6738 (class 3256 OID 42094)

--

CREATE POLICY rls_service_role_all ON public.api_rate_limits TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6713 (class 3256 OID 42096)

--

CREATE POLICY rls_service_role_all ON public.app_events TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6719 (class 3256 OID 42098)

--

CREATE POLICY rls_service_role_all ON public.driver_counters TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6731 (class 3256 OID 42100)

--

CREATE POLICY rls_service_role_all ON public.driver_locations TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6744 (class 3256 OID 42105)

--

CREATE POLICY rls_service_role_all ON public.driver_vehicles TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6752 (class 3256 OID 42110)

--

CREATE POLICY rls_service_role_all ON public.drivers TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6753 (class 3256 OID 42112)

--

CREATE POLICY rls_service_role_all ON public.kyc_document_types TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6745 (class 3256 OID 42114)

--

CREATE POLICY rls_service_role_all ON public.kyc_liveness_sessions TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6759 (class 3256 OID 42119)

--

CREATE POLICY rls_service_role_all ON public.notification_outbox TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6761 (class 3256 OID 42121)

--

CREATE POLICY rls_service_role_all ON public.payment_intents TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6675 (class 3256 OID 42123)

--

CREATE POLICY rls_service_role_all ON public.payment_providers TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6694 (class 3256 OID 42125)

--

CREATE POLICY rls_service_role_all ON public.payments TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6706 (class 3256 OID 42127)

--

CREATE POLICY rls_service_role_all ON public.pricing_configs TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6746 (class 3256 OID 42129)

--

CREATE POLICY rls_service_role_all ON public.profile_kyc TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6763 (class 3256 OID 42134)

--

CREATE POLICY rls_service_role_all ON public.provider_events TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6764 (class 3256 OID 42136)

--

CREATE POLICY rls_service_role_all ON public.referral_campaigns TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6747 (class 3256 OID 42138)

--

CREATE POLICY rls_service_role_all ON public.referral_codes TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6770 (class 3256 OID 42143)

--

CREATE POLICY rls_service_role_all ON public.referral_invites TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6772 (class 3256 OID 42145)

--

CREATE POLICY rls_service_role_all ON public.referral_redemptions TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6774 (class 3256 OID 42147)

--

CREATE POLICY rls_service_role_all ON public.referral_settings TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6776 (class 3256 OID 42149)

--

CREATE POLICY rls_service_role_all ON public.ride_chat_threads TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6781 (class 3256 OID 42154)

--

CREATE POLICY rls_service_role_all ON public.ride_chat_typing TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6788 (class 3256 OID 42159)

--

CREATE POLICY rls_service_role_all ON public.ride_completion_log TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6790 (class 3256 OID 42161)

--

CREATE POLICY rls_service_role_all ON public.ride_events TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6795 (class 3256 OID 42166)

--

CREATE POLICY rls_service_role_all ON public.ride_incidents TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6796 (class 3256 OID 42168)

--

CREATE POLICY rls_service_role_all ON public.ride_products TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6782 (class 3256 OID 42170)

--

CREATE POLICY rls_service_role_all ON public.ride_ratings TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6783 (class 3256 OID 42172)

--

CREATE POLICY rls_service_role_all ON public.ride_receipts TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6876 (class 3256 OID 43874)

--

CREATE POLICY rls_service_role_all ON public.ridecheck_events TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6877 (class 3256 OID 43875)

--

CREATE POLICY rls_service_role_all ON public.ridecheck_responses TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6878 (class 3256 OID 43876)

--

CREATE POLICY rls_service_role_all ON public.ridecheck_state TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6798 (class 3256 OID 42174)

--

CREATE POLICY rls_service_role_all ON public.rides TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6856 (class 3256 OID 43571)

--

CREATE POLICY rls_service_role_all ON public.scheduled_rides TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6802 (class 3256 OID 42179)

--

CREATE POLICY rls_service_role_all ON public.support_categories TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6804 (class 3256 OID 42181)

--

CREATE POLICY rls_service_role_all ON public.topup_packages TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6805 (class 3256 OID 42183)

--

CREATE POLICY rls_service_role_all ON public.user_device_tokens TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6811 (class 3256 OID 42188)

--

CREATE POLICY rls_service_role_all ON public.wallet_accounts TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6734 (class 3256 OID 42090)

--

CREATE POLICY rls_update ON public.achievement_progress FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6742 (class 3256 OID 42103)

--

CREATE POLICY rls_update ON public.driver_locations FOR UPDATE TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6750 (class 3256 OID 42108)

--

CREATE POLICY rls_update ON public.driver_vehicles FOR UPDATE TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6757 (class 3256 OID 42117)

--

CREATE POLICY rls_update ON public.kyc_liveness_sessions FOR UPDATE TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6768 (class 3256 OID 42141)

--

CREATE POLICY rls_update ON public.referral_codes FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6779 (class 3256 OID 42152)

--

CREATE POLICY rls_update ON public.ride_chat_threads FOR UPDATE TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid)))) WITH CHECK (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6786 (class 3256 OID 42157)

--

CREATE POLICY rls_update ON public.ride_chat_typing FOR UPDATE TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6793 (class 3256 OID 42164)

--

CREATE POLICY rls_update ON public.ride_events FOR UPDATE TO authenticated USING ((actor_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((actor_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6809 (class 3256 OID 42186)

--

CREATE POLICY rls_update ON public.user_device_tokens FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6815 (class 3256 OID 42191)

--

CREATE POLICY rls_update ON public.wallet_accounts FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6652 (class 0 OID 43545)
-- Dependencies: 476

--

ALTER TABLE public.scheduled_rides ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6858 (class 3256 OID 43573)

--

CREATE POLICY scheduled_rides_insert_own ON public.scheduled_rides FOR INSERT TO authenticated WITH CHECK ((rider_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6857 (class 3256 OID 43572)

--

CREATE POLICY scheduled_rides_select_own_or_admin ON public.scheduled_rides FOR SELECT TO authenticated USING (((rider_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6859 (class 3256 OID 43574)

--

CREATE POLICY scheduled_rides_update_own_pending ON public.scheduled_rides FOR UPDATE TO authenticated USING (((rider_id = ( SELECT auth.uid() AS uid)) AND (status = 'pending'::public.scheduled_ride_status))) WITH CHECK ((rider_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6653 (class 0 OID 43576)
-- Dependencies: 477

--

ALTER TABLE public.service_areas ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6905 (class 3256 OID 44162)

--

CREATE POLICY service_areas_admin_write_del ON public.service_areas FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6903 (class 3256 OID 44160)

--

CREATE POLICY service_areas_admin_write_ins ON public.service_areas FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6904 (class 3256 OID 44161)

--

CREATE POLICY service_areas_admin_write_upd ON public.service_areas FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6860 (class 3256 OID 43612)

--

CREATE POLICY service_areas_select_active_or_admin ON public.service_areas FOR SELECT TO authenticated USING (((is_active = true) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6655 (class 0 OID 43676)
-- Dependencies: 479

--

ALTER TABLE public.sos_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6869 (class 3256 OID 43702)

--

CREATE POLICY sos_events_delete_admin ON public.sos_events FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6867 (class 3256 OID 43700)

--

CREATE POLICY sos_events_insert_own ON public.sos_events FOR INSERT TO authenticated WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6866 (class 3256 OID 43699)

--

CREATE POLICY sos_events_select_own ON public.sos_events FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6868 (class 3256 OID 43701)

--

CREATE POLICY sos_events_update_admin ON public.sos_events FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6657 (class 0 OID 43717)
-- Dependencies: 481

--

ALTER TABLE public.support_articles ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6908 (class 3256 OID 44165)

--

CREATE POLICY support_articles_admin_write_del ON public.support_articles FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6906 (class 3256 OID 44163)

--

CREATE POLICY support_articles_admin_write_ins ON public.support_articles FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6907 (class 3256 OID 44164)

--

CREATE POLICY support_articles_admin_write_upd ON public.support_articles FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6871 (class 3256 OID 43744)

--

CREATE POLICY support_articles_select_public ON public.support_articles FOR SELECT TO authenticated, anon USING ((enabled = true));


--
-- TOC entry 6634 (class 0 OID 40824)
-- Dependencies: 455

--

ALTER TABLE public.support_categories ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6636 (class 0 OID 40861)
-- Dependencies: 457

--

ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6703 (class 3256 OID 42045)

--

CREATE POLICY support_messages_insert_ticket_owner_or_admin ON public.support_messages FOR INSERT TO authenticated WITH CHECK (((sender_id = ( SELECT auth.uid() AS uid)) AND (( SELECT public.is_admin() AS is_admin) OR (EXISTS ( SELECT 1
   FROM public.support_tickets t
  WHERE ((t.id = support_messages.ticket_id) AND (t.created_by = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6704 (class 3256 OID 42046)

--

CREATE POLICY support_messages_select_ticket_owner_sender_or_admin ON public.support_messages FOR SELECT TO authenticated USING ((( SELECT public.is_admin() AS is_admin) OR (sender_id = ( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
   FROM public.support_tickets t
  WHERE ((t.id = support_messages.ticket_id) AND (t.created_by = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6656 (class 0 OID 43703)
-- Dependencies: 480

--

ALTER TABLE public.support_sections ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6911 (class 3256 OID 44168)

--

CREATE POLICY support_sections_admin_write_del ON public.support_sections FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6909 (class 3256 OID 44166)

--

CREATE POLICY support_sections_admin_write_ins ON public.support_sections FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6910 (class 3256 OID 44167)

--

CREATE POLICY support_sections_admin_write_upd ON public.support_sections FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6870 (class 3256 OID 43742)

--

CREATE POLICY support_sections_select_public ON public.support_sections FOR SELECT TO authenticated, anon USING ((enabled = true));


--
-- TOC entry 6635 (class 0 OID 40833)
-- Dependencies: 456

--

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6708 (class 3256 OID 42047)

--

CREATE POLICY support_tickets_insert_own ON public.support_tickets FOR INSERT TO authenticated WITH CHECK ((created_by = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6709 (class 3256 OID 42048)

--

CREATE POLICY support_tickets_select_own_or_admin ON public.support_tickets FOR SELECT TO authenticated USING (((created_by = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6710 (class 3256 OID 42049)

--

CREATE POLICY support_tickets_update_own_or_admin ON public.support_tickets FOR UPDATE TO authenticated USING (((created_by = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))) WITH CHECK (((created_by = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6596 (class 0 OID 39813)
-- Dependencies: 412

--

ALTER TABLE public.topup_intents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6714 (class 3256 OID 42052)

--

CREATE POLICY topup_intents_admin_update ON public.topup_intents FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6711 (class 3256 OID 42050)

--

CREATE POLICY topup_intents_insert_own ON public.topup_intents FOR INSERT TO authenticated WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) AND (status = 'created'::public.topup_status)));


--
-- TOC entry 6712 (class 3256 OID 42051)

--

CREATE POLICY topup_intents_select_own_or_admin ON public.topup_intents FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6615 (class 0 OID 40013)
-- Dependencies: 433

--

ALTER TABLE public.topup_packages ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6823 (class 3256 OID 42202)

--

CREATE POLICY topup_packages_delete_admin ON public.topup_packages FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6820 (class 3256 OID 42200)

--

CREATE POLICY topup_packages_insert_admin ON public.topup_packages FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6819 (class 3256 OID 42199)

--

CREATE POLICY topup_packages_select_public_active ON public.topup_packages FOR SELECT TO authenticated, anon USING ((active = true));


--
-- TOC entry 6821 (class 3256 OID 42201)

--

CREATE POLICY topup_packages_update_admin ON public.topup_packages FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6640 (class 0 OID 40961)
-- Dependencies: 461

--

ALTER TABLE public.trip_share_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6715 (class 3256 OID 42053)

--

CREATE POLICY trip_share_tokens_insert_participant ON public.trip_share_tokens FOR INSERT TO authenticated WITH CHECK (((created_by = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = trip_share_tokens.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)))))));


--
-- TOC entry 6717 (class 3256 OID 42055)

--

CREATE POLICY trip_share_tokens_revoke_own ON public.trip_share_tokens FOR UPDATE TO authenticated USING ((created_by = ( SELECT auth.uid() AS uid))) WITH CHECK ((created_by = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6716 (class 3256 OID 42054)

--

CREATE POLICY trip_share_tokens_select_participant ON public.trip_share_tokens FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = trip_share_tokens.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))))));


--
-- TOC entry 6659 (class 0 OID 43767)
-- Dependencies: 483

--

ALTER TABLE public.trusted_contact_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6872 (class 3256 OID 43795)

--

CREATE POLICY trusted_contact_events_select_own_or_admin ON public.trusted_contact_events FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6663 (class 0 OID 43966)
-- Dependencies: 487

--

ALTER TABLE public.trusted_contact_outbox ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6890 (class 3256 OID 44147)

--

CREATE POLICY trusted_contact_outbox_admin_read ON public.trusted_contact_outbox FOR SELECT TO authenticated USING (public.is_admin(( SELECT auth.uid() AS uid)));


--
-- TOC entry 6881 (class 3256 OID 44006)

--

CREATE POLICY trusted_contact_outbox_service_role_all ON public.trusted_contact_outbox TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6633 (class 0 OID 40790)
-- Dependencies: 454

--

ALTER TABLE public.trusted_contacts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6720 (class 3256 OID 42056)

--

CREATE POLICY trusted_contacts_write_own_or_admin ON public.trusted_contacts TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))) WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6646 (class 0 OID 41699)
-- Dependencies: 469

--

ALTER TABLE public.user_device_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6616 (class 0 OID 40026)
-- Dependencies: 434

--

ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6721 (class 3256 OID 42057)

--

CREATE POLICY user_notifications_select_own_or_admin ON public.user_notifications FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6722 (class 3256 OID 42058)

--

CREATE POLICY user_notifications_update_own_or_admin ON public.user_notifications FOR UPDATE TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))) WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6658 (class 0 OID 43747)
-- Dependencies: 482

--

ALTER TABLE public.user_safety_settings ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6874 (class 3256 OID 43799)

--

CREATE POLICY user_safety_settings_insert_own ON public.user_safety_settings FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6873 (class 3256 OID 43798)

--

CREATE POLICY user_safety_settings_select_own_or_admin ON public.user_safety_settings FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6875 (class 3256 OID 43800)

--

CREATE POLICY user_safety_settings_update_own_or_admin ON public.user_safety_settings FOR UPDATE TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))) WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6597 (class 0 OID 39828)
-- Dependencies: 413

--

ALTER TABLE public.wallet_accounts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6617 (class 0 OID 40034)
-- Dependencies: 435

--

ALTER TABLE public.wallet_entries ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6723 (class 3256 OID 42059)

--

CREATE POLICY wallet_entries_select_own ON public.wallet_entries FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6618 (class 0 OID 40042)
-- Dependencies: 437

--

ALTER TABLE public.wallet_holds ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6724 (class 3256 OID 42060)

--

CREATE POLICY wallet_holds_select_own ON public.wallet_holds FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6619 (class 0 OID 40053)
-- Dependencies: 438

--

ALTER TABLE public.wallet_withdraw_payout_methods ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6620 (class 0 OID 40059)
-- Dependencies: 439

--

ALTER TABLE public.wallet_withdraw_requests ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6621 (class 0 OID 40070)
-- Dependencies: 440

--

ALTER TABLE public.wallet_withdrawal_policy ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6666 (class 0 OID 44046)
-- Dependencies: 490

--

ALTER TABLE public.whatsapp_booking_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6884 (class 3256 OID 44079)

--

CREATE POLICY whatsapp_booking_tokens_select_admin ON public.whatsapp_booking_tokens FOR SELECT TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6893 (class 3256 OID 44150)

--

CREATE POLICY whatsapp_booking_tokens_write_admin_del ON public.whatsapp_booking_tokens FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6891 (class 3256 OID 44148)

--

CREATE POLICY whatsapp_booking_tokens_write_admin_ins ON public.whatsapp_booking_tokens FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6892 (class 3256 OID 44149)

--

CREATE POLICY whatsapp_booking_tokens_write_admin_upd ON public.whatsapp_booking_tokens FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6665 (class 0 OID 44029)
-- Dependencies: 489

--

ALTER TABLE public.whatsapp_messages ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6883 (class 3256 OID 44077)

--

CREATE POLICY whatsapp_messages_select_admin ON public.whatsapp_messages FOR SELECT TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6896 (class 3256 OID 44153)

--

CREATE POLICY whatsapp_messages_write_admin_del ON public.whatsapp_messages FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6894 (class 3256 OID 44151)

--

CREATE POLICY whatsapp_messages_write_admin_ins ON public.whatsapp_messages FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6895 (class 3256 OID 44152)

--

CREATE POLICY whatsapp_messages_write_admin_upd ON public.whatsapp_messages FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6667 (class 0 OID 44107)
-- Dependencies: 492

--

ALTER TABLE public.whatsapp_thread_notes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6885 (class 3256 OID 44126)

--

CREATE POLICY whatsapp_thread_notes_select_admin ON public.whatsapp_thread_notes FOR SELECT TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6899 (class 3256 OID 44156)

--

CREATE POLICY whatsapp_thread_notes_write_admin_del ON public.whatsapp_thread_notes FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6897 (class 3256 OID 44154)

--

CREATE POLICY whatsapp_thread_notes_write_admin_ins ON public.whatsapp_thread_notes FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6898 (class 3256 OID 44155)

--

CREATE POLICY whatsapp_thread_notes_write_admin_upd ON public.whatsapp_thread_notes FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6664 (class 0 OID 44012)
-- Dependencies: 488

--

ALTER TABLE public.whatsapp_threads ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6882 (class 3256 OID 44075)

--

CREATE POLICY whatsapp_threads_select_admin ON public.whatsapp_threads FOR SELECT TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6902 (class 3256 OID 44159)

--

CREATE POLICY whatsapp_threads_write_admin_del ON public.whatsapp_threads FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6900 (class 3256 OID 44157)

--

CREATE POLICY whatsapp_threads_write_admin_ins ON public.whatsapp_threads FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6901 (class 3256 OID 44158)

--

CREATE POLICY whatsapp_threads_write_admin_upd ON public.whatsapp_threads FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6725 (class 3256 OID 42061)

--

CREATE POLICY withdraw_insert_own ON public.wallet_withdraw_requests FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6729 (class 3256 OID 42066)

--

CREATE POLICY withdraw_payout_methods_admin_update ON public.wallet_withdraw_payout_methods FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6728 (class 3256 OID 42065)

--

CREATE POLICY withdraw_payout_methods_select ON public.wallet_withdraw_payout_methods FOR SELECT TO authenticated USING ((( SELECT auth.uid() AS uid) IS NOT NULL));


--
-- TOC entry 6835 (class 3256 OID 42217)

--

CREATE POLICY withdraw_policy_admin_update ON public.wallet_withdrawal_policy FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6834 (class 3256 OID 42216)

--

CREATE POLICY withdraw_policy_select_public ON public.wallet_withdrawal_policy FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6726 (class 3256 OID 42062)

--

CREATE POLICY withdraw_select_own_or_admin ON public.wallet_withdraw_requests FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6727 (class 3256 OID 42063)

--

CREATE POLICY withdraw_update_admin_or_cancel_own ON public.wallet_withdraw_requests FOR UPDATE TO authenticated USING ((( SELECT public.is_admin() AS is_admin) OR ((user_id = ( SELECT auth.uid() AS uid)) AND (status = 'requested'::public.withdraw_request_status)))) WITH CHECK ((( SELECT public.is_admin() AS is_admin) OR ((user_id = ( SELECT auth.uid() AS uid)) AND (status = ANY (ARRAY['requested'::public.withdraw_request_status, 'cancelled'::public.withdraw_request_status])))));


--
-- TOC entry 6584 (class 0 OID 17239)
-- Dependencies: 383

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.driver_locations;


--
-- TOC entry 6928 (class 6106 OID 40789)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.driver_stats_daily;


--
-- TOC entry 6917 (class 6106 OID 40536)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.drivers;


--
-- TOC entry 6937 (class 6106 OID 41049)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.kyc_documents;


--
-- TOC entry 6936 (class 6106 OID 41048)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.kyc_submissions;


--
-- TOC entry 6942 (class 6106 OID 42234)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.payment_intents;


--
-- TOC entry 6918 (class 6106 OID 40537)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.payments;


--
-- TOC entry 6941 (class 6106 OID 42233)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.provider_events;


--
-- TOC entry 6932 (class 6106 OID 41044)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_chat_messages;


--
-- TOC entry 6933 (class 6106 OID 41045)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_chat_read_receipts;


--
-- TOC entry 6938 (class 6106 OID 42230)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_chat_threads;


--
-- TOC entry 6934 (class 6106 OID 41046)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_chat_typing;


--
-- TOC entry 6919 (class 6106 OID 40538)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_events;


--
-- TOC entry 6940 (class 6106 OID 42232)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_incidents;


--
-- TOC entry 6944 (class 6106 OID 44139)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_intents;


--
-- TOC entry 6939 (class 6106 OID 42231)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_receipts;


--
-- TOC entry 6920 (class 6106 OID 40539)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_requests;


--
-- TOC entry 6945 (class 6106 OID 44140)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ridecheck_events;


--
-- TOC entry 6946 (class 6106 OID 44141)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ridecheck_responses;


--
-- TOC entry 6921 (class 6106 OID 40540)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.rides;


--
-- TOC entry 6943 (class 6106 OID 44138)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.scheduled_rides;


--
-- TOC entry 6931 (class 6106 OID 41043)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.support_messages;


--
-- TOC entry 6930 (class 6106 OID 41042)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.support_tickets;


--
-- TOC entry 6922 (class 6106 OID 40541)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.topup_intents;


--
-- TOC entry 6935 (class 6106 OID 41047)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.trip_share_tokens;


--
-- TOC entry 6929 (class 6106 OID 41041)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.trusted_contacts;


--
-- TOC entry 6923 (class 6106 OID 40542)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.user_notifications;


--
-- TOC entry 6924 (class 6106 OID 40543)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_accounts;


--
-- TOC entry 6925 (class 6106 OID 40544)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_entries;


--
-- TOC entry 6926 (class 6106 OID 40545)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_holds;


--
-- TOC entry 6927 (class 6106 OID 40546)

--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_withdraw_requests;


--
-- TOC entry 6915 (class 6106 OID 24116)

--

REVOKE ALL ON FUNCTION public.achievement_claim(p_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.achievement_claim(p_key text) TO service_role;


--
-- TOC entry 7769 (class 0 OID 0)
-- Dependencies: 410

--

GRANT ALL ON TABLE public.gift_codes TO authenticated;
GRANT ALL ON TABLE public.gift_codes TO service_role;


--
-- TOC entry 7770 (class 0 OID 0)
-- Dependencies: 725

--

REVOKE ALL ON FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) TO service_role;


--
-- TOC entry 7771 (class 0 OID 0)
-- Dependencies: 1312

--

REVOKE ALL ON FUNCTION public.admin_create_service_area_bbox(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer, p_is_active boolean, p_pricing_config_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_create_service_area_bbox(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer, p_is_active boolean, p_pricing_config_id uuid) TO service_role;


--
-- TOC entry 7772 (class 0 OID 0)
-- Dependencies: 1368

--

REVOKE ALL ON FUNCTION public.admin_create_service_area_bbox_v2(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer, p_is_active boolean, p_pricing_config_id uuid, p_notes text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_create_service_area_bbox_v2(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer, p_is_active boolean, p_pricing_config_id uuid, p_notes text) TO service_role;
GRANT ALL ON FUNCTION public.admin_create_service_area_bbox_v2(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer, p_is_active boolean, p_pricing_config_id uuid, p_notes text) TO authenticated;


--
-- TOC entry 7773 (class 0 OID 0)
-- Dependencies: 644

--

REVOKE ALL ON FUNCTION public.admin_create_service_area_bbox_v2(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer, p_is_active boolean, p_pricing_config_id uuid, p_min_base_fare_iqd integer, p_surge_multiplier numeric, p_surge_reason text, p_notes text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_create_service_area_bbox_v2(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer, p_is_active boolean, p_pricing_config_id uuid, p_min_base_fare_iqd integer, p_surge_multiplier numeric, p_surge_reason text, p_notes text) TO service_role;
GRANT ALL ON FUNCTION public.admin_create_service_area_bbox_v2(p_name text, p_governorate text, p_min_lat double precision, p_min_lng double precision, p_max_lat double precision, p_max_lng double precision, p_priority integer, p_is_active boolean, p_pricing_config_id uuid, p_min_base_fare_iqd integer, p_surge_multiplier numeric, p_surge_reason text, p_notes text) TO authenticated;


--
-- TOC entry 7774 (class 0 OID 0)
-- Dependencies: 1119

--

REVOKE ALL ON FUNCTION public.admin_mark_stale_drivers_offline(p_stale_after_seconds integer, p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_mark_stale_drivers_offline(p_stale_after_seconds integer, p_limit integer) TO service_role;


--
-- TOC entry 7775 (class 0 OID 0)
-- Dependencies: 1140

--

REVOKE ALL ON FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) TO service_role;
GRANT ALL ON FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) TO authenticated;


--
-- TOC entry 7776 (class 0 OID 0)
-- Dependencies: 869

--

REVOKE ALL ON FUNCTION public.admin_ridecheck_escalate(p_event_id uuid, p_note text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_ridecheck_escalate(p_event_id uuid, p_note text) TO service_role;
GRANT ALL ON FUNCTION public.admin_ridecheck_escalate(p_event_id uuid, p_note text) TO authenticated;


--
-- TOC entry 7777 (class 0 OID 0)
-- Dependencies: 1321

--

REVOKE ALL ON FUNCTION public.admin_ridecheck_resolve(p_event_id uuid, p_note text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_ridecheck_resolve(p_event_id uuid, p_note text) TO service_role;
GRANT ALL ON FUNCTION public.admin_ridecheck_resolve(p_event_id uuid, p_note text) TO authenticated;


--
-- TOC entry 7778 (class 0 OID 0)
-- Dependencies: 1229

--

REVOKE ALL ON FUNCTION public.admin_update_pricing_config_caps(p_id uuid, p_max_surge_multiplier numeric) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_update_pricing_config_caps(p_id uuid, p_max_surge_multiplier numeric) TO service_role;
GRANT ALL ON FUNCTION public.admin_update_pricing_config_caps(p_id uuid, p_max_surge_multiplier numeric) TO authenticated;


--
-- TOC entry 7779 (class 0 OID 0)
-- Dependencies: 727

--

REVOKE ALL ON FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) TO service_role;
GRANT ALL ON FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) TO authenticated;


--
-- TOC entry 7780 (class 0 OID 0)
-- Dependencies: 937

--

REVOKE ALL ON FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) TO service_role;
GRANT ALL ON FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) TO authenticated;


--
-- TOC entry 7781 (class 0 OID 0)
-- Dependencies: 1406

--

REVOKE ALL ON FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) TO service_role;


--
-- TOC entry 7782 (class 0 OID 0)
-- Dependencies: 649

--

REVOKE ALL ON FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) TO service_role;


--
-- TOC entry 7783 (class 0 OID 0)
-- Dependencies: 582

--

REVOKE ALL ON FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) TO service_role;


--
-- TOC entry 7784 (class 0 OID 0)
-- Dependencies: 775

--

REVOKE ALL ON FUNCTION public.apply_rating_aggregate() FROM PUBLIC;
GRANT ALL ON FUNCTION public.apply_rating_aggregate() TO service_role;


--
-- TOC entry 7785 (class 0 OID 0)
-- Dependencies: 533

--

REVOKE ALL ON FUNCTION public.apply_referral_rewards(p_referred_id uuid, p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.apply_referral_rewards(p_referred_id uuid, p_ride_id uuid) TO service_role;


--
-- TOC entry 7786 (class 0 OID 0)
-- Dependencies: 939

--

REVOKE ALL ON FUNCTION public.create_receipt_from_payment() FROM PUBLIC;
GRANT ALL ON FUNCTION public.create_receipt_from_payment() TO service_role;


--
-- TOC entry 7787 (class 0 OID 0)
-- Dependencies: 1389

--

REVOKE ALL ON FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) FROM PUBLIC;
GRANT ALL ON FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) TO service_role;
GRANT ALL ON FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) TO authenticated;


--
-- TOC entry 7788 (class 0 OID 0)
-- Dependencies: 910

--

REVOKE ALL ON FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) TO service_role;


--
-- TOC entry 7789 (class 0 OID 0)
-- Dependencies: 1296

--

REVOKE ALL ON FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer) TO service_role;


--
-- TOC entry 7790 (class 0 OID 0)
-- Dependencies: 1386

--

REVOKE ALL ON FUNCTION public.driver_leaderboard_refresh_day(p_day date) FROM PUBLIC;
GRANT ALL ON FUNCTION public.driver_leaderboard_refresh_day(p_day date) TO service_role;


--
-- TOC entry 7791 (class 0 OID 0)
-- Dependencies: 832

--

REVOKE ALL ON FUNCTION public.driver_stats_rollup_day(p_day date) FROM PUBLIC;
GRANT ALL ON FUNCTION public.driver_stats_rollup_day(p_day date) TO service_role;


--
-- TOC entry 7792 (class 0 OID 0)
-- Dependencies: 556

--

REVOKE ALL ON FUNCTION public.drivers_force_id_from_auth_uid() FROM PUBLIC;
GRANT ALL ON FUNCTION public.drivers_force_id_from_auth_uid() TO service_role;


--
-- TOC entry 7793 (class 0 OID 0)
-- Dependencies: 648

--

REVOKE ALL ON FUNCTION public.enqueue_notification_outbox() FROM PUBLIC;
GRANT ALL ON FUNCTION public.enqueue_notification_outbox() TO service_role;


--
-- TOC entry 7794 (class 0 OID 0)
-- Dependencies: 828

--

REVOKE ALL ON FUNCTION public.ensure_referral_code(p_user_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.ensure_referral_code(p_user_id uuid) TO service_role;


--
-- TOC entry 7795 (class 0 OID 0)
-- Dependencies: 1036

--

REVOKE ALL ON FUNCTION public.ensure_wallet_account() FROM PUBLIC;
GRANT ALL ON FUNCTION public.ensure_wallet_account() TO service_role;


--
-- TOC entry 7796 (class 0 OID 0)
-- Dependencies: 1227

--

REVOKE ALL ON FUNCTION public.estimate_ride_quote_breakdown_iqd_v1(_pickup extensions.geography, _dropoff extensions.geography, _product_code text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.estimate_ride_quote_breakdown_iqd_v1(_pickup extensions.geography, _dropoff extensions.geography, _product_code text) TO service_role;


--
-- TOC entry 7797 (class 0 OID 0)
-- Dependencies: 542

--

REVOKE ALL ON FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) FROM PUBLIC;
GRANT ALL ON FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) TO service_role;


--
-- TOC entry 7798 (class 0 OID 0)
-- Dependencies: 943

--

REVOKE ALL ON FUNCTION public.estimate_ride_quote_iqd_v2(_pickup extensions.geography, _dropoff extensions.geography, _product_code text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.estimate_ride_quote_iqd_v2(_pickup extensions.geography, _dropoff extensions.geography, _product_code text) TO service_role;


--
-- TOC entry 7799 (class 0 OID 0)
-- Dependencies: 1054

--

REVOKE ALL ON FUNCTION public.get_assigned_driver(p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.get_assigned_driver(p_ride_id uuid) TO service_role;


--
-- TOC entry 7800 (class 0 OID 0)
-- Dependencies: 681

--

REVOKE ALL ON FUNCTION public.get_driver_leaderboard(p_period text, p_period_start date, p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.get_driver_leaderboard(p_period text, p_period_start date, p_limit integer) TO service_role;


--
-- TOC entry 7801 (class 0 OID 0)
-- Dependencies: 1114

--

REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- TOC entry 7802 (class 0 OID 0)
-- Dependencies: 693

--

REVOKE ALL ON FUNCTION public.is_admin() FROM PUBLIC;
GRANT ALL ON FUNCTION public.is_admin() TO service_role;
GRANT ALL ON FUNCTION public.is_admin() TO authenticated;


--
-- TOC entry 7803 (class 0 OID 0)
-- Dependencies: 1031

--

REVOKE ALL ON FUNCTION public.is_admin(p_user uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.is_admin(p_user uuid) TO service_role;
GRANT ALL ON FUNCTION public.is_admin(p_user uuid) TO authenticated;


--
-- TOC entry 7804 (class 0 OID 0)
-- Dependencies: 921

--

REVOKE ALL ON FUNCTION public.is_pickup_pin_required_v1(p_rider_id uuid, p_driver_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.is_pickup_pin_required_v1(p_rider_id uuid, p_driver_id uuid) TO service_role;


--
-- TOC entry 7805 (class 0 OID 0)
-- Dependencies: 785

--

REVOKE ALL ON FUNCTION public.notification_outbox_claim(p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.notification_outbox_claim(p_limit integer) TO service_role;


--
-- TOC entry 7806 (class 0 OID 0)
-- Dependencies: 539

--

REVOKE ALL ON FUNCTION public.notification_outbox_mark(p_outbox_id bigint, p_status text, p_error text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.notification_outbox_mark(p_outbox_id bigint, p_status text, p_error text) TO service_role;


--
-- TOC entry 7807 (class 0 OID 0)
-- Dependencies: 717

--

REVOKE ALL ON FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) TO service_role;


--
-- TOC entry 7808 (class 0 OID 0)
-- Dependencies: 1032

--

REVOKE ALL ON FUNCTION public.notify_users_bulk(p_user_ids uuid[], p_kind text, p_title text, p_body text, p_data jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.notify_users_bulk(p_user_ids uuid[], p_kind text, p_title text, p_body text, p_data jsonb) TO service_role;


--
-- TOC entry 7809 (class 0 OID 0)
-- Dependencies: 1409

--

REVOKE ALL ON FUNCTION public.on_ride_completed_side_effects() FROM PUBLIC;
GRANT ALL ON FUNCTION public.on_ride_completed_side_effects() TO service_role;


--
-- TOC entry 7810 (class 0 OID 0)
-- Dependencies: 722

--

REVOKE ALL ON FUNCTION public.on_ride_completed_v1(p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.on_ride_completed_v1(p_ride_id uuid) TO service_role;


--
-- TOC entry 7811 (class 0 OID 0)
-- Dependencies: 1019

--

REVOKE ALL ON FUNCTION public.profile_kyc_init() FROM PUBLIC;
GRANT ALL ON FUNCTION public.profile_kyc_init() TO service_role;


--
-- TOC entry 7812 (class 0 OID 0)
-- Dependencies: 971

--

REVOKE ALL ON FUNCTION public.quote_breakdown_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision, p_product_code text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.quote_breakdown_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision, p_product_code text) TO service_role;
GRANT ALL ON FUNCTION public.quote_breakdown_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision, p_product_code text) TO anon;


--
-- TOC entry 7813 (class 0 OID 0)
-- Dependencies: 889

--

REVOKE ALL ON FUNCTION public.quote_products_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision) FROM PUBLIC;
GRANT ALL ON FUNCTION public.quote_products_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision) TO service_role;


--
-- TOC entry 7814 (class 0 OID 0)
-- Dependencies: 1419

--

REVOKE ALL ON FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) TO service_role;


--
-- TOC entry 7815 (class 0 OID 0)
-- Dependencies: 1064

--

REVOKE ALL ON FUNCTION public.redeem_gift_code(p_code text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.redeem_gift_code(p_code text) TO service_role;
GRANT ALL ON FUNCTION public.redeem_gift_code(p_code text) TO authenticated;


--
-- TOC entry 7816 (class 0 OID 0)
-- Dependencies: 1128

--

REVOKE ALL ON FUNCTION public.referral_apply_code(p_code text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.referral_apply_code(p_code text) TO service_role;


--
-- TOC entry 7817 (class 0 OID 0)
-- Dependencies: 1011

--

REVOKE ALL ON FUNCTION public.referral_apply_rewards_for_ride(p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.referral_apply_rewards_for_ride(p_ride_id uuid) TO service_role;


--
-- TOC entry 7818 (class 0 OID 0)
-- Dependencies: 685

--

REVOKE ALL ON FUNCTION public.referral_claim(p_code text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.referral_claim(p_code text) TO service_role;


--
-- TOC entry 7819 (class 0 OID 0)
-- Dependencies: 1261

--

REVOKE ALL ON FUNCTION public.referral_code_init() FROM PUBLIC;
GRANT ALL ON FUNCTION public.referral_code_init() TO service_role;


--
-- TOC entry 7820 (class 0 OID 0)
-- Dependencies: 1050

--

REVOKE ALL ON FUNCTION public.referral_generate_code() FROM PUBLIC;
GRANT ALL ON FUNCTION public.referral_generate_code() TO service_role;


--
-- TOC entry 7821 (class 0 OID 0)
-- Dependencies: 861

--

REVOKE ALL ON FUNCTION public.referral_on_ride_completed() FROM PUBLIC;
GRANT ALL ON FUNCTION public.referral_on_ride_completed() TO service_role;


--
-- TOC entry 7822 (class 0 OID 0)
-- Dependencies: 750

--

REVOKE ALL ON FUNCTION public.referral_status() FROM PUBLIC;
GRANT ALL ON FUNCTION public.referral_status() TO service_role;


--
-- TOC entry 7823 (class 0 OID 0)
-- Dependencies: 770

--

REVOKE ALL ON FUNCTION public.refresh_driver_rank_snapshots(p_period text, p_period_start date, p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.refresh_driver_rank_snapshots(p_period text, p_period_start date, p_limit integer) TO service_role;


--
-- TOC entry 7824 (class 0 OID 0)
-- Dependencies: 887

--

REVOKE ALL ON FUNCTION public.resolve_service_area(p_lat double precision, p_lng double precision) FROM PUBLIC;
GRANT ALL ON FUNCTION public.resolve_service_area(p_lat double precision, p_lng double precision) TO service_role;
GRANT ALL ON FUNCTION public.resolve_service_area(p_lat double precision, p_lng double precision) TO anon;


--
-- TOC entry 7825 (class 0 OID 0)
-- Dependencies: 1068

--

REVOKE ALL ON FUNCTION public.revoke_trip_share_tokens_on_ride_end() FROM PUBLIC;
GRANT ALL ON FUNCTION public.revoke_trip_share_tokens_on_ride_end() TO service_role;


--
-- TOC entry 7826 (class 0 OID 0)
-- Dependencies: 1270

--

REVOKE ALL ON FUNCTION public.ride_chat_get_or_create_thread(p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.ride_chat_get_or_create_thread(p_ride_id uuid) TO service_role;


--
-- TOC entry 7827 (class 0 OID 0)
-- Dependencies: 1097

--

REVOKE ALL ON FUNCTION public.ride_chat_notify_on_message() FROM PUBLIC;
GRANT ALL ON FUNCTION public.ride_chat_notify_on_message() TO service_role;


--
-- TOC entry 7828 (class 0 OID 0)
-- Dependencies: 1339

--

REVOKE ALL ON FUNCTION public.ride_requests_clear_match_fields() FROM PUBLIC;
GRANT ALL ON FUNCTION public.ride_requests_clear_match_fields() TO service_role;


--
-- TOC entry 7829 (class 0 OID 0)
-- Dependencies: 1090

--

REVOKE ALL ON FUNCTION public.ride_requests_release_driver_on_unmatch() FROM PUBLIC;
GRANT ALL ON FUNCTION public.ride_requests_release_driver_on_unmatch() TO service_role;


--
-- TOC entry 7830 (class 0 OID 0)
-- Dependencies: 1307

--

REVOKE ALL ON FUNCTION public.ride_requests_set_quote() FROM PUBLIC;
GRANT ALL ON FUNCTION public.ride_requests_set_quote() TO service_role;


--
-- TOC entry 7831 (class 0 OID 0)
-- Dependencies: 804

--

REVOKE ALL ON FUNCTION public.ride_requests_set_status_timestamps() FROM PUBLIC;
GRANT ALL ON FUNCTION public.ride_requests_set_status_timestamps() TO service_role;


--
-- TOC entry 7832 (class 0 OID 0)
-- Dependencies: 1333

--

REVOKE ALL ON FUNCTION public.ridecheck_open_event_v1(p_ride_id uuid, p_kind text, p_metadata jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.ridecheck_open_event_v1(p_ride_id uuid, p_kind text, p_metadata jsonb) TO service_role;


--
-- TOC entry 7833 (class 0 OID 0)
-- Dependencies: 630

--

REVOKE ALL ON FUNCTION public.ridecheck_run_v1() FROM PUBLIC;
GRANT ALL ON FUNCTION public.ridecheck_run_v1() TO service_role;


--
-- TOC entry 7834 (class 0 OID 0)
-- Dependencies: 671

--

REVOKE ALL ON FUNCTION public.scheduled_rides_execute_due(p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.scheduled_rides_execute_due(p_limit integer) TO service_role;


--
-- TOC entry 7835 (class 0 OID 0)
-- Dependencies: 903

--

REVOKE ALL ON FUNCTION public.set_service_area_id_from_pickup() FROM PUBLIC;
GRANT ALL ON FUNCTION public.set_service_area_id_from_pickup() TO service_role;


--
-- TOC entry 7836 (class 0 OID 0)
-- Dependencies: 678

--

REVOKE ALL ON FUNCTION public.set_updated_at() FROM PUBLIC;
GRANT ALL ON FUNCTION public.set_updated_at() TO service_role;


--
-- TOC entry 7837 (class 0 OID 0)
-- Dependencies: 1008

--

REVOKE ALL ON FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) FROM PUBLIC;
GRANT ALL ON FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) TO service_role;


--
-- TOC entry 7838 (class 0 OID 0)
-- Dependencies: 853

--

REVOKE ALL ON FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) TO service_role;
GRANT ALL ON FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) TO authenticated;


--
-- TOC entry 7839 (class 0 OID 0)
-- Dependencies: 734

--

REVOKE ALL ON FUNCTION public.support_ticket_touch_updated_at() FROM PUBLIC;
GRANT ALL ON FUNCTION public.support_ticket_touch_updated_at() TO service_role;


--
-- TOC entry 7840 (class 0 OID 0)
-- Dependencies: 809

--

REVOKE ALL ON FUNCTION public.sync_profile_kyc_from_submission() FROM PUBLIC;
GRANT ALL ON FUNCTION public.sync_profile_kyc_from_submission() TO service_role;


--
-- TOC entry 7841 (class 0 OID 0)
-- Dependencies: 976

--

REVOKE ALL ON FUNCTION public.sync_public_profile() FROM PUBLIC;
GRANT ALL ON FUNCTION public.sync_public_profile() TO service_role;


--
-- TOC entry 7842 (class 0 OID 0)
-- Dependencies: 622

--

REVOKE ALL ON FUNCTION public.tg__set_updated_at() FROM PUBLIC;
GRANT ALL ON FUNCTION public.tg__set_updated_at() TO service_role;


--
-- TOC entry 7843 (class 0 OID 0)
-- Dependencies: 411

--

GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN ON TABLE public.rides TO authenticated;
GRANT ALL ON TABLE public.rides TO service_role;


--
-- TOC entry 7844 (class 0 OID 0)
-- Dependencies: 525

--

REVOKE ALL ON FUNCTION public.transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer) TO service_role;


--
-- TOC entry 7845 (class 0 OID 0)
-- Dependencies: 1299

--

REVOKE ALL ON FUNCTION public.trusted_contact_outbox_claim(p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.trusted_contact_outbox_claim(p_limit integer) TO service_role;


--
-- TOC entry 7846 (class 0 OID 0)
-- Dependencies: 1214

--

REVOKE ALL ON FUNCTION public.trusted_contact_outbox_mark(p_outbox_id uuid, p_status text, p_error text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.trusted_contact_outbox_mark(p_outbox_id uuid, p_status text, p_error text) TO service_role;


--
-- TOC entry 7847 (class 0 OID 0)
-- Dependencies: 521

--

REVOKE ALL ON FUNCTION public.trusted_contact_outbox_mark_v2(p_outbox_id uuid, p_result text, p_error text, p_retry_in_seconds integer, p_http_status integer, p_provider_message_id text, p_response text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.trusted_contact_outbox_mark_v2(p_outbox_id uuid, p_result text, p_error text, p_retry_in_seconds integer, p_http_status integer, p_provider_message_id text, p_response text) TO service_role;


--
-- TOC entry 7848 (class 0 OID 0)
-- Dependencies: 578

--

REVOKE ALL ON FUNCTION public.trusted_contacts_enforce_active_limit() FROM PUBLIC;
GRANT ALL ON FUNCTION public.trusted_contacts_enforce_active_limit() TO service_role;


--
-- TOC entry 7849 (class 0 OID 0)
-- Dependencies: 1442

--

REVOKE ALL ON FUNCTION public.try_get_vault_secret(p_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.try_get_vault_secret(p_name text) TO service_role;


--
-- TOC entry 7850 (class 0 OID 0)
-- Dependencies: 620

--

REVOKE ALL ON FUNCTION public.update_driver_achievements(p_driver_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.update_driver_achievements(p_driver_id uuid) TO service_role;


--
-- TOC entry 7851 (class 0 OID 0)
-- Dependencies: 1289

--

REVOKE ALL ON FUNCTION public.update_receipt_on_refund() FROM PUBLIC;
GRANT ALL ON FUNCTION public.update_receipt_on_refund() TO service_role;


--
-- TOC entry 7852 (class 0 OID 0)
-- Dependencies: 702

--

REVOKE ALL ON FUNCTION public.upsert_device_token(p_token text, p_platform text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.upsert_device_token(p_token text, p_platform text) TO service_role;


--
-- TOC entry 7853 (class 0 OID 0)
-- Dependencies: 1099

--

REVOKE ALL ON FUNCTION public.user_notifications_mark_all_read() FROM PUBLIC;
GRANT ALL ON FUNCTION public.user_notifications_mark_all_read() TO service_role;
GRANT ALL ON FUNCTION public.user_notifications_mark_all_read() TO authenticated;


--
-- TOC entry 7854 (class 0 OID 0)
-- Dependencies: 611

--

REVOKE ALL ON FUNCTION public.user_notifications_mark_read(p_notification_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.user_notifications_mark_read(p_notification_id uuid) TO service_role;
GRANT ALL ON FUNCTION public.user_notifications_mark_read(p_notification_id uuid) TO authenticated;


--
-- TOC entry 7855 (class 0 OID 0)
-- Dependencies: 1151

--

REVOKE ALL ON FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) TO service_role;
GRANT ALL ON FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) TO authenticated;


--
-- TOC entry 7856 (class 0 OID 0)
-- Dependencies: 1181

--

REVOKE ALL ON FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) TO service_role;


--
-- TOC entry 7857 (class 0 OID 0)
-- Dependencies: 412

--

GRANT ALL ON TABLE public.topup_intents TO authenticated;
GRANT ALL ON TABLE public.topup_intents TO service_role;


--
-- TOC entry 7858 (class 0 OID 0)
-- Dependencies: 902

--

REVOKE ALL ON FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) TO service_role;


--
-- TOC entry 7859 (class 0 OID 0)
-- Dependencies: 1053

--

REVOKE ALL ON FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) TO service_role;


--
-- TOC entry 7860 (class 0 OID 0)
-- Dependencies: 413

--

GRANT ALL ON TABLE public.wallet_accounts TO authenticated;
GRANT ALL ON TABLE public.wallet_accounts TO service_role;


--
-- TOC entry 7861 (class 0 OID 0)
-- Dependencies: 946

--

REVOKE ALL ON FUNCTION public.wallet_get_my_account() FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_get_my_account() TO service_role;
GRANT ALL ON FUNCTION public.wallet_get_my_account() TO authenticated;


--
-- TOC entry 7862 (class 0 OID 0)
-- Dependencies: 878

--

REVOKE ALL ON FUNCTION public.wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint) TO service_role;


--
-- TOC entry 7863 (class 0 OID 0)
-- Dependencies: 720

--

REVOKE ALL ON FUNCTION public.wallet_holds_normalize_status() FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_holds_normalize_status() TO service_role;


--
-- TOC entry 7864 (class 0 OID 0)
-- Dependencies: 854

--

REVOKE ALL ON FUNCTION public.wallet_release_ride_hold(p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_release_ride_hold(p_ride_id uuid) TO service_role;


--
-- TOC entry 7865 (class 0 OID 0)
-- Dependencies: 1258

--

REVOKE ALL ON FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) TO service_role;
GRANT ALL ON FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) TO authenticated;


--
-- TOC entry 7866 (class 0 OID 0)
-- Dependencies: 877

--

REVOKE ALL ON FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) TO service_role;


--
-- TOC entry 7867 (class 0 OID 0)
-- Dependencies: 561

--

REVOKE ALL ON FUNCTION public.whatsapp_booking_token_consume_v1(p_token text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.whatsapp_booking_token_consume_v1(p_token text) TO service_role;


--
-- TOC entry 7868 (class 0 OID 0)
-- Dependencies: 684

--

REVOKE ALL ON FUNCTION public.whatsapp_booking_token_create_v1(p_thread_id uuid, p_expires_minutes integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.whatsapp_booking_token_create_v1(p_thread_id uuid, p_expires_minutes integer) TO service_role;
GRANT ALL ON FUNCTION public.whatsapp_booking_token_create_v1(p_thread_id uuid, p_expires_minutes integer) TO authenticated;


--
-- TOC entry 7869 (class 0 OID 0)
-- Dependencies: 1369

--

REVOKE ALL ON FUNCTION public.whatsapp_booking_token_view_v1(p_token text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.whatsapp_booking_token_view_v1(p_token text) TO service_role;


--
-- TOC entry 7870 (class 0 OID 0)
-- Dependencies: 1322

--

REVOKE ALL ON FUNCTION public.whatsapp_booking_tokens_cleanup_v1(p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.whatsapp_booking_tokens_cleanup_v1(p_limit integer) TO service_role;


--
-- TOC entry 7871 (class 0 OID 0)
-- Dependencies: 1342

--

REVOKE ALL ON FUNCTION public.whatsapp_messages_failed_outbound_to_followup_v1() FROM PUBLIC;
GRANT ALL ON FUNCTION public.whatsapp_messages_failed_outbound_to_followup_v1() TO service_role;


--
-- TOC entry 7872 (class 0 OID 0)
-- Dependencies: 761

--

REVOKE ALL ON FUNCTION public.whatsapp_messages_touch_updated_at_v1() FROM PUBLIC;
GRANT ALL ON FUNCTION public.whatsapp_messages_touch_updated_at_v1() TO service_role;


--
-- TOC entry 7873 (class 0 OID 0)
-- Dependencies: 526

--

GRANT ALL ON TABLE public.achievement_progress TO authenticated;
GRANT ALL ON TABLE public.achievement_progress TO service_role;


--
-- TOC entry 7959 (class 0 OID 0)
-- Dependencies: 449

--

GRANT ALL ON TABLE public.achievements TO service_role;


--
-- TOC entry 7960 (class 0 OID 0)
-- Dependencies: 496

--

GRANT ALL ON TABLE public.admin_security_audit_functions_v1 TO authenticated;
GRANT ALL ON TABLE public.admin_security_audit_functions_v1 TO service_role;


--
-- TOC entry 7961 (class 0 OID 0)
-- Dependencies: 498

--

GRANT ALL ON TABLE public.admin_security_audit_policies_v1 TO authenticated;
GRANT ALL ON TABLE public.admin_security_audit_policies_v1 TO service_role;


--
-- TOC entry 7962 (class 0 OID 0)
-- Dependencies: 497

--

GRANT ALL ON TABLE public.admin_security_audit_schema_v1 TO authenticated;
GRANT ALL ON TABLE public.admin_security_audit_schema_v1 TO service_role;


--
-- TOC entry 7963 (class 0 OID 0)
-- Dependencies: 414

--

GRANT ALL ON TABLE public.api_rate_limits TO service_role;


--
-- TOC entry 7964 (class 0 OID 0)
-- Dependencies: 415

--

GRANT ALL ON TABLE public.app_events TO service_role;


--
-- TOC entry 7965 (class 0 OID 0)
-- Dependencies: 443

--

GRANT ALL ON TABLE public.device_tokens TO authenticated;
GRANT ALL ON TABLE public.device_tokens TO service_role;


--
-- TOC entry 7967 (class 0 OID 0)
-- Dependencies: 442

--

GRANT ALL ON SEQUENCE public.device_tokens_id_seq TO anon;
GRANT ALL ON SEQUENCE public.device_tokens_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.device_tokens_id_seq TO service_role;


--
-- TOC entry 7968 (class 0 OID 0)
-- Dependencies: 446

--

GRANT ALL ON TABLE public.driver_counters TO authenticated;
GRANT ALL ON TABLE public.driver_counters TO service_role;


--
-- TOC entry 7969 (class 0 OID 0)
-- Dependencies: 474

--

GRANT ALL ON TABLE public.driver_leaderboard_daily TO authenticated;
GRANT ALL ON TABLE public.driver_leaderboard_daily TO service_role;


--
-- TOC entry 7970 (class 0 OID 0)
-- Dependencies: 416

--

GRANT ALL ON TABLE public.driver_locations TO authenticated;
GRANT ALL ON TABLE public.driver_locations TO service_role;


--
-- TOC entry 7971 (class 0 OID 0)
-- Dependencies: 448

--

GRANT ALL ON TABLE public.driver_rank_snapshots TO authenticated;
GRANT ALL ON TABLE public.driver_rank_snapshots TO service_role;


--
-- TOC entry 7972 (class 0 OID 0)
-- Dependencies: 447

--

GRANT ALL ON TABLE public.driver_stats_daily TO authenticated;
GRANT ALL ON TABLE public.driver_stats_daily TO service_role;


--
-- TOC entry 7973 (class 0 OID 0)
-- Dependencies: 417

--

GRANT ALL ON TABLE public.driver_vehicles TO authenticated;
GRANT ALL ON TABLE public.driver_vehicles TO service_role;


--
-- TOC entry 7974 (class 0 OID 0)
-- Dependencies: 418

--

GRANT ALL ON TABLE public.drivers TO authenticated;
GRANT ALL ON TABLE public.drivers TO service_role;


--
-- TOC entry 7975 (class 0 OID 0)
-- Dependencies: 465

--

GRANT ALL ON TABLE public.kyc_document_types TO service_role;


--
-- TOC entry 7976 (class 0 OID 0)
-- Dependencies: 463

--

GRANT ALL ON TABLE public.kyc_documents TO authenticated;
GRANT ALL ON TABLE public.kyc_documents TO service_role;


--
-- TOC entry 7977 (class 0 OID 0)
-- Dependencies: 466

--

GRANT ALL ON TABLE public.kyc_liveness_sessions TO authenticated;
GRANT ALL ON TABLE public.kyc_liveness_sessions TO service_role;


--
-- TOC entry 7978 (class 0 OID 0)
-- Dependencies: 462

--

GRANT ALL ON TABLE public.kyc_submissions TO authenticated;
GRANT ALL ON TABLE public.kyc_submissions TO service_role;


--
-- TOC entry 7979 (class 0 OID 0)
-- Dependencies: 445

--

GRANT ALL ON TABLE public.notification_outbox TO authenticated;
GRANT ALL ON TABLE public.notification_outbox TO service_role;


--
-- TOC entry 7981 (class 0 OID 0)
-- Dependencies: 444

--

GRANT ALL ON SEQUENCE public.notification_outbox_id_seq TO anon;
GRANT ALL ON SEQUENCE public.notification_outbox_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.notification_outbox_id_seq TO service_role;


--
-- TOC entry 7982 (class 0 OID 0)
-- Dependencies: 419

--

GRANT ALL ON TABLE public.payment_intents TO service_role;
GRANT SELECT ON TABLE public.payment_intents TO authenticated;


--
-- TOC entry 7983 (class 0 OID 0)
-- Dependencies: 420

--

GRANT ALL ON TABLE public.payment_providers TO service_role;
GRANT SELECT ON TABLE public.payment_providers TO anon;
GRANT SELECT ON TABLE public.payment_providers TO authenticated;


--
-- TOC entry 7984 (class 0 OID 0)
-- Dependencies: 421

--

GRANT ALL ON TABLE public.payments TO service_role;
GRANT SELECT ON TABLE public.payments TO authenticated;


--
-- TOC entry 7986 (class 0 OID 0)
-- Dependencies: 422

--

GRANT ALL ON TABLE public.pricing_configs TO service_role;
GRANT SELECT ON TABLE public.pricing_configs TO authenticated;


--
-- TOC entry 7987 (class 0 OID 0)
-- Dependencies: 423

--

GRANT ALL ON TABLE public.profile_kyc TO authenticated;
GRANT ALL ON TABLE public.profile_kyc TO service_role;


--
-- TOC entry 7988 (class 0 OID 0)
-- Dependencies: 424

--

GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- TOC entry 7989 (class 0 OID 0)
-- Dependencies: 425

--

GRANT ALL ON TABLE public.provider_events TO service_role;
GRANT SELECT ON TABLE public.provider_events TO anon;
GRANT SELECT,INSERT ON TABLE public.provider_events TO authenticated;


--
-- TOC entry 7991 (class 0 OID 0)
-- Dependencies: 426

--

GRANT ALL ON SEQUENCE public.provider_events_id_seq TO anon;
GRANT ALL ON SEQUENCE public.provider_events_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.provider_events_id_seq TO service_role;


--
-- TOC entry 7992 (class 0 OID 0)
-- Dependencies: 441

--

GRANT ALL ON TABLE public.public_profiles TO authenticated;
GRANT ALL ON TABLE public.public_profiles TO service_role;


--
-- TOC entry 7993 (class 0 OID 0)
-- Dependencies: 451

--

GRANT ALL ON TABLE public.referral_campaigns TO service_role;


--
-- TOC entry 7994 (class 0 OID 0)
-- Dependencies: 452

--

GRANT ALL ON TABLE public.referral_codes TO authenticated;
GRANT ALL ON TABLE public.referral_codes TO service_role;


--
-- TOC entry 7995 (class 0 OID 0)
-- Dependencies: 473

--

GRANT ALL ON TABLE public.referral_invites TO service_role;


--
-- TOC entry 7996 (class 0 OID 0)
-- Dependencies: 453

--

GRANT ALL ON TABLE public.referral_redemptions TO service_role;


--
-- TOC entry 7997 (class 0 OID 0)
-- Dependencies: 472

--

GRANT ALL ON TABLE public.referral_settings TO service_role;


--
-- TOC entry 7998 (class 0 OID 0)
-- Dependencies: 458

--

GRANT ALL ON TABLE public.ride_chat_messages TO authenticated;
GRANT ALL ON TABLE public.ride_chat_messages TO service_role;


--
-- TOC entry 7999 (class 0 OID 0)
-- Dependencies: 459

--

GRANT ALL ON TABLE public.ride_chat_read_receipts TO authenticated;
GRANT ALL ON TABLE public.ride_chat_read_receipts TO service_role;


--
-- TOC entry 8000 (class 0 OID 0)
-- Dependencies: 471

--

GRANT ALL ON TABLE public.ride_chat_threads TO authenticated;
GRANT ALL ON TABLE public.ride_chat_threads TO service_role;


--
-- TOC entry 8001 (class 0 OID 0)
-- Dependencies: 460

--

GRANT ALL ON TABLE public.ride_chat_typing TO authenticated;
GRANT ALL ON TABLE public.ride_chat_typing TO service_role;


--
-- TOC entry 8002 (class 0 OID 0)
-- Dependencies: 470

--

GRANT ALL ON TABLE public.ride_completion_log TO service_role;


--
-- TOC entry 8003 (class 0 OID 0)
-- Dependencies: 427

--

GRANT ALL ON TABLE public.ride_events TO service_role;


--
-- TOC entry 8005 (class 0 OID 0)
-- Dependencies: 428

--

GRANT ALL ON SEQUENCE public.ride_events_id_seq TO anon;
GRANT ALL ON SEQUENCE public.ride_events_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.ride_events_id_seq TO service_role;


--
-- TOC entry 8006 (class 0 OID 0)
-- Dependencies: 429

--

GRANT ALL ON TABLE public.ride_incidents TO service_role;
GRANT SELECT ON TABLE public.ride_incidents TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE public.ride_incidents TO authenticated;


--
-- TOC entry 8007 (class 0 OID 0)
-- Dependencies: 478

--

GRANT ALL ON TABLE public.ride_intents TO authenticated;
GRANT ALL ON TABLE public.ride_intents TO service_role;


--
-- TOC entry 8008 (class 0 OID 0)
-- Dependencies: 464

--

GRANT ALL ON TABLE public.ride_products TO service_role;
GRANT SELECT ON TABLE public.ride_products TO authenticated;


--
-- TOC entry 8009 (class 0 OID 0)
-- Dependencies: 430

--

GRANT ALL ON TABLE public.ride_ratings TO service_role;
GRANT SELECT ON TABLE public.ride_ratings TO authenticated;


--
-- TOC entry 8010 (class 0 OID 0)
-- Dependencies: 431

--

GRANT ALL ON TABLE public.ride_receipts TO service_role;
GRANT SELECT ON TABLE public.ride_receipts TO anon;
GRANT SELECT ON TABLE public.ride_receipts TO authenticated;


--
-- TOC entry 8011 (class 0 OID 0)
-- Dependencies: 432

--

GRANT ALL ON TABLE public.ride_requests TO authenticated;
GRANT ALL ON TABLE public.ride_requests TO service_role;


--
-- TOC entry 8012 (class 0 OID 0)
-- Dependencies: 485

--

GRANT ALL ON TABLE public.ridecheck_events TO service_role;
GRANT SELECT ON TABLE public.ridecheck_events TO authenticated;


--
-- TOC entry 8013 (class 0 OID 0)
-- Dependencies: 486

--

GRANT ALL ON TABLE public.ridecheck_responses TO service_role;
GRANT SELECT ON TABLE public.ridecheck_responses TO authenticated;


--
-- TOC entry 8014 (class 0 OID 0)
-- Dependencies: 484

--

GRANT ALL ON TABLE public.ridecheck_state TO service_role;


--
-- TOC entry 8015 (class 0 OID 0)
-- Dependencies: 476

--

GRANT ALL ON TABLE public.scheduled_rides TO authenticated;
GRANT ALL ON TABLE public.scheduled_rides TO service_role;


--
-- TOC entry 8018 (class 0 OID 0)
-- Dependencies: 477

--

GRANT ALL ON TABLE public.service_areas TO authenticated;
GRANT ALL ON TABLE public.service_areas TO service_role;


--
-- TOC entry 8019 (class 0 OID 0)
-- Dependencies: 479

--

GRANT ALL ON TABLE public.sos_events TO authenticated;
GRANT ALL ON TABLE public.sos_events TO service_role;


--
-- TOC entry 8020 (class 0 OID 0)
-- Dependencies: 481

--

GRANT ALL ON TABLE public.support_articles TO authenticated;
GRANT ALL ON TABLE public.support_articles TO service_role;
GRANT SELECT ON TABLE public.support_articles TO anon;


--
-- TOC entry 8021 (class 0 OID 0)
-- Dependencies: 455

--

GRANT ALL ON TABLE public.support_categories TO service_role;


--
-- TOC entry 8022 (class 0 OID 0)
-- Dependencies: 457

--

GRANT ALL ON TABLE public.support_messages TO authenticated;
GRANT ALL ON TABLE public.support_messages TO service_role;


--
-- TOC entry 8023 (class 0 OID 0)
-- Dependencies: 480

--

GRANT ALL ON TABLE public.support_sections TO authenticated;
GRANT ALL ON TABLE public.support_sections TO service_role;
GRANT SELECT ON TABLE public.support_sections TO anon;


--
-- TOC entry 8024 (class 0 OID 0)
-- Dependencies: 456

--

GRANT ALL ON TABLE public.support_tickets TO authenticated;
GRANT ALL ON TABLE public.support_tickets TO service_role;


--
-- TOC entry 8025 (class 0 OID 0)
-- Dependencies: 467

--

GRANT ALL ON TABLE public.support_ticket_summaries TO anon;
GRANT ALL ON TABLE public.support_ticket_summaries TO authenticated;
GRANT ALL ON TABLE public.support_ticket_summaries TO service_role;


--
-- TOC entry 8026 (class 0 OID 0)
-- Dependencies: 433

--

GRANT ALL ON TABLE public.topup_packages TO service_role;
GRANT SELECT ON TABLE public.topup_packages TO anon;
GRANT SELECT ON TABLE public.topup_packages TO authenticated;


--
-- TOC entry 8027 (class 0 OID 0)
-- Dependencies: 461

--

GRANT ALL ON TABLE public.trip_share_tokens TO authenticated;
GRANT ALL ON TABLE public.trip_share_tokens TO service_role;


--
-- TOC entry 8028 (class 0 OID 0)
-- Dependencies: 483

--

GRANT ALL ON TABLE public.trusted_contact_events TO authenticated;
GRANT ALL ON TABLE public.trusted_contact_events TO service_role;


--
-- TOC entry 8029 (class 0 OID 0)
-- Dependencies: 487

--

GRANT ALL ON TABLE public.trusted_contact_outbox TO authenticated;
GRANT ALL ON TABLE public.trusted_contact_outbox TO service_role;


--
-- TOC entry 8030 (class 0 OID 0)
-- Dependencies: 454

--

GRANT ALL ON TABLE public.trusted_contacts TO authenticated;
GRANT ALL ON TABLE public.trusted_contacts TO service_role;


--
-- TOC entry 8031 (class 0 OID 0)
-- Dependencies: 469

--

GRANT ALL ON TABLE public.user_device_tokens TO authenticated;
GRANT ALL ON TABLE public.user_device_tokens TO service_role;


--
-- TOC entry 8032 (class 0 OID 0)
-- Dependencies: 434

--

GRANT ALL ON TABLE public.user_notifications TO authenticated;
GRANT ALL ON TABLE public.user_notifications TO service_role;


--
-- TOC entry 8033 (class 0 OID 0)
-- Dependencies: 482

--

GRANT ALL ON TABLE public.user_safety_settings TO authenticated;
GRANT ALL ON TABLE public.user_safety_settings TO service_role;


--
-- TOC entry 8034 (class 0 OID 0)
-- Dependencies: 435

--

GRANT ALL ON TABLE public.wallet_entries TO authenticated;
GRANT ALL ON TABLE public.wallet_entries TO service_role;


--
-- TOC entry 8036 (class 0 OID 0)
-- Dependencies: 436

--

GRANT ALL ON SEQUENCE public.wallet_entries_id_seq TO anon;
GRANT ALL ON SEQUENCE public.wallet_entries_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.wallet_entries_id_seq TO service_role;


--
-- TOC entry 8037 (class 0 OID 0)
-- Dependencies: 437

--

GRANT ALL ON TABLE public.wallet_holds TO authenticated;
GRANT ALL ON TABLE public.wallet_holds TO service_role;


--
-- TOC entry 8038 (class 0 OID 0)
-- Dependencies: 438

--

GRANT ALL ON TABLE public.wallet_withdraw_payout_methods TO authenticated;
GRANT ALL ON TABLE public.wallet_withdraw_payout_methods TO service_role;


--
-- TOC entry 8039 (class 0 OID 0)
-- Dependencies: 439

--

GRANT ALL ON TABLE public.wallet_withdraw_requests TO authenticated;
GRANT ALL ON TABLE public.wallet_withdraw_requests TO service_role;


--
-- TOC entry 8040 (class 0 OID 0)
-- Dependencies: 440

--

GRANT ALL ON TABLE public.wallet_withdrawal_policy TO authenticated;
GRANT ALL ON TABLE public.wallet_withdrawal_policy TO service_role;
GRANT SELECT ON TABLE public.wallet_withdrawal_policy TO anon;


--
-- TOC entry 8041 (class 0 OID 0)
-- Dependencies: 490

--

GRANT ALL ON TABLE public.whatsapp_booking_tokens TO authenticated;
GRANT ALL ON TABLE public.whatsapp_booking_tokens TO service_role;


--
-- TOC entry 8042 (class 0 OID 0)
-- Dependencies: 489

--

GRANT ALL ON TABLE public.whatsapp_messages TO authenticated;
GRANT ALL ON TABLE public.whatsapp_messages TO service_role;


--
-- TOC entry 8043 (class 0 OID 0)
-- Dependencies: 492

--

GRANT ALL ON TABLE public.whatsapp_thread_notes TO authenticated;
GRANT ALL ON TABLE public.whatsapp_thread_notes TO service_role;


--
-- TOC entry 8044 (class 0 OID 0)
-- Dependencies: 488

--

GRANT ALL ON TABLE public.whatsapp_threads TO authenticated;
GRANT ALL ON TABLE public.whatsapp_threads TO service_role;


--
-- TOC entry 8045 (class 0 OID 0)
-- Dependencies: 491

--

GRANT ALL ON TABLE public.whatsapp_threads_admin_v1 TO service_role;


--
-- TOC entry 8046 (class 0 OID 0)
-- Dependencies: 493

--

GRANT ALL ON TABLE public.whatsapp_threads_admin_v2 TO service_role;


--
-- TOC entry 8047 (class 0 OID 0)
-- Dependencies: 383

--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 3906 (class 826 OID 40559)

--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 3904 (class 826 OID 40560)

--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 3889 (class 826 OID 16557)
