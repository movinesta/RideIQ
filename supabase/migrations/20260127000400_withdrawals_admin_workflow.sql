-- P2: Withdrawals admin workflow hardening + audit log + payout attempts
-- Best practice goals:
--  - Clients MUST NOT be able to insert/update withdrawals directly (bypass validation / workflow).
--  - Admin workflow happens via SECURITY DEFINER RPCs which already enforce is_admin().
--  - Add immutable audit trail for status transitions + payout attempt logging.

begin;

-- ============================================================================
-- 1) Withdrawal audit log
-- ============================================================================

create table if not exists public.wallet_withdraw_audit_log (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.wallet_withdraw_requests(id) on delete cascade,
  action text not null,
  old_status public.withdraw_request_status,
  new_status public.withdraw_request_status,
  actor_user_id uuid,
  actor_is_admin boolean default false not null,
  note text,
  created_at timestamptz not null default now()
);

alter table public.wallet_withdraw_audit_log enable row level security;

-- Users can view audit for their own withdrawal requests; admins can view all.
drop policy if exists withdraw_audit_select_own_or_admin on public.wallet_withdraw_audit_log;
create policy withdraw_audit_select_own_or_admin
on public.wallet_withdraw_audit_log
for select
to authenticated
using (
  (select public.is_admin())
  or exists (
    select 1
    from public.wallet_withdraw_requests w
    where w.id = request_id
      and w.user_id = (select auth.uid())
  )
);

revoke all on table public.wallet_withdraw_audit_log from authenticated;
grant select on table public.wallet_withdraw_audit_log to authenticated;
grant all on table public.wallet_withdraw_audit_log to service_role;

create index if not exists ix_wallet_withdraw_audit_request_created
  on public.wallet_withdraw_audit_log (request_id, created_at desc);

-- Trigger to log inserts + status changes
create or replace function public.wallet_withdraw_audit_log_trigger()
returns trigger
language plpgsql
security definer
set search_path to 'pg_catalog'
as $$
declare
  v_actor uuid;
  v_is_admin boolean;
begin
  v_actor := (select auth.uid());
  v_is_admin := (select public.is_admin());

  if tg_op = 'INSERT' then
    insert into public.wallet_withdraw_audit_log(
      request_id, action, old_status, new_status, actor_user_id, actor_is_admin, note
    ) values (
      new.id, 'created', null, new.status, v_actor, coalesce(v_is_admin,false), new.note
    );
    return new;
  end if;

  if tg_op = 'UPDATE' then
    if (new.status is distinct from old.status)
       or (new.note is distinct from old.note)
       or (new.payout_reference is distinct from old.payout_reference) then
      insert into public.wallet_withdraw_audit_log(
        request_id, action, old_status, new_status, actor_user_id, actor_is_admin, note
      ) values (
        new.id,
        case
          when new.status is distinct from old.status then 'status_change'
          when new.payout_reference is distinct from old.payout_reference then 'payout_reference_change'
          else 'note_change'
        end,
        old.status,
        new.status,
        v_actor,
        coalesce(v_is_admin,false),
        new.note
      );
    end if;
    return new;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_wallet_withdraw_audit_log on public.wallet_withdraw_requests;
create trigger trg_wallet_withdraw_audit_log
after insert or update on public.wallet_withdraw_requests
for each row execute function public.wallet_withdraw_audit_log_trigger();

-- ============================================================================
-- 2) Payout attempts table (admin-only write, user-readable)
-- ============================================================================

do $$
begin
  if not exists (select 1 from pg_type where typname = 'payout_attempt_status' and typnamespace = 'public'::regnamespace) then
    create type public.payout_attempt_status as enum ('created','sent','succeeded','failed');
  end if;
end$$;

create table if not exists public.wallet_payout_attempts (
  id uuid primary key default gen_random_uuid(),
  withdraw_request_id uuid not null references public.wallet_withdraw_requests(id) on delete cascade,
  payout_kind public.withdraw_payout_kind not null,
  amount_iqd bigint not null check (amount_iqd > 0),
  destination jsonb not null default '{}'::jsonb,
  status public.payout_attempt_status not null default 'created',
  provider_reference text,
  error_code text,
  error_message text,
  request_payload jsonb,
  response_payload jsonb,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists ux_wallet_payout_attempts_withdraw_request
  on public.wallet_payout_attempts(withdraw_request_id);

create index if not exists ix_wallet_payout_attempts_status_created
  on public.wallet_payout_attempts(status, created_at desc);

alter table public.wallet_payout_attempts enable row level security;

drop policy if exists wallet_payout_attempts_select_own_or_admin on public.wallet_payout_attempts;
create policy wallet_payout_attempts_select_own_or_admin
on public.wallet_payout_attempts
for select
to authenticated
using (
  (select public.is_admin())
  or exists (
    select 1
    from public.wallet_withdraw_requests w
    where w.id = withdraw_request_id
      and w.user_id = (select auth.uid())
  )
);

revoke all on table public.wallet_payout_attempts from authenticated;
grant select on table public.wallet_payout_attempts to authenticated;
grant all on table public.wallet_payout_attempts to service_role;

create or replace function public.set_updated_at_wallet_payout_attempts()
returns trigger
language plpgsql
security definer
set search_path to 'pg_catalog'
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists wallet_payout_attempts_set_updated_at on public.wallet_payout_attempts;
create trigger wallet_payout_attempts_set_updated_at
before update on public.wallet_payout_attempts
for each row execute function public.set_updated_at_wallet_payout_attempts();

-- Automatically log a payout attempt when a withdrawal becomes PAID (manual or integrated).
create or replace function public.wallet_payout_attempts_autolog_paid()
returns trigger
language plpgsql
security definer
set search_path to 'pg_catalog'
as $$
declare
  v_actor uuid := (select auth.uid());
begin
  if new.status = 'paid' and (old.status is distinct from new.status) then
    insert into public.wallet_payout_attempts(
      withdraw_request_id, payout_kind, amount_iqd, destination, status, provider_reference, created_by, request_payload, response_payload
    ) values (
      new.id,
      new.payout_kind,
      new.amount_iqd,
      new.destination,
      'succeeded',
      new.payout_reference,
      v_actor,
      jsonb_build_object('autolog', true, 'path', 'admin_withdraw_mark_paid'),
      null
    )
    on conflict (withdraw_request_id) do update
      set status = excluded.status,
          provider_reference = coalesce(excluded.provider_reference, public.wallet_payout_attempts.provider_reference),
          updated_at = now();
  end if;

  return new;
end;
$$;

drop trigger if exists trg_wallet_payout_attempts_autolog_paid on public.wallet_withdraw_requests;
create trigger trg_wallet_payout_attempts_autolog_paid
after update on public.wallet_withdraw_requests
for each row execute function public.wallet_payout_attempts_autolog_paid();

-- ============================================================================
-- 3) Remove direct client DML on wallet_withdraw_requests (RPC-only workflow)
-- ============================================================================

drop policy if exists withdraw_insert_own on public.wallet_withdraw_requests;
drop policy if exists withdraw_update_admin_or_cancel_own on public.wallet_withdraw_requests;

revoke all on table public.wallet_withdraw_requests from authenticated;
grant select on table public.wallet_withdraw_requests to authenticated;
grant all on table public.wallet_withdraw_requests to service_role;

-- Realtime (optional): allow realtime subscriptions for admin dashboards / user status updates.
alter publication supabase_realtime add table public.wallet_withdraw_audit_log;
alter publication supabase_realtime add table public.wallet_payout_attempts;

commit;
