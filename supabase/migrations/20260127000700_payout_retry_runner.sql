-- P5: Payout provider adapter layer + retries/backoff + runner (best practice)
begin;

-- 1) Extend payout_provider_jobs for retries/backoff and locking
alter table public.payout_provider_jobs
  add column if not exists attempt_count int not null default 0,
  add column if not exists max_attempts int not null default 8,
  add column if not exists next_attempt_at timestamptz not null default now(),
  add column if not exists last_attempt_at timestamptz,
  add column if not exists locked_at timestamptz,
  add column if not exists lock_token uuid,
  add column if not exists canceled_at timestamptz,
  add column if not exists provider_idempotency_key text;

create index if not exists ix_payout_provider_jobs_status_next
  on public.payout_provider_jobs(status, next_attempt_at);

create index if not exists ix_payout_provider_jobs_locked_at
  on public.payout_provider_jobs(locked_at);

-- Ensure provider_idempotency_key exists (best-effort)
create or replace function public.payout_provider_jobs_set_idem()
returns trigger
language plpgsql
as $$
begin
  if new.provider_idempotency_key is null or new.provider_idempotency_key = '' then
    new.provider_idempotency_key := 'pj_' || replace(new.id::text, '-', '');
  end if;
  return new;
end;
$$;

drop trigger if exists trg_payout_provider_jobs_set_idem on public.payout_provider_jobs;
create trigger trg_payout_provider_jobs_set_idem
before insert on public.payout_provider_jobs
for each row execute function public.payout_provider_jobs_set_idem();

-- 2) Attempts log
create table if not exists public.payout_provider_job_attempts (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.payout_provider_jobs(id) on delete cascade,
  attempt_no int not null,
  status text not null check (status in ('sending','sent','failed','confirmed')),
  request_payload jsonb,
  response_payload jsonb,
  error_message text,
  created_at timestamptz not null default now()
);

create unique index if not exists ux_payout_provider_job_attempts_job_attempt
  on public.payout_provider_job_attempts(job_id, attempt_no);

create index if not exists ix_payout_provider_job_attempts_job_created
  on public.payout_provider_job_attempts(job_id, created_at desc);

alter table public.payout_provider_job_attempts enable row level security;

-- Admins can read attempts; users can read their own attempts (via withdraw_request ownership)
drop policy if exists payout_job_attempts_select_admin_or_owner on public.payout_provider_job_attempts;
create policy payout_job_attempts_select_admin_or_owner
on public.payout_provider_job_attempts
for select
to authenticated
using (
  (select public.is_admin())
  or exists (
    select 1
    from public.payout_provider_jobs j
    join public.wallet_withdraw_requests w on w.id = j.withdraw_request_id
    where j.id = payout_provider_job_attempts.job_id
      and w.user_id = (select auth.uid())
  )
);

revoke all on table public.payout_provider_job_attempts from anon, authenticated;
grant select on table public.payout_provider_job_attempts to authenticated;
grant all on table public.payout_provider_job_attempts to service_role;

-- 3) Service-role claim function (prevents concurrent processing)
create or replace function public.payout_claim_jobs(p_limit int default 10, p_lock_seconds int default 300)
returns setof public.payout_provider_jobs
language plpgsql
security definer
set search_path to 'pg_catalog, public'
as $$
begin
  if current_user <> 'service_role' then
    raise exception 'not_allowed';
  end if;

  return query
  with c as (
    select id
    from public.payout_provider_jobs
    where status in ('queued','failed')
      and next_attempt_at <= now()
      and attempt_count < max_attempts
      and canceled_at is null
      and (locked_at is null or locked_at < now() - (p_lock_seconds || ' seconds')::interval)
    order by next_attempt_at asc, created_at asc
    limit greatest(p_limit, 1)
    for update skip locked
  )
  update public.payout_provider_jobs j
  set locked_at = now(),
      lock_token = gen_random_uuid(),
      updated_at = now()
  from c
  where j.id = c.id
  returning j.*;
end;
$$;

revoke all on function public.payout_claim_jobs(int, int) from public, anon, authenticated;
grant execute on function public.payout_claim_jobs(int, int) to service_role;

-- Optional realtime publication for admin dashboards
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'payout_provider_job_attempts'
  ) then
    alter publication supabase_realtime add table public.payout_provider_job_attempts;
  end if;
end $$;

commit;
