-- OTP / Phone normalization / Auth Send SMS Hook support
-- Date: 2026-01-29
--
-- Notes:
-- - No seed rows are inserted.
-- - Constraints are added as NOT VALID to avoid breaking existing data; new/updated rows must comply.

begin;

-- 1) Event log + idempotency for Supabase Auth Send SMS Hook (Standard Webhooks webhook-id)
create table if not exists public.auth_sms_hook_events (
  webhook_id text primary key,
  created_at timestamptz not null default now(),
  user_id uuid null,
  phone_e164 text null,
  otp_hash text null,
  provider_used text null,
  status text not null check (status in ('sent','failed')),
  error text null
);

create index if not exists ix_auth_sms_hook_events_phone on public.auth_sms_hook_events (phone_e164);
create index if not exists ix_auth_sms_hook_events_created_at on public.auth_sms_hook_events (created_at desc);

alter table public.auth_sms_hook_events enable row level security;

-- 2) Iraq-only phone normalization helpers
create or replace function public.normalize_iraq_phone_e164(p_phone text)
returns text
language plpgsql
immutable
as $$
declare
  p text;
begin
  if p_phone is null then
    return null;
  end if;

  p := regexp_replace(trim(p_phone), '[\s\-().]', '', 'g');

  if p like '+%' then
    p := substr(p, 2);
  end if;

  if p like '00%' then
    p := substr(p, 3);
  end if;

  if p like '964%' then
    -- ok
  elsif p like '0%' then
    p := '964' || substr(p, 2);
  elsif p like '7%' then
    p := '964' || p;
  else
    raise exception 'Phone must be an Iraqi mobile number';
  end if;

  if p !~ '^9647[0-9]{9}$' then
    raise exception 'Invalid Iraqi mobile number format';
  end if;

  return '+' || p;
end;
$$;

-- 3) Enforce normalization on public.profiles.phone and public.trusted_contacts.phone
alter table public.profiles add column if not exists phone_e164 text;
create unique index if not exists ux_profiles_phone_e164 on public.profiles (phone_e164) where phone_e164 is not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'profiles_phone_iraq_chk'
      and conrelid = 'public.profiles'::regclass
  ) then
    alter table public.profiles
      add constraint profiles_phone_iraq_chk
      check (phone is null or phone ~ '^\+9647[0-9]{9}$') not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'profiles_phone_e164_iraq_chk'
      and conrelid = 'public.profiles'::regclass
  ) then
    alter table public.profiles
      add constraint profiles_phone_e164_iraq_chk
      check (phone_e164 is null or phone_e164 ~ '^\+9647[0-9]{9}$') not valid;
  end if;
end$$;

create or replace function public.tg_profiles_normalize_iraq_phone()
returns trigger
language plpgsql
as $$
begin
  if new.phone is not null then
    new.phone := public.normalize_iraq_phone_e164(new.phone);
    new.phone_e164 := new.phone;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_profiles_normalize_iraq_phone on public.profiles;
create trigger trg_profiles_normalize_iraq_phone
before insert or update of phone on public.profiles
for each row execute function public.tg_profiles_normalize_iraq_phone();

alter table public.trusted_contacts add column if not exists phone_e164 text;
create index if not exists ix_trusted_contacts_phone_e164 on public.trusted_contacts (phone_e164);

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'trusted_contacts_phone_iraq_chk'
      and conrelid = 'public.trusted_contacts'::regclass
  ) then
    alter table public.trusted_contacts
      add constraint trusted_contacts_phone_iraq_chk
      check (phone is null or phone ~ '^\+9647[0-9]{9}$') not valid;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'trusted_contacts_phone_e164_iraq_chk'
      and conrelid = 'public.trusted_contacts'::regclass
  ) then
    alter table public.trusted_contacts
      add constraint trusted_contacts_phone_e164_iraq_chk
      check (phone_e164 is null or phone_e164 ~ '^\+9647[0-9]{9}$') not valid;
  end if;
end$$;

create or replace function public.tg_trusted_contacts_normalize_iraq_phone()
returns trigger
language plpgsql
as $$
begin
  if new.phone is not null then
    new.phone := public.normalize_iraq_phone_e164(new.phone);
    new.phone_e164 := new.phone;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_trusted_contacts_normalize_iraq_phone on public.trusted_contacts;
create trigger trg_trusted_contacts_normalize_iraq_phone
before insert or update of phone on public.trusted_contacts
for each row execute function public.tg_trusted_contacts_normalize_iraq_phone();

commit;
