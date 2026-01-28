-- P8: Role onboarding (single-app super-app mode selector)
-- Goals:
-- - show role chooser once per user (DB-backed flag)
-- - keep schema changes minimal

begin;

alter table public.profiles
  add column if not exists role_onboarding_completed boolean not null default false;

-- optional: index not required (single-row lookup by PK)

commit;
