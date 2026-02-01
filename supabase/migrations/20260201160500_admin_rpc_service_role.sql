-- Session 2
-- Allow trusted automation/seed scripts using service_role JWT to call admin RPCs.
--
-- Rationale: ingest scripts use SUPABASE_SERVICE_ROLE_KEY (server-side). For these
-- scripts, auth.uid() may not correspond to an admin user; we explicitly allow
-- service_role while keeping the public/anon path blocked.

create or replace function public.admin_create_service_area_bbox_v3(
  p_name text,
  p_governorate text,
  p_min_lat double precision,
  p_min_lng double precision,
  p_max_lat double precision,
  p_max_lng double precision,
  p_priority integer default 0,
  p_is_active boolean default true,
  p_pricing_config_id uuid default null,
  p_min_base_fare_iqd integer default null,
  p_surge_multiplier numeric default null,
  p_surge_reason text default null,
  p_cash_rounding_step_iqd integer default null
) returns uuid
language plpgsql
security definer
set search_path to 'public', 'extensions'
as $$
declare
  v_id uuid;
  v_role text;
begin
  v_role := coalesce(auth.jwt() ->> 'role', '');
  if v_role <> 'service_role' and not public.is_admin() then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  insert into public.service_areas (
    name, governorate, is_active, priority, pricing_config_id,
    min_base_fare_iqd, surge_multiplier, surge_reason,
    cash_rounding_step_iqd,
    geom
  )
  values (
    p_name,
    p_governorate,
    coalesce(p_is_active, true),
    coalesce(p_priority, 0),
    p_pricing_config_id,
    p_min_base_fare_iqd,
    greatest(coalesce(p_surge_multiplier, 1.0), 1.0),
    nullif(btrim(coalesce(p_surge_reason, '')), ''),
    greatest(coalesce(p_cash_rounding_step_iqd, 250), 1),
    extensions.ST_Multi(extensions.ST_MakeEnvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326))
  )
  on conflict (name, governorate) do update
    set is_active = excluded.is_active,
        priority = excluded.priority,
        pricing_config_id = excluded.pricing_config_id,
        min_base_fare_iqd = excluded.min_base_fare_iqd,
        surge_multiplier = excluded.surge_multiplier,
        surge_reason = excluded.surge_reason,
        cash_rounding_step_iqd = excluded.cash_rounding_step_iqd,
        geom = excluded.geom,
        updated_at = now()
  returning id into v_id;

  return v_id;
end;
$$;

create or replace function public.admin_upsert_service_area_geojson_v1(
  p_name text,
  p_governorate text,
  p_geojson jsonb,
  p_priority integer default 0,
  p_is_active boolean default true,
  p_pricing_config_id uuid default null,
  p_min_base_fare_iqd integer default null,
  p_surge_multiplier numeric default null,
  p_surge_reason text default null,
  p_cash_rounding_step_iqd integer default null
) returns uuid
language plpgsql
security definer
set search_path to 'public', 'extensions'
as $$
declare
  v_id uuid;
  v_role text;
  v_geom extensions.geometry(MultiPolygon, 4326);
begin
  v_role := coalesce(auth.jwt() ->> 'role', '');
  if v_role <> 'service_role' and not public.is_admin() then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  if p_geojson is null then
    raise exception 'geojson required';
  end if;

  v_geom := extensions.ST_Multi(
    extensions.ST_CollectionExtract(
      extensions.ST_MakeValid(
        extensions.ST_SetSRID(extensions.ST_GeomFromGeoJSON(p_geojson::text), 4326)
      ),
      3
    )
  );

  if v_geom is null or extensions.ST_IsEmpty(v_geom) then
    raise exception 'invalid or empty geometry';
  end if;

  insert into public.service_areas (
    name, governorate, is_active, priority, pricing_config_id,
    min_base_fare_iqd, surge_multiplier, surge_reason,
    cash_rounding_step_iqd,
    geom
  )
  values (
    p_name,
    p_governorate,
    coalesce(p_is_active, true),
    coalesce(p_priority, 0),
    p_pricing_config_id,
    p_min_base_fare_iqd,
    greatest(coalesce(p_surge_multiplier, 1.0), 1.0),
    nullif(btrim(coalesce(p_surge_reason, '')), ''),
    greatest(coalesce(p_cash_rounding_step_iqd, 250), 1),
    v_geom
  )
  on conflict (name, governorate) do update
    set is_active = excluded.is_active,
        priority = excluded.priority,
        pricing_config_id = excluded.pricing_config_id,
        min_base_fare_iqd = excluded.min_base_fare_iqd,
        surge_multiplier = excluded.surge_multiplier,
        surge_reason = excluded.surge_reason,
        cash_rounding_step_iqd = excluded.cash_rounding_step_iqd,
        geom = excluded.geom,
        updated_at = now()
  returning id into v_id;

  return v_id;
end;
$$;

