-- Session 2
-- Enhance fare quote audit table for tariff/version reproducibility

alter table public.fare_quotes
  add column if not exists pricing_config_id uuid references public.pricing_configs(id),
  add column if not exists pricing_snapshot jsonb not null default '{}'::jsonb,
  add column if not exists cash_rounding_step_iqd integer,
  add column if not exists service_area_name text,
  add column if not exists service_area_governorate text,
  add column if not exists route_provider text not null default 'osrm',
  add column if not exists route_profile text not null default 'driving',
  add column if not exists route_fetched_at timestamptz not null default now();

create index if not exists fare_quotes_pricing_config_idx
  on public.fare_quotes (pricing_config_id, created_at desc);

create index if not exists fare_quotes_route_provider_idx
  on public.fare_quotes (route_provider, created_at desc);

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'fare_quotes_cash_rounding_step_check'
  ) then
    alter table public.fare_quotes
      add constraint fare_quotes_cash_rounding_step_check
      check (cash_rounding_step_iqd is null or cash_rounding_step_iqd >= 1);
  end if;
end $$;
