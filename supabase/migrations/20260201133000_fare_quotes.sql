-- Add fare quote audit table (route-based quotes, ML telemetry)
-- This is intentionally additive and does not change existing ride request flows.

create table if not exists public.fare_quotes (
  id uuid primary key default gen_random_uuid(),
  rider_id uuid not null references auth.users(id) on delete cascade,
  service_area_id uuid references public.service_areas(id),
  product_code text not null default 'standard',
  pickup_lat double precision not null,
  pickup_lng double precision not null,
  dropoff_lat double precision not null,
  dropoff_lng double precision not null,
  route_distance_m integer,
  route_duration_s integer,
  weather jsonb not null default '{}'::jsonb,
  context jsonb not null default '{}'::jsonb,
  breakdown jsonb not null,
  total_iqd integer not null,
  currency text not null default 'IQD',
  engine text not null default 'fare-quote-v1',
  created_at timestamptz not null default now()
);

create index if not exists fare_quotes_rider_created_idx
  on public.fare_quotes (rider_id, created_at desc);

create index if not exists fare_quotes_service_area_created_idx
  on public.fare_quotes (service_area_id, created_at desc);

alter table public.fare_quotes enable row level security;

do $$
begin
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='fare_quotes' and policyname='fare_quotes_select_own'
  ) then
    create policy fare_quotes_select_own
      on public.fare_quotes
      for select
      to authenticated
      using (rider_id = auth.uid() or public.is_admin());
  end if;

  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='fare_quotes' and policyname='fare_quotes_insert_own'
  ) then
    create policy fare_quotes_insert_own
      on public.fare_quotes
      for insert
      to authenticated
      with check (rider_id = auth.uid());
  end if;
end $$;

grant select, insert on table public.fare_quotes to authenticated;
grant select, insert, update, delete on table public.fare_quotes to service_role;
