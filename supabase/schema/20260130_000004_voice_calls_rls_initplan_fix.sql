-- Fix: Auth RLS Initialization Plan (initPlan) for voice call tables
-- Date: 2026-01-30
--
-- Supabase linter: 0003_auth_rls_initplan
-- Wrap auth.* calls in scalar subqueries so Postgres can cache them per-statement.

begin;

-- public.voice_calls

drop policy if exists voice_calls_participant_select on public.voice_calls;
create policy voice_calls_participant_select
  on public.voice_calls
  for select
  to authenticated
  using (
    (select public.is_admin())
    or created_by = (select auth.uid())
    or exists (
      select 1
      from public.voice_call_participants p
      where p.call_id = voice_calls.id
        and p.profile_id = (select auth.uid())
    )
  );

-- public.voice_call_participants

drop policy if exists voice_call_participants_participant_select on public.voice_call_participants;
create policy voice_call_participants_participant_select
  on public.voice_call_participants
  for select
  to authenticated
  using (
    (select public.is_admin())
    or profile_id = (select auth.uid())
    or exists (
      select 1
      from public.voice_call_participants p
      where p.call_id = voice_call_participants.call_id
        and p.profile_id = (select auth.uid())
    )
  );

commit;
