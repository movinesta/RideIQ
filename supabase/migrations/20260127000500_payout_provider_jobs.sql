-- P3/P4: Provider payout job queue (admin-controlled, webhook-confirmed)
begin;

create table if not exists public.payout_idempotency (
  id bigserial primary key,
  key text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.payout_provider_jobs (
  id uuid primary key default gen_random_uuid(),
  withdraw_request_id uuid not null references public.wallet_withdraw_requests(id) on delete cascade,
  payout_kind public.withdraw_payout_kind not null,
  amount_iqd bigint not null check (amount_iqd > 0),
  status text not null default 'queued' check (status in ('queued','sent','confirmed','failed','canceled')),
  provider_ref text,
  last_error text,
  request_payload jsonb,
  response_payload jsonb,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  sent_at timestamptz,
  confirmed_at timestamptz,
  failed_at timestamptz
);

alter table public.payout_provider_jobs enable row level security;

-- Only admins can create/update/cancel jobs.
drop policy if exists payout_provider_jobs_write_admin on public.payout_provider_jobs;
create policy payout_provider_jobs_write_admin
on public.payout_provider_jobs
for insert
with check ((select public.is_admin()));

drop policy if exists payout_provider_jobs_update_admin on public.payout_provider_jobs;
create policy payout_provider_jobs_update_admin
on public.payout_provider_jobs
for update
using ((select public.is_admin()))
with check ((select public.is_admin()));

drop policy if exists payout_provider_jobs_delete_admin on public.payout_provider_jobs;
create policy payout_provider_jobs_delete_admin
on public.payout_provider_jobs
for delete
using ((select public.is_admin()));

-- Users can read their own jobs (based on withdraw_request user_id). Admins can read all.
drop policy if exists payout_provider_jobs_select_admin_or_owner on public.payout_provider_jobs;
create policy payout_provider_jobs_select_admin_or_owner
on public.payout_provider_jobs
for select
using (
  (select public.is_admin())
  or exists (
    select 1
    from public.wallet_withdraw_requests w
    where w.id = payout_provider_jobs.withdraw_request_id
      and w.user_id = (select auth.uid())
  )
);

revoke all on table public.payout_provider_jobs from anon, authenticated;
grant select on table public.payout_provider_jobs to authenticated;
grant all on table public.payout_provider_jobs to service_role;

-- Prevent creating multiple active jobs (queued/sent) for the same withdrawal.
create unique index if not exists ux_payout_provider_jobs_active_per_withdraw
  on public.payout_provider_jobs(withdraw_request_id)
  where status in ('queued','sent');

-- Auto-updated timestamps
create or replace function public.payout_provider_jobs_touch()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_payout_provider_jobs_touch on public.payout_provider_jobs;
create trigger trg_payout_provider_jobs_touch
before update on public.payout_provider_jobs
for each row execute function public.payout_provider_jobs_touch();

-- Optional realtime publication for admin dashboards
alter publication supabase_realtime add table public.payout_provider_jobs;

commit;
