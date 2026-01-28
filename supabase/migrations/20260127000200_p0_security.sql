-- RideIQ: P0 security hardening (wallet + admin)
-- Generated: 2026-01-27
--
-- Goals:
-- 1) Prevent client-side wallet balance tampering (wallet_accounts must not be writable by authenticated users)
-- 2) Prevent privilege escalation via profiles.is_admin (admin membership moves to admin_users + is_admin() RPC)
-- 3) Prefer least-privilege GRANTs + RLS best practices (wrap auth.* calls with SELECT for initPlan)

-- -------------------------------------------------------------------
-- Admin: dedicated membership table
-- -------------------------------------------------------------------
create table if not exists public.admin_users (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  created_by uuid null references public.profiles(id),
  note text
);

alter table public.admin_users enable row level security;

-- Service role can do everything (bypassrls anyway, but we keep explicit policy for clarity)
drop policy if exists admin_users_service_role_all on public.admin_users;
create policy admin_users_service_role_all
  on public.admin_users
  to service_role
  using (true)
  with check (true);

-- Only admins can view/manage admin membership
drop policy if exists admin_users_admin_select on public.admin_users;
create policy admin_users_admin_select
  on public.admin_users
  for select
  to authenticated
  using ((select public.is_admin()));

drop policy if exists admin_users_admin_insert on public.admin_users;
create policy admin_users_admin_insert
  on public.admin_users
  for insert
  to authenticated
  with check ((select public.is_admin()));

drop policy if exists admin_users_admin_update on public.admin_users;
create policy admin_users_admin_update
  on public.admin_users
  for update
  to authenticated
  using ((select public.is_admin()))
  with check ((select public.is_admin()));

drop policy if exists admin_users_admin_delete on public.admin_users;
create policy admin_users_admin_delete
  on public.admin_users
  for delete
  to authenticated
  using ((select public.is_admin()));

-- Admin helper RPCs (SECURITY DEFINER + fixed search_path is the recommended pattern)
create or replace function public.is_admin() returns boolean
  language sql
  stable
  security definer
  set search_path = ''
as $$
  -- Prefer membership table; fallback to legacy flag for backward compatibility.
  select
    exists(
      select 1
      from public.admin_users au
      where au.user_id = (select auth.uid())
    )
    or coalesce(
      (select p.is_admin from public.profiles p where p.id = (select auth.uid())),
      false
    );
$$;

create or replace function public.is_admin(p_user uuid) returns boolean
  language sql
  stable
  security definer
  set search_path = ''
as $$
  select
    exists(
      select 1
      from public.admin_users au
      where au.user_id = p_user
    )
    or coalesce(
      (select p.is_admin from public.profiles p where p.id = p_user),
      false
    );
$$;

-- -------------------------------------------------------------------
-- Profiles: lock down sensitive columns + remove unnecessary client INSERT
-- -------------------------------------------------------------------
-- Remove client INSERT policy (profiles are created by handle_new_user() trigger)
drop policy if exists profiles_insert_self on public.profiles;

-- Tighten table privileges (RLS controls rows; GRANT controls columns)
revoke all on table public.profiles from authenticated;
grant select on table public.profiles to authenticated;
grant update (display_name, phone, avatar_object_key, locale, active_role, gender) on table public.profiles to authenticated;

-- Defense-in-depth: reject attempts to change protected columns even if privileges drift later.
create or replace function public.guard_profiles_sensitive_update()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Allow privileged DB roles and service role operations
  if current_user in ('service_role','postgres','supabase_admin') then
    return new;
  end if;

  -- Block any change to admin/rating fields from client context
  if new.is_admin is distinct from old.is_admin then
    raise exception 'cannot_change_is_admin';
  end if;

  if new.rating_avg is distinct from old.rating_avg
     or new.rating_count is distinct from old.rating_count then
    raise exception 'cannot_change_rating_fields';
  end if;

  return new;
end;
$$;

-- Ensure the trigger function is NOT directly executable by PUBLIC
revoke all on function public.guard_profiles_sensitive_update() from public;
revoke all on function public.guard_profiles_sensitive_update() from anon;
revoke all on function public.guard_profiles_sensitive_update() from authenticated;

drop trigger if exists trg_guard_profiles_sensitive_update on public.profiles;
create trigger trg_guard_profiles_sensitive_update
before update on public.profiles
for each row
execute function public.guard_profiles_sensitive_update();

-- -------------------------------------------------------------------
-- Wallet: authenticated users must not be able to mutate balances
-- -------------------------------------------------------------------
-- Remove writable policies
drop policy if exists rls_insert on public.wallet_accounts;
drop policy if exists rls_update on public.wallet_accounts;
drop policy if exists rls_delete on public.wallet_accounts;

-- Keep select for own row (already present as rls_select) + service_role all (already present).
-- Tighten privileges
revoke all on table public.wallet_accounts from authenticated;
grant select on table public.wallet_accounts to authenticated;

-- Optional: keep service_role grants explicit
grant all on table public.wallet_accounts to service_role;
