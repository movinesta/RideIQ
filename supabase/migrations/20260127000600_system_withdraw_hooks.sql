-- P4: Service-role-only helpers for provider webhooks (withdraw payouts)
-- Providers call Edge Functions without JWT. Edge Functions use service_role to finalize.
begin;

-- Mark withdraw paid (service role only)
create or replace function public.system_withdraw_mark_paid(
  p_request_id uuid,
  p_payout_reference text default null,
  p_provider_payload jsonb default null
) returns void
language plpgsql
security definer
set search_path to 'pg_catalog, public'
as $$
declare
  r record;
  h record;
begin
  -- Ensure only service_role can execute
  if current_user <> 'service_role' then
    raise exception 'not_allowed';
  end if;

  select * into r
  from public.wallet_withdraw_requests
  where id = p_request_id
  for update;

  if not found then
    raise exception 'withdraw_request_not_found';
  end if;

  if r.status <> 'approved' then
    raise exception 'invalid_status_transition';
  end if;

  -- lock active hold
  select * into h
  from public.wallet_holds
  where withdraw_request_id = r.id and status = 'active'
  order by created_at desc
  limit 1
  for update;

  -- lock wallet account
  perform 1 from public.wallet_accounts wa where wa.user_id = r.user_id for update;

  update public.wallet_accounts
  set held_iqd = greatest(held_iqd - r.amount_iqd, 0),
      balance_iqd = balance_iqd - r.amount_iqd,
      updated_at = now()
  where user_id = r.user_id;

  -- mark hold completed if present
  if h.id is not null then
    update public.wallet_holds
      set status = 'completed',
          updated_at = now()
    where id = h.id;
  end if;

  update public.wallet_withdraw_requests
  set status = 'paid',
      payout_reference = coalesce(nullif(p_payout_reference,''), payout_reference),
      paid_at = now(),
      updated_at = now()
  where id = r.id;

  -- best-effort attempt log update with provider payload
  insert into public.wallet_payout_attempts(
    withdraw_request_id, payout_kind, amount_iqd, destination, status, provider_reference, request_payload, response_payload
  ) values (
    r.id, r.payout_kind, r.amount_iqd, r.destination, 'succeeded', p_payout_reference, p_provider_payload, null
  )
  on conflict (withdraw_request_id) do update
    set status = 'succeeded',
        provider_reference = coalesce(excluded.provider_reference, public.wallet_payout_attempts.provider_reference),
        response_payload = coalesce(excluded.request_payload, public.wallet_payout_attempts.response_payload),
        updated_at = now();
end;
$$;

revoke all on function public.system_withdraw_mark_paid(uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.system_withdraw_mark_paid(uuid, text, jsonb) to service_role;

-- Mark attempt failed (keeps withdraw approved so admin can retry)
create or replace function public.system_withdraw_mark_failed(
  p_request_id uuid,
  p_error_message text,
  p_provider_payload jsonb default null
) returns void
language plpgsql
security definer
set search_path to 'pg_catalog, public'
as $$
declare
  r record;
begin
  if current_user <> 'service_role' then
    raise exception 'not_allowed';
  end if;

  select * into r
  from public.wallet_withdraw_requests
  where id = p_request_id
  for update;

  if not found then
    raise exception 'withdraw_request_not_found';
  end if;

  if r.status <> 'approved' then
    -- no-op for other statuses
    return;
  end if;

  insert into public.wallet_payout_attempts(
    withdraw_request_id, payout_kind, amount_iqd, destination, status, error_message, request_payload
  ) values (
    r.id, r.payout_kind, r.amount_iqd, r.destination, 'failed', p_error_message, p_provider_payload
  )
  on conflict (withdraw_request_id) do update
    set status = 'failed',
        error_message = excluded.error_message,
        request_payload = coalesce(excluded.request_payload, public.wallet_payout_attempts.request_payload),
        updated_at = now();

end;
$$;

revoke all on function public.system_withdraw_mark_failed(uuid, text, jsonb) from public, anon, authenticated;
grant execute on function public.system_withdraw_mark_failed(uuid, text, jsonb) to service_role;

commit;
