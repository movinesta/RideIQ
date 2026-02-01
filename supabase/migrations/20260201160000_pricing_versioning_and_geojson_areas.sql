-- Session 2
-- Pricing versioning + polygon (GeoJSON) service-area upsert
--
-- This migration is intentionally additive (no breaking schema changes).

-- -----------------------------------------------------------------------------
-- 1) pricing_configs: lightweight versioning metadata
-- -----------------------------------------------------------------------------

alter table public.pricing_configs
  add column if not exists name text,
  add column if not exists version integer not null default 1,
  add column if not exists effective_from timestamptz not null default now(),
  add column if not exists effective_to timestamptz,
  add column if not exists is_default boolean not null default false;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'pricing_configs_version_check'
  ) then
    alter table public.pricing_configs
      add constraint pricing_configs_version_check
      check (version >= 1);
  end if;

  if not exists (
    select 1 from pg_constraint where conname = 'pricing_configs_effective_window_check'
  ) then
    alter table public.pricing_configs
      add constraint pricing_configs_effective_window_check
      check (effective_to is null or effective_to > effective_from);
  end if;
end $$;

create index if not exists idx_pricing_configs_default_active
  on public.pricing_configs (is_default, active, effective_from desc);

-- -----------------------------------------------------------------------------
-- 2) service_areas: admin RPCs for bbox + GeoJSON polygon upsert
-- -----------------------------------------------------------------------------

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
begin
  if not public.is_admin() then
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
  v_geom extensions.geometry(MultiPolygon, 4326);
begin
  if not public.is_admin() then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  if p_geojson is null then
    raise exception 'geojson required';
  end if;

  -- Convert GeoJSON -> geometry, enforce SRID 4326, make valid, and normalize to MultiPolygon.
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

-- Permissions: keep admin RPCs off PUBLIC. Admin check still applies for authenticated.
revoke all on function public.admin_create_service_area_bbox_v3(
  text, text, double precision, double precision, double precision, double precision, integer, boolean, uuid, integer, numeric, text, integer
) from public;
grant all on function public.admin_create_service_area_bbox_v3(
  text, text, double precision, double precision, double precision, double precision, integer, boolean, uuid, integer, numeric, text, integer
) to service_role;
grant all on function public.admin_create_service_area_bbox_v3(
  text, text, double precision, double precision, double precision, double precision, integer, boolean, uuid, integer, numeric, text, integer
) to authenticated;

revoke all on function public.admin_upsert_service_area_geojson_v1(
  text, text, jsonb, integer, boolean, uuid, integer, numeric, text, integer
) from public;
grant all on function public.admin_upsert_service_area_geojson_v1(
  text, text, jsonb, integer, boolean, uuid, integer, numeric, text, integer
) to service_role;
grant all on function public.admin_upsert_service_area_geojson_v1(
  text, text, jsonb, integer, boolean, uuid, integer, numeric, text, integer
) to authenticated;
