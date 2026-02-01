-- Session 3
-- Pricing config: enforce a single default + admin RPCs to manage versions safely.
--
-- Why:
-- - We need a reproducible, versioned tariff system (baseline today, ML later).
-- - Admins need a safe workflow to roll forward prices per governorate/zone without
--   ad-hoc SQL edits.

-- -----------------------------------------------------------------------------
-- 1) Normalize: ensure <= 1 row has is_default=true
-- -----------------------------------------------------------------------------

do $$
declare
  v_keep uuid;
begin
  select id into v_keep
  from public.pricing_configs
  where is_default = true
  order by
    active desc,
    effective_from desc nulls last,
    updated_at desc nulls last,
    created_at desc nulls last
  limit 1;

  if v_keep is not null then
    update public.pricing_configs
      set is_default = (id = v_keep)
    where is_default = true;
  end if;
end $$;

-- At most one default overall. (We keep this simple; admin RPCs preserve invariants.)
create unique index if not exists uniq_pricing_configs_default_true
  on public.pricing_configs (is_default)
  where is_default;

-- -----------------------------------------------------------------------------
-- 2) Admin RPCs
-- -----------------------------------------------------------------------------

create or replace function public.admin_set_default_pricing_config_v1(
  p_id uuid
) returns void
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_role text;
begin
  v_role := coalesce(auth.jwt() ->> 'role', '');
  if v_role <> 'service_role' and not public.is_admin() then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  -- Clear any existing default then set exactly one.
  update public.pricing_configs set is_default = false where is_default = true;
  update public.pricing_configs set is_default = true where id = p_id;

  if not found then
    raise exception 'pricing_config not found';
  end if;
end;
$$;

create or replace function public.admin_clone_pricing_config_v1(
  p_source_id uuid,
  p_name text,
  p_effective_from timestamptz default now(),
  p_active boolean default true,
  p_set_default boolean default false
) returns uuid
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  v_role text;
  v_new_id uuid;
  v_src record;
begin
  v_role := coalesce(auth.jwt() ->> 'role', '');
  if v_role <> 'service_role' and not public.is_admin() then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  select * into v_src
  from public.pricing_configs
  where id = p_source_id;

  if v_src.id is null then
    raise exception 'source pricing_config not found';
  end if;

  insert into public.pricing_configs (
    name,
    version,
    effective_from,
    effective_to,
    is_default,
    active,
    currency,
    base_fare_iqd,
    per_km_iqd,
    per_min_iqd,
    minimum_fare_iqd,
    max_surge_multiplier
  ) values (
    nullif(btrim(coalesce(p_name, '')), ''),
    coalesce(v_src.version, 1) + 1,
    coalesce(p_effective_from, now()),
    null,
    coalesce(p_set_default, false),
    coalesce(p_active, true),
    coalesce(v_src.currency, 'IQD'),
    v_src.base_fare_iqd,
    v_src.per_km_iqd,
    v_src.per_min_iqd,
    v_src.minimum_fare_iqd,
    v_src.max_surge_multiplier
  ) returning id into v_new_id;

  if coalesce(p_set_default, false) then
    perform public.admin_set_default_pricing_config_v1(v_new_id);
  end if;

  return v_new_id;
end;
$$;

revoke all on function public.admin_set_default_pricing_config_v1(uuid) from public;
grant all on function public.admin_set_default_pricing_config_v1(uuid) to service_role;
grant all on function public.admin_set_default_pricing_config_v1(uuid) to authenticated;

revoke all on function public.admin_clone_pricing_config_v1(uuid, text, timestamptz, boolean, boolean) from public;
grant all on function public.admin_clone_pricing_config_v1(uuid, text, timestamptz, boolean, boolean) to service_role;
grant all on function public.admin_clone_pricing_config_v1(uuid, text, timestamptz, boolean, boolean) to authenticated;
