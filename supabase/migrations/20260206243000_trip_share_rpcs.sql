-- Trip share: move token creation + public token view into DB RPCs.
--
-- Goals:
-- 1) Eliminate service_role usage from token-based public share view.
-- 2) Eliminate direct Edge CRUD for share token creation.
-- 3) Centralize token validation + data shaping in a SECURITY DEFINER RPC.
--
-- NOTE: We intentionally store only token_hash (SHA-256 hex) for new tokens.
-- The legacy `token` column is still supported for backwards compatibility.

-- ---------------------------------------------------------------------------
-- 1) Authenticated: create a share token for a ride the caller participates in
-- ---------------------------------------------------------------------------
create or replace function public.trip_share_create_user_v1(
  p_ride_id uuid,
  p_ttl_minutes integer default 120
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions, pg_catalog
as $$
declare
  v_user_id uuid := auth.uid();
  v_ttl integer;
  v_expires_at timestamptz;
  v_token text;
  v_token_hash text;
  v_is_participant boolean;
begin
  if v_user_id is null then
    return jsonb_build_object('ok', false, 'error', 'unauthorized');
  end if;

  -- Validate ride membership (rider/driver). We return NOT_FOUND (not FORBIDDEN)
  -- to avoid leaking ride existence.
  select exists(
    select 1
    from public.rides r
    where r.id = p_ride_id
      and (r.rider_id = v_user_id or r.driver_id = v_user_id)
  ) into v_is_participant;

  if not v_is_participant then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;

  v_ttl := greatest(5, least(1440, coalesce(p_ttl_minutes, 120)));
  v_expires_at := now() + (v_ttl * interval '1 minute');

  -- Revoke any still-active tokens created by this user for this ride.
  update public.trip_share_tokens
    set revoked_at = now()
  where ride_id = p_ride_id
    and created_by = v_user_id
    and revoked_at is null
    and expires_at > now();

  -- Generate a new random token and store only the SHA-256 hex hash.
  v_token := encode(extensions.gen_random_bytes(32), 'hex');
  v_token_hash := encode(extensions.digest(v_token, 'sha256'), 'hex');

  insert into public.trip_share_tokens (ride_id, created_by, token_hash, expires_at)
  values (p_ride_id, v_user_id, v_token_hash, v_expires_at);

  return jsonb_build_object(
    'ok', true,
    'token', v_token,
    'expires_at', v_expires_at
  );
end;
$$;

comment on function public.trip_share_create_user_v1(uuid, integer) is
  'Create a trip share token for a ride the caller participates in; stores token_hash only and returns plaintext token.';

grant execute on function public.trip_share_create_user_v1(uuid, integer) to authenticated;

-- ---------------------------------------------------------------------------
-- 2) Public: token-gated view for shared trip status/location
-- ---------------------------------------------------------------------------
create or replace function public.trip_share_view_public_v1(
  p_token text
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions, pg_catalog
as $$
declare
  v_token text := coalesce(btrim(p_token), '');
  v_mode text := 'token';
  v_hash text;
  v_share public.trip_share_tokens%rowtype;
  v_ride public.rides%rowtype;
  v_req public.ride_requests%rowtype;
  v_loc record;
  v_vehicle record;
  v_plate_suffix text;
begin
  if v_token = '' or length(v_token) < 16 then
    return jsonb_build_object('ok', false, 'error', 'invalid_token');
  end if;

  -- 1) token is already a hash
  select * into v_share
  from public.trip_share_tokens t
  where t.token_hash = v_token
  limit 1;

  if found then
    v_mode := 'hash';
  else
    -- 2) token is plaintext; hash it
    v_hash := encode(extensions.digest(v_token, 'sha256'), 'hex');
    select * into v_share
    from public.trip_share_tokens t
    where t.token_hash = v_hash
    limit 1;

    if found then
      v_mode := 'token';
    else
      -- 3) legacy: plaintext persisted in `token`
      select * into v_share
      from public.trip_share_tokens t
      where t.token = v_token
      limit 1;

      if found then
        v_mode := 'legacy_token';
      end if;
    end if;
  end if;

  if not found then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;

  if v_share.revoked_at is not null then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;

  if v_share.expires_at is not null and v_share.expires_at < now() then
    return jsonb_build_object('ok', false, 'error', 'expired', 'token_mode', v_mode);
  end if;

  select * into v_ride
  from public.rides r
  where r.id = v_share.ride_id
  limit 1;

  if not found then
    return jsonb_build_object('ok', false, 'error', 'ride_not_found', 'token_mode', v_mode);
  end if;

  -- ride_requests are optional (defensive; do not hard-fail if missing)
  select * into v_req
  from public.ride_requests rr
  where rr.id = v_ride.request_id
  limit 1;

  -- Latest driver location
  if v_ride.driver_id is not null then
    select dl.lat, dl.lng, dl.updated_at
      into v_loc
    from public.driver_locations dl
    where dl.driver_id = v_ride.driver_id
    order by dl.updated_at desc
    limit 1;
  end if;

  -- Active vehicle (minimal public info)
  if v_ride.driver_id is not null then
    select dv.make, dv.model, dv.color, dv.plate_number, dv.vehicle_type, dv.capacity
      into v_vehicle
    from public.driver_vehicles dv
    where dv.driver_id = v_ride.driver_id
      and dv.is_active = true
    order by dv.updated_at desc
    limit 1;

    if v_vehicle.plate_number is not null then
      v_plate_suffix := right(v_vehicle.plate_number::text, 3);
    end if;
  end if;

  return jsonb_build_object(
    'ok', true,
    'token_mode', v_mode,
    'ride', jsonb_build_object(
      'id', v_ride.id,
      'status', v_ride.status,
      'created_at', v_ride.created_at,
      'started_at', v_ride.started_at,
      'completed_at', v_ride.completed_at,
      'fare_amount_iqd', v_ride.fare_amount_iqd,
      'currency', coalesce(v_ride.currency, 'IQD')
    ),
    'request', case
      when v_req.id is null then null
      else jsonb_build_object(
        'id', v_req.id,
        'status', v_req.status,
        'pickup', jsonb_build_object(
          'lat', v_req.pickup_lat,
          'lng', v_req.pickup_lng,
          'address', v_req.pickup_address
        ),
        'dropoff', jsonb_build_object(
          'lat', v_req.dropoff_lat,
          'lng', v_req.dropoff_lng,
          'address', v_req.dropoff_address
        ),
        'product_code', coalesce(v_req.product_code, v_ride.product_code),
        'service_area_id', v_req.service_area_id,
        'matched_at', v_req.matched_at,
        'accepted_at', v_req.accepted_at
      )
    end,
    'driver', case
      when v_ride.driver_id is null then null
      else jsonb_build_object('id', v_ride.driver_id)
    end,
    'vehicle', case
      when v_vehicle is null then null
      else jsonb_build_object(
        'make', v_vehicle.make,
        'model', v_vehicle.model,
        'color', v_vehicle.color,
        'vehicle_type', v_vehicle.vehicle_type,
        'capacity', v_vehicle.capacity,
        'plate_suffix', v_plate_suffix
      )
    end,
    'location', case
      when v_loc is null then null
      else jsonb_build_object('lat', v_loc.lat, 'lng', v_loc.lng, 'updated_at', v_loc.updated_at)
    end
  );
end;
$$;

comment on function public.trip_share_view_public_v1(text) is
  'Token-gated public view of ride/request status with minimal driver location and vehicle info.';

grant execute on function public.trip_share_view_public_v1(text) to anon;
grant execute on function public.trip_share_view_public_v1(text) to authenticated;
