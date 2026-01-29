-- OTP linter fixes: function search_path + explicit RLS policy for auth_sms_hook_events
-- Date: 2026-01-29

begin;

-- 1) Fix Security Advisor lint: function_search_path_mutable
-- Explicitly set a safe search_path for all OTP normalization functions.
-- We schema-qualify all non-builtins, so pg_catalog is sufficient.
alter function public.normalize_iraq_phone_e164(text)
  set search_path = pg_catalog;

alter function public.tg_profiles_normalize_iraq_phone()
  set search_path = pg_catalog;

alter function public.tg_trusted_contacts_normalize_iraq_phone()
  set search_path = pg_catalog;

-- 2) Fix Security Advisor info: rls_enabled_no_policy (make intent explicit)
-- Table is meant to be service_role-only (Edge Functions). Add an explicit policy.
alter table public.auth_sms_hook_events enable row level security;

revoke all on table public.auth_sms_hook_events from anon, authenticated;
-- keep ownership privileges intact; grant only to service_role.
grant select, insert, update, delete on table public.auth_sms_hook_events to service_role;

drop policy if exists auth_sms_hook_events_service_role_all on public.auth_sms_hook_events;
create policy auth_sms_hook_events_service_role_all
  on public.auth_sms_hook_events
  for all
  to service_role
  using (true)
  with check (true);

commit;
