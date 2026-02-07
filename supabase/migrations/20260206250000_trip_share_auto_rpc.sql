-- Trip share auto: move token creation + notification side-effects into a DB RPC.
--
-- Motivation:
-- - `trip-share-auto` Edge function is invoked via the DB webhook outbox and should be a thin
--   transport/auth wrapper (no direct business-critical DB writes).
-- - Token creation + idempotency + notification/event writes are correctness-sensitive and
--   belong in Postgres transactions.
--
-- This function is service-role only (invoked by the Edge webhook), and is safe to retry.

create or replace function public.trip_share_auto_create_v1(
  p_ride_id uuid,
  p_rider_id uuid,
  p_ttl_minutes integer default 120
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions, pg_catalog
as $$
declare
  v_role text := auth.role();
  v_ttl integer;
  v_expires_at timestamptz;
  v_existing record;
  v_token text;
  v_token_hash text;
  v_enabled boolean;
  v_settings_ttl integer;
  v_created boolean := false;
  v_ride_status public.ride_status;
  v_i int;
begin
  -- Only service-role (internal) calls are allowed.
  if v_role is distinct from 'service_role' then
    return jsonb_build_object('ok', false, 'error', 'forbidden');
  end if;

  if p_ride_id is null or p_rider_id is null then
    return jsonb_build_object('ok', false, 'error', 'invalid_args');
  end if;

  -- Validate ride ownership + status.
  select r.status
    into v_ride_status
  from public.rides r
  where r.id = p_ride_id
    and r.rider_id = p_rider_id
  limit 1;

  if not found then
    return jsonb_build_object('ok', false, 'error', 'not_found');
  end if;

  if v_ride_status is distinct from 'in_progress'::public.ride_status then
    -- Defensive: trigger already filters for in_progress.
    return jsonb_build_object('ok', true, 'ignored', true, 'reason', 'not_in_progress');
  end if;

  -- Safety settings (defensive; trigger should already have checked this).
  select uss.auto_share_on_trip_start, uss.default_share_ttl_minutes
    into v_enabled, v_settings_ttl
  from public.user_safety_settings uss
  where uss.user_id = p_rider_id
  limit 1;

  if not coalesce(v_enabled, false) then
    return jsonb_build_object('ok', true, 'ignored', true, 'reason', 'disabled');
  end if;

  v_ttl := greatest(5, least(1440, coalesce(p_ttl_minutes, v_settings_ttl, 120)));
  v_expires_at := now() + (v_ttl * interval '1 minute');

  -- Idempotency: if an active token already exists for this ride + rider, reuse it.
  select t.token_hash, t.expires_at
    into v_existing
  from public.trip_share_tokens t
  where t.ride_id = p_ride_id
    and t.created_by = p_rider_id
    and t.revoked_at is null
    and t.expires_at > now()
  order by t.expires_at desc
  limit 1;

  if found and v_existing.token_hash is not null then
    -- Ensure a notification exists (best-effort; do not spam duplicates).
    if not exists (
      select 1
      from public.user_notifications n
      where n.user_id = p_rider_id
        and n.kind = 'trip_share'
        and (n.data ->> 'ride_id') = p_ride_id::text
        and (n.data ->> 'reason') = 'auto_trip_start'
        and n.created_at > (now() - interval '7 days')
      limit 1
    ) then
      insert into public.user_notifications(user_id, kind, title, body, data)
      values (
        p_rider_id,
        'trip_share',
        'Trip started — share link ready',
        'Your trip has started. Share this private link with trusted contacts.',
        jsonb_build_object(
          'ride_id', p_ride_id,
          'token', v_existing.token_hash,
          'expires_at', v_existing.expires_at,
          'reason', 'auto_trip_start'
        )
      );
    end if;

    return jsonb_build_object(
      'ok', true,
      'token_created', false,
      'token', v_existing.token_hash,
      'expires_at', v_existing.expires_at
    );
  end if;

  -- Create a new token (safe retry; extremely low collision probability).
  v_i := 0;
  while v_i < 3 loop
    v_i := v_i + 1;
    v_token := encode(extensions.gen_random_bytes(32), 'hex');
    v_token_hash := encode(extensions.digest(v_token, 'sha256'), 'hex');

    begin
      insert into public.trip_share_tokens(ride_id, created_by, token_hash, expires_at)
      values (p_ride_id, p_rider_id, v_token_hash, v_expires_at);
      v_created := true;
      exit;
    exception
      when unique_violation then
        -- retry token generation
        null;
    end;
  end loop;

  if not v_created then
    return jsonb_build_object('ok', false, 'error', 'token_collision');
  end if;

  -- Event row (dedupe by existence).
  if not exists (
    select 1
    from public.trusted_contact_events e
    where e.user_id = p_rider_id
      and e.ride_id = p_ride_id
      and e.event_type = 'auto_share_token_created'
    limit 1
  ) then
    insert into public.trusted_contact_events(user_id, ride_id, event_type, status, payload)
    values (
      p_rider_id,
      p_ride_id,
      'auto_share_token_created',
      'ok',
      jsonb_build_object('ttl_minutes', v_ttl, 'expires_at', v_expires_at)
    );
  end if;

  -- In-app notification (will enqueue existing notifications outbox via trigger).
  insert into public.user_notifications(user_id, kind, title, body, data)
  values (
    p_rider_id,
    'trip_share',
    'Trip started — share link ready',
    'Your trip has started. Share this private link with trusted contacts.',
    jsonb_build_object(
      'ride_id', p_ride_id,
      'token', v_token_hash,
      'expires_at', v_expires_at,
      'reason', 'auto_trip_start'
    )
  );

  return jsonb_build_object(
    'ok', true,
    'token_created', true,
    'token', v_token_hash,
    'expires_at', v_expires_at
  );
end;
$$;

comment on function public.trip_share_auto_create_v1(uuid, uuid, integer) is
  'Service-role only: idempotently create a trip share token for the rider when a ride enters in_progress and auto-share is enabled; emits a user notification.';

revoke all on function public.trip_share_auto_create_v1(uuid, uuid, integer) from public;
revoke all on function public.trip_share_auto_create_v1(uuid, uuid, integer) from anon;
revoke all on function public.trip_share_auto_create_v1(uuid, uuid, integer) from authenticated;
grant execute on function public.trip_share_auto_create_v1(uuid, uuid, integer) to service_role;
