-- Add assigned status for drivers and align dispatch flows to treat it like reserved.

ALTER TYPE public.driver_status
  ADD VALUE IF NOT EXISTS 'assigned';

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
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, extensions'
AS $$
#variable_conflict use_column
declare
  rr record;
  r record;
  v_hold_id uuid;
  v_quote bigint;
begin
  select * into rr
  from public.ride_requests req
  where req.id = p_request_id
  for update;

  if not found then
    raise exception 'ride_request_not_found';
  end if;

  if rr.assigned_driver_id is distinct from p_driver_id then
    raise exception 'forbidden';
  end if;

  if rr.status <> 'matched' then
    raise exception 'request_not_matched';
  end if;

  -- ensure driver is reserved or assigned
  if not exists (
    select 1 from public.drivers d
    where d.id = p_driver_id and d.status in ('reserved', 'assigned')
  ) then
    raise exception 'driver_not_reserved';
  end if;

  v_quote := coalesce(rr.quote_amount_iqd, 0)::bigint;
  if v_quote <= 0 then
    v_quote := public.estimate_ride_quote_iqd_v2(rr.pickup_loc, rr.dropoff_loc, rr.product_code)::bigint;
    if v_quote <= 0 then
      raise exception 'invalid_quote';
    end if;
  end if;

  -- Mark accepted
  update public.ride_requests
    set status = 'accepted',
        quote_amount_iqd = v_quote::int
  where id = rr.id and status = 'matched';

  -- Create ride (idempotent)
  insert into public.rides (request_id, rider_id, driver_id, status, version, started_at, completed_at, fare_amount_iqd, currency, product_code)
  values (rr.id, rr.rider_id, p_driver_id, 'assigned', 0, null, null, v_quote::int, rr.currency, rr.product_code)
  on conflict (request_id) do update
    set driver_id = excluded.driver_id,
        fare_amount_iqd = excluded.fare_amount_iqd,
        currency = excluded.currency,
        product_code = excluded.product_code
  returning * into r;

  -- Reserve fare amount from rider wallet (hold)
  v_hold_id := public.wallet_hold_upsert_for_ride(r.rider_id, r.id, r.fare_amount_iqd::bigint);

  -- Driver is now on-trip
  update public.drivers
    set status = 'on_trip'
  where id = p_driver_id;

  return query
    select r.id, r.status, 'accepted'::public.ride_request_status, v_hold_id, r.rider_id, r.driver_id, r.started_at, r.completed_at, r.fare_amount_iqd, r.currency;
end;
$$;

CREATE OR REPLACE FUNCTION public.dispatch_match_ride(
  p_request_id uuid,
  p_rider_id uuid,
  p_radius_m numeric default 5000,
  p_limit_n integer default 20,
  p_match_ttl_seconds integer default 120,
  p_stale_after_seconds integer default 30
) returns table(
  id uuid,
  status public.ride_request_status,
  assigned_driver_id uuid,
  match_deadline timestamp with time zone,
  match_attempts integer,
  matched_at timestamp with time zone
)
language plpgsql
security definer
set search_path = 'pg_catalog, extensions'
as $$
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

    update public.drivers
      set status = 'assigned'
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
    exception when others then
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

CREATE OR REPLACE FUNCTION public.ride_requests_release_driver_on_unmatch() RETURNS trigger
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
