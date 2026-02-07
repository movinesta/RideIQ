-- Add OpenRouteService (ORS) provider support across maps schema and admin validation.

-- Expand provider checks to allow ORS.
ALTER TABLE IF EXISTS public.maps_providers
  DROP CONSTRAINT IF EXISTS maps_providers_provider_code_chk;
ALTER TABLE IF EXISTS public.maps_providers
  ADD CONSTRAINT maps_providers_provider_code_chk
  CHECK (provider_code IN ('google','mapbox','here','thunderforest','ors'));

ALTER TABLE IF EXISTS public.maps_requests_log
  DROP CONSTRAINT IF EXISTS maps_requests_log_provider_chk;
ALTER TABLE IF EXISTS public.maps_requests_log
  ADD CONSTRAINT maps_requests_log_provider_chk
  CHECK (provider_code IN ('google','mapbox','here','thunderforest','ors'));

ALTER TABLE IF EXISTS public.geo_cache
  DROP CONSTRAINT IF EXISTS geo_cache_provider_chk;
ALTER TABLE IF EXISTS public.geo_cache
  ADD CONSTRAINT geo_cache_provider_chk
  CHECK (provider_code IN ('google','mapbox','here','thunderforest','ors'));

ALTER TABLE IF EXISTS public.maps_provider_health
  DROP CONSTRAINT IF EXISTS mph_provider_chk;
ALTER TABLE IF EXISTS public.maps_provider_health
  ADD CONSTRAINT mph_provider_chk
  CHECK (provider_code IN ('google','mapbox','here','thunderforest','ors'));

-- Seed ORS provider (disabled by default; priority between HERE and Thunderforest).
INSERT INTO public.maps_providers (provider_code, priority, enabled, language, region, monthly_soft_cap_units, monthly_hard_cap_units, note)
VALUES
  ('ors', 75, false, 'ar', 'IQ', 30000, 35000, 'OpenRouteService (routing, matrix, geocoding)')
ON CONFLICT (provider_code) DO UPDATE
SET priority = EXCLUDED.priority,
    enabled = EXCLUDED.enabled,
    language = EXCLUDED.language,
    region = EXCLUDED.region,
    monthly_soft_cap_units = EXCLUDED.monthly_soft_cap_units,
    monthly_hard_cap_units = EXCLUDED.monthly_hard_cap_units,
    note = EXCLUDED.note;

-- Seed ORS capability defaults (render disabled).
INSERT INTO public.maps_provider_capabilities (provider_code, capability, enabled, unit_label, note)
VALUES
  ('ors', 'render', false, 'n/a', 'Not supported (server-only)')
 ,('ors', 'directions', true, 'request', 'Server-side request count')
 ,('ors', 'geocode', true, 'request', 'Server-side request count (forward + reverse)')
 ,('ors', 'distance_matrix', true, 'element', 'Origin-destination element count')
ON CONFLICT (provider_code, capability)
DO UPDATE SET
  enabled = EXCLUDED.enabled,
  unit_label = EXCLUDED.unit_label,
  note = EXCLUDED.note,
  updated_at = now();

-- Admin: upsert provider config (v1).
CREATE OR REPLACE FUNCTION public.admin_maps_provider_set_v1(
  p_provider_code text,
  p_priority integer,
  p_enabled boolean,
  p_language text,
  p_region text,
  p_monthly_soft_cap_units integer,
  p_monthly_hard_cap_units integer,
  p_note text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_code text := lower(btrim(p_provider_code));
  v_priority integer := COALESCE(p_priority, 0);
  v_enabled boolean := COALESCE(p_enabled, true);
  v_lang text := COALESCE(nullif(btrim(p_language), ''), 'ar');
  v_region text := COALESCE(nullif(btrim(p_region), ''), 'IQ');
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;
  IF NOT (SELECT public.is_admin()) THEN
    RAISE EXCEPTION 'not_authorized';
  END IF;

  IF v_code NOT IN ('google','mapbox','here','thunderforest','ors') THEN
    RAISE EXCEPTION 'invalid_provider_code';
  END IF;

  IF v_priority < 0 OR v_priority > 1000 THEN
    RAISE EXCEPTION 'invalid_priority';
  END IF;

  IF p_monthly_soft_cap_units IS NOT NULL AND p_monthly_soft_cap_units < 0 THEN
    RAISE EXCEPTION 'invalid_soft_cap';
  END IF;
  IF p_monthly_hard_cap_units IS NOT NULL AND p_monthly_hard_cap_units < 0 THEN
    RAISE EXCEPTION 'invalid_hard_cap';
  END IF;

  INSERT INTO public.maps_providers(provider_code, priority, enabled, language, region, monthly_soft_cap_units, monthly_hard_cap_units, note)
  VALUES (v_code, v_priority, v_enabled, v_lang, v_region, p_monthly_soft_cap_units, p_monthly_hard_cap_units, p_note)
  ON CONFLICT (provider_code)
  DO UPDATE SET
    priority = EXCLUDED.priority,
    enabled = EXCLUDED.enabled,
    language = EXCLUDED.language,
    region = EXCLUDED.region,
    monthly_soft_cap_units = EXCLUDED.monthly_soft_cap_units,
    monthly_hard_cap_units = EXCLUDED.monthly_hard_cap_units,
    note = EXCLUDED.note,
    updated_at = now();
END;
$$;

-- Admin: upsert provider config (v2 includes cache controls).
CREATE OR REPLACE FUNCTION public.admin_maps_provider_set_v2(
  p_provider_code text,
  p_priority integer,
  p_enabled boolean,
  p_language text,
  p_region text,
  p_monthly_soft_cap_units integer,
  p_monthly_hard_cap_units integer,
  p_cache_enabled boolean DEFAULT false,
  p_cache_ttl_seconds integer DEFAULT NULL,
  p_note text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_code text := lower(btrim(p_provider_code));
  v_priority integer := COALESCE(p_priority, 0);
  v_enabled boolean := COALESCE(p_enabled, true);
  v_lang text := COALESCE(nullif(btrim(p_language), ''), 'ar');
  v_region text := COALESCE(nullif(btrim(p_region), ''), 'IQ');
  v_cache_enabled boolean := COALESCE(p_cache_enabled, false);
  v_cache_ttl integer := p_cache_ttl_seconds;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;
  IF NOT (SELECT public.is_admin()) THEN
    RAISE EXCEPTION 'not_authorized';
  END IF;

  IF v_code NOT IN ('google','mapbox','here','thunderforest','ors') THEN
    RAISE EXCEPTION 'invalid_provider_code';
  END IF;

  IF v_priority < 0 OR v_priority > 1000 THEN
    RAISE EXCEPTION 'invalid_priority';
  END IF;

  IF p_monthly_soft_cap_units IS NOT NULL AND p_monthly_soft_cap_units < 0 THEN
    RAISE EXCEPTION 'invalid_soft_cap';
  END IF;
  IF p_monthly_hard_cap_units IS NOT NULL AND p_monthly_hard_cap_units < 0 THEN
    RAISE EXCEPTION 'invalid_hard_cap';
  END IF;

  IF v_cache_ttl IS NOT NULL AND v_cache_ttl <= 0 THEN
    -- Treat non-positive TTL as "disable".
    v_cache_ttl := NULL;
    v_cache_enabled := false;
  END IF;

  INSERT INTO public.maps_providers(
    provider_code,
    priority,
    enabled,
    language,
    region,
    monthly_soft_cap_units,
    monthly_hard_cap_units,
    cache_enabled,
    cache_ttl_seconds,
    note
  )
  VALUES (
    v_code,
    v_priority,
    v_enabled,
    v_lang,
    v_region,
    p_monthly_soft_cap_units,
    p_monthly_hard_cap_units,
    v_cache_enabled,
    v_cache_ttl,
    p_note
  )
  ON CONFLICT (provider_code)
  DO UPDATE SET
    priority = EXCLUDED.priority,
    enabled = EXCLUDED.enabled,
    language = EXCLUDED.language,
    region = EXCLUDED.region,
    monthly_soft_cap_units = EXCLUDED.monthly_soft_cap_units,
    monthly_hard_cap_units = EXCLUDED.monthly_hard_cap_units,
    cache_enabled = EXCLUDED.cache_enabled,
    cache_ttl_seconds = EXCLUDED.cache_ttl_seconds,
    note = EXCLUDED.note,
    updated_at = now();
END;
$$;

-- Admin: upsert capability setting.
CREATE OR REPLACE FUNCTION public.admin_maps_provider_capability_set_v1(
  p_provider_code text,
  p_capability text,
  p_enabled boolean,
  p_unit_label text,
  p_note text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_provider text := lower(btrim(p_provider_code));
  v_cap text := lower(btrim(p_capability));
  v_enabled boolean := COALESCE(p_enabled, true);
  v_label text := COALESCE(nullif(btrim(p_unit_label), ''), 'units');
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;
  IF NOT (SELECT public.is_admin()) THEN
    RAISE EXCEPTION 'not_authorized';
  END IF;

  IF v_provider NOT IN ('google','mapbox','here','thunderforest','ors') THEN
    RAISE EXCEPTION 'invalid_provider_code';
  END IF;
  IF v_cap NOT IN ('render','directions','geocode','distance_matrix') THEN
    RAISE EXCEPTION 'invalid_capability';
  END IF;

  INSERT INTO public.maps_provider_capabilities(provider_code, capability, enabled, unit_label, note)
  VALUES (v_provider, v_cap, v_enabled, v_label, p_note)
  ON CONFLICT (provider_code, capability)
  DO UPDATE SET
    enabled = EXCLUDED.enabled,
    unit_label = EXCLUDED.unit_label,
    note = EXCLUDED.note,
    updated_at = now();
END;
$$;

-- Cache helper: allow ORS provider code.
CREATE OR REPLACE FUNCTION public.geo_cache_put_v1(
  p_cache_key text,
  p_provider_code text,
  p_capability text,
  p_response jsonb,
  p_ttl_seconds int
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $$
DECLARE
  v_provider text := lower(btrim(p_provider_code));
  v_cap text := lower(btrim(p_capability));
  v_ttl int := greatest(1, least(coalesce(p_ttl_seconds, 300), 2592000)); -- max 30 days
  v_expires timestamptz := now() + make_interval(secs => v_ttl);
BEGIN
  IF v_provider NOT IN ('google','mapbox','here','thunderforest','ors') THEN
    RAISE EXCEPTION 'invalid_provider_code';
  END IF;
  IF v_cap NOT IN ('directions','geocode','distance_matrix') THEN
    RAISE EXCEPTION 'invalid_capability';
  END IF;

  INSERT INTO public.geo_cache(cache_key, provider_code, capability, response_json, expires_at)
  VALUES (p_cache_key, v_provider, v_cap, p_response, v_expires)
  ON CONFLICT (cache_key)
  DO UPDATE SET
    provider_code = EXCLUDED.provider_code,
    capability = EXCLUDED.capability,
    response_json = EXCLUDED.response_json,
    expires_at = EXCLUDED.expires_at,
    updated_at = now();
END;
$$;

-- Provider health: allow ORS provider.
CREATE OR REPLACE FUNCTION public.maps_provider_health_on_failure_v1(
  p_provider_code text,
  p_capability text,
  p_http_status int DEFAULT NULL,
  p_error_code text DEFAULT NULL,
  p_base_cooldown_seconds int DEFAULT 60
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $$
DECLARE
  v_provider text := lower(btrim(p_provider_code));
  v_cap text := lower(btrim(p_capability));
  v_now timestamptz := now();
  v_base int := greatest(0, least(coalesce(p_base_cooldown_seconds, 60), 86400));
  v_new_failures int;
  v_effective int;
BEGIN
  IF v_provider NOT IN ('google','mapbox','here','thunderforest','ors') THEN
    RAISE EXCEPTION 'invalid_provider_code';
  END IF;
  IF v_cap NOT IN ('render','directions','geocode','distance_matrix') THEN
    RAISE EXCEPTION 'invalid_capability';
  END IF;

  INSERT INTO public.maps_provider_health(provider_code, capability)
  VALUES (v_provider, v_cap)
  ON CONFLICT (provider_code, capability)
  DO NOTHING;

  -- Increment failures.
  UPDATE public.maps_provider_health
  SET
    consecutive_failures = consecutive_failures + 1,
    last_http_status = p_http_status,
    last_error_code = left(coalesce(p_error_code, ''), 120),
    last_failure_at = v_now,
    updated_at = v_now
  WHERE provider_code = v_provider AND capability = v_cap
  RETURNING consecutive_failures INTO v_new_failures;

  -- Exponential backoff capped at 24h.
  v_effective := LEAST(86400, v_base * power(2, GREATEST(0, v_new_failures - 1))::int);

  UPDATE public.maps_provider_health
  SET disabled_until = GREATEST(coalesce(disabled_until, v_now), v_now + make_interval(secs => v_effective)),
      updated_at = v_now
  WHERE provider_code = v_provider AND capability = v_cap;
END;
$$;

CREATE OR REPLACE FUNCTION public.maps_provider_health_on_success_v1(
  p_provider_code text,
  p_capability text
) RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $$
DECLARE
  v_provider text := lower(btrim(p_provider_code));
  v_cap text := lower(btrim(p_capability));
BEGIN
  IF v_provider NOT IN ('google','mapbox','here','thunderforest','ors') THEN
    RAISE EXCEPTION 'invalid_provider_code';
  END IF;
  IF v_cap NOT IN ('render','directions','geocode','distance_matrix') THEN
    RAISE EXCEPTION 'invalid_capability';
  END IF;

  INSERT INTO public.maps_provider_health(provider_code, capability)
  VALUES (v_provider, v_cap)
  ON CONFLICT (provider_code, capability)
  DO UPDATE SET
    consecutive_failures = 0,
    disabled_until = NULL,
    updated_at = now();
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_maps_provider_health_reset_v1(
  p_provider_code text,
  p_capability text
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public'
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_provider text := lower(btrim(p_provider_code));
  v_cap text := lower(btrim(p_capability));
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;
  IF NOT (SELECT public.is_admin()) THEN
    RAISE EXCEPTION 'not_authorized';
  END IF;

  IF v_provider NOT IN ('google','mapbox','here','thunderforest','ors') THEN
    RAISE EXCEPTION 'invalid_provider_code';
  END IF;
  IF v_cap NOT IN ('render','directions','geocode','distance_matrix') THEN
    RAISE EXCEPTION 'invalid_capability';
  END IF;

  INSERT INTO public.maps_provider_health(provider_code, capability)
  VALUES (v_provider, v_cap)
  ON CONFLICT (provider_code, capability)
  DO UPDATE SET
    consecutive_failures = 0,
    disabled_until = NULL,
    updated_at = now();
END;
$$;
