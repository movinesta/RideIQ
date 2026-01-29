-- Voice Calls (Rider <-> Driver <-> Business)
-- Date: 2026-01-29
--
-- Notes:
-- - No seed rows are inserted.
-- - Designed to be service_role-driven via Edge Functions.
-- - Authenticated users can SELECT only calls they participate in.

begin;

-- 1) Enums
do $$
begin
  if not exists (select 1 from pg_type where typname = 'voice_call_provider') then
    create type public.voice_call_provider as enum ('agora', 'daily');
  end if;

  if not exists (select 1 from pg_type where typname = 'voice_call_status') then
    create type public.voice_call_status as enum (
      'created',
      'ringing',
      'active',
      'ended',
      'missed',
      'canceled',
      'failed'
    );
  end if;
end$$;

-- 2) Tables
create table if not exists public.voice_calls (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  provider public.voice_call_provider not null,
  status public.voice_call_status not null default 'created',

  -- optional linkage
  ride_id uuid null references public.rides(id) on delete set null,

  created_by uuid not null references public.profiles(id) on delete cascade,

  -- Agora
  agora_channel text null,

  -- Daily (and Pipecat transport)
  daily_room_name text null,
  daily_room_url text null,

  -- Pipecat (optional)
  pipecat_session_id text null,
  pipecat_agent_name text null,

  started_at timestamptz null,
  ended_at timestamptz null,

  metadata jsonb not null default '{}'::jsonb
);

create index if not exists ix_voice_calls_created_at on public.voice_calls (created_at desc);
create index if not exists ix_voice_calls_ride_id on public.voice_calls (ride_id);
create index if not exists ix_voice_calls_created_by on public.voice_calls (created_by);
create index if not exists ix_voice_calls_status on public.voice_calls (status);

alter table public.voice_calls enable row level security;
alter table public.voice_calls replica identity full;

drop trigger if exists trg_voice_calls_set_updated_at on public.voice_calls;
create trigger trg_voice_calls_set_updated_at
before update on public.voice_calls
for each row execute function public.set_updated_at();


create table if not exists public.voice_call_participants (
  call_id uuid not null references public.voice_calls(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  role text not null check (role in ('rider','driver','business')),
  is_initiator boolean not null default false,
  joined_at timestamptz null,
  left_at timestamptz null,
  primary key (call_id, profile_id)
);

create index if not exists ix_voice_call_participants_profile_id on public.voice_call_participants (profile_id);

alter table public.voice_call_participants enable row level security;
alter table public.voice_call_participants replica identity full;

-- 3) Privileges + Policies
revoke all on table public.voice_calls from anon;
revoke all on table public.voice_call_participants from anon;

-- Authenticated users: read only their calls
grant select on table public.voice_calls to authenticated;
grant select on table public.voice_call_participants to authenticated;

-- service_role: full control (Edge Functions)
grant select, insert, update, delete on table public.voice_calls to service_role;
grant select, insert, update, delete on table public.voice_call_participants to service_role;

drop policy if exists voice_calls_service_role_all on public.voice_calls;
create policy voice_calls_service_role_all
  on public.voice_calls
  for all
  to service_role
  using (true)
  with check (true);

drop policy if exists voice_calls_participant_select on public.voice_calls;
create policy voice_calls_participant_select
  on public.voice_calls
  for select
  to authenticated
  using (
    public.is_admin()
    or created_by = auth.uid()
    or exists (
      select 1
      from public.voice_call_participants p
      where p.call_id = voice_calls.id
        and p.profile_id = auth.uid()
    )
  );


drop policy if exists voice_call_participants_service_role_all on public.voice_call_participants;
create policy voice_call_participants_service_role_all
  on public.voice_call_participants
  for all
  to service_role
  using (true)
  with check (true);

drop policy if exists voice_call_participants_participant_select on public.voice_call_participants;
create policy voice_call_participants_participant_select
  on public.voice_call_participants
  for select
  to authenticated
  using (
    public.is_admin()
    or profile_id = auth.uid()
    or exists (
      select 1
      from public.voice_call_participants p
      where p.call_id = voice_call_participants.call_id
        and p.profile_id = auth.uid()
    )
  );

commit;
