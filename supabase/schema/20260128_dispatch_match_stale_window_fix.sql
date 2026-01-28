-- RideIQ hotfix: make driver location freshness window sane for matching
-- Date: 2026-01-28
--
-- Problem:
--   dispatch_match_ride defaulted to p_stale_after_seconds=30. In practice, many mobile clients
--   report location on a ~30–60s cadence when idle/battery-optimized, causing matching to return
--   no candidates even when nearby drivers exist.
--
-- Fix:
--   - Set the default p_stale_after_seconds to 120 seconds.
--   - Add a guardrail that enforces a minimum 30 seconds.

create or replace function public.dispatch_match_ride(
  p_request_id uuid,
  p_rider_id uuid,
  p_radius_m numeric default 5000,
  p_limit_n integer default 20,
  p_match_ttl_seconds integer default 120,
  p_stale_after_seconds integer default 120
)
returns table(
  id uuid,
  status public.ride_request_status,
  assigned_driver_id uuid,
  match_deadline timestamp with time zone,
  match_attempts integer,
  matched_at timestamp with time zone
)
language plpgsql
security definer
set search_path to 'pg_catalog, extensions'
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
  v_stale_after int;
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

  -- Handle expired match: release driver back to available
  if rr.status = 'matched' and rr.match_deadline is not null and rr.match_deadline <= now() then
    perform public.transition_driver(rr.assigned_driver_id, 'available'::public.driver_status, null, 'match_expired');

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

  select coalesce(w.balance_iqd, 0), coalesce(w.held_iqd, 0)
    into v_balance, v_held
  from public.wallet_accounts w
  where w.user_id = rr.rider_id;

  v_available := coalesce(v_balance, 0) - coalesce(v_held, 0);

  -- Quote: prefer persisted quote_amount_iqd but fall back to a fresh estimate.
  v_quote := coalesce(rr.quote_amount_iqd, 0)::bigint;
  if v_quote <= 0 then
    v_quote := coalesce(public.estimate_ride_quote_iqd_v2(rr.pickup_loc, rr.dropoff_loc, rr.product_code), 0)::bigint;
    if v_quote <= 0 then
      raise exception 'invalid_quote';
    end if;

    -- Persist the computed quote to keep DB state consistent.
    update public.ride_requests
      set quote_amount_iqd = v_quote::bigint,
          updated_at = now()
    where id = rr.id;
  end if;

  if v_available < v_quote then
    raise exception 'insufficient_wallet_balance';
  end if;

  -- Guardrail: a 30s location freshness window is commonly too strict for mobile clients.
  -- Keep a sane minimum to prevent accidental "no candidates" when drivers update on a 30–60s cadence.
  v_stale_after := greatest(30, coalesce(p_stale_after_seconds, 120));

  for i in 1..3 loop
    with pickup as (
      select rr.pickup_loc as pickup
    ), candidates as (
      select d.id as driver_id
      from public.drivers d
      cross join pickup
      join public.driver_locations dl
        on dl.driver_id = d.id
       and dl.updated_at >= now() - make_interval(secs => v_stale_after)
      where d.status = 'available'
        and not (d.id = any(tried))
        and extensions.st_dwithin(dl.loc, pickup.pickup, p_radius_m)
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

    -- Reserve the driver
    begin
      perform public.transition_driver(candidate, 'reserved'::public.driver_status, null, 'matching');
    exception when others then
      tried := array_append(tried, candidate);
      continue;
    end;

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
        perform public.transition_driver(candidate, 'available'::public.driver_status, null, 'match_conflict');
      when others then
        perform public.transition_driver(candidate, 'available'::public.driver_status, null, 'match_error');
        raise;
    end;

    tried := array_append(tried, candidate);

    perform public.transition_driver(candidate, 'available'::public.driver_status, null, 'match_failed');
  end loop;

  return query select rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
end;
$$;

comment on function public.dispatch_match_ride(
  p_request_id uuid,
  p_rider_id uuid,
  p_radius_m numeric,
  p_limit_n integer,
  p_match_ttl_seconds integer,
  p_stale_after_seconds integer
) is 'Matches a ride request to an available driver. Uses transition_driver for state changes.';
