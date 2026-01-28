-- RideIQ: Admin user management + audit (best-practice)
-- Generated: 2026-01-27
--
-- Goals:
-- 1) Manage admin membership via SECURITY DEFINER RPCs (no direct table writes from client)
-- 2) Maintain an audit trail for grant/revoke operations
-- 3) Avoid accidental lockout by blocking removal of the last remaining admin

-- -------------------------------------------------------------------
-- Audit log table
-- -------------------------------------------------------------------
create table if not exists public.admin_audit_log (
  id bigserial primary key,
  created_at timestamptz not null default now(),
  actor_id uuid not null references public.profiles(id) on delete restrict,
  action text not null check (action in ('grant_admin','revoke_admin')),
  target_user_id uuid not null references public.profiles(id) on delete restrict,
  note text
);

alter table public.admin_audit_log enable row level security;

drop policy if exists admin_audit_log_admin_select on public.admin_audit_log;
create policy admin_audit_log_admin_select
  on public.admin_audit_log
  for select
  to authenticated
  using ((select public.is_admin()));

-- Tighten privileges: admins can read the audit; writes happen only via SECURITY DEFINER functions.
revoke all on table public.admin_audit_log from authenticated;
grant select on table public.admin_audit_log to authenticated;

-- -------------------------------------------------------------------
-- admin_users: remove direct DML from authenticated (use RPCs instead)
-- -------------------------------------------------------------------
-- Keep SELECT for admins.
drop policy if exists admin_users_admin_insert on public.admin_users;
drop policy if exists admin_users_admin_update on public.admin_users;
drop policy if exists admin_users_admin_delete on public.admin_users;

-- Ensure only explicit, least-privilege grants.
revoke all on table public.admin_users from authenticated;
grant select on table public.admin_users to authenticated;

-- -------------------------------------------------------------------
-- RPCs
-- -------------------------------------------------------------------

create or replace function public.admin_grant_user(p_user uuid, p_note text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not (select public.is_admin()) then
    raise exception 'forbidden';
  end if;

  if p_user is null then
    raise exception 'missing_user_id';
  end if;

  insert into public.admin_users (user_id, created_by, note)
  values (p_user, (select auth.uid()), p_note)
  on conflict (user_id) do update
    set note = coalesce(excluded.note, public.admin_users.note);

  insert into public.admin_audit_log (actor_id, action, target_user_id, note)
  values ((select auth.uid()), 'grant_admin', p_user, p_note);
end;
$$;

revoke all on function public.admin_grant_user(uuid, text) from public;
revoke all on function public.admin_grant_user(uuid, text) from anon;
grant execute on function public.admin_grant_user(uuid, text) to authenticated;


create or replace function public.admin_revoke_user(p_user uuid, p_note text default null)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  remaining_admins integer;
begin
  if not (select public.is_admin()) then
    raise exception 'forbidden';
  end if;

  if p_user is null then
    raise exception 'missing_user_id';
  end if;

  -- Prevent removing the last remaining admin (avoid lockout).
  with admin_set as (
    select p.id
    from public.profiles p
    where coalesce(p.is_admin, false) = true
    union
    select au.user_id as id
    from public.admin_users au
  )
  select count(*) into remaining_admins
  from admin_set
  where id <> p_user;

  if remaining_admins < 1 then
    raise exception 'cannot_remove_last_admin';
  end if;

  delete from public.admin_users where user_id = p_user;

  insert into public.admin_audit_log (actor_id, action, target_user_id, note)
  values ((select auth.uid()), 'revoke_admin', p_user, p_note);
end;
$$;

revoke all on function public.admin_revoke_user(uuid, text) from public;
revoke all on function public.admin_revoke_user(uuid, text) from anon;
grant execute on function public.admin_revoke_user(uuid, text) to authenticated;
