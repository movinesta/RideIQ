-- Add: Merchant chat autopilot settings + idempotency receipts
-- Supports: Database Webhook -> Edge Function flow (merchant-chat-autoreply)
-- Safe to run multiple times.

begin;

create table if not exists public.merchant_chat_ai_settings (
  thread_id uuid primary key references public.merchant_chat_threads(id) on delete cascade,
  auto_enabled boolean not null default false,
  auto_reply_mode text not null default 'smart' check (auto_reply_mode in ('smart','always')),
  min_gap_seconds integer not null default 15 check (min_gap_seconds between 0 and 300),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Ensure updated_at is touched consistently
do $$
begin
  if not exists (select 1 from pg_trigger where tgname = 'trg_touch_mchat_ai_settings_updated_at') then
    create trigger trg_touch_mchat_ai_settings_updated_at
    before update on public.merchant_chat_ai_settings
    for each row execute function public.touch_updated_at();
  end if;
end $$;

alter table public.merchant_chat_ai_settings enable row level security;

-- Policies (drop + recreate for idempotency)
drop policy if exists mcas_select_participant on public.merchant_chat_ai_settings;
drop policy if exists mcas_insert_owner on public.merchant_chat_ai_settings;
drop policy if exists mcas_update_owner on public.merchant_chat_ai_settings;
drop policy if exists mcas_delete_owner on public.merchant_chat_ai_settings;

-- Participants can read settings; only merchant owner/admin can modify.
create policy mcas_select_participant
on public.merchant_chat_ai_settings
for select to authenticated
using (
  exists (
    select 1
    from public.merchant_chat_threads t
    join public.merchants m on m.id = t.merchant_id
    where t.id = merchant_chat_ai_settings.thread_id
      and (
        t.customer_id = (select auth.uid())
        or m.owner_profile_id = (select auth.uid())
        or public.is_admin()
      )
  )
);

create policy mcas_insert_owner
on public.merchant_chat_ai_settings
for insert to authenticated
with check (
  exists (
    select 1
    from public.merchant_chat_threads t
    join public.merchants m on m.id = t.merchant_id
    where t.id = merchant_chat_ai_settings.thread_id
      and (m.owner_profile_id = (select auth.uid()) or public.is_admin())
  )
);

create policy mcas_update_owner
on public.merchant_chat_ai_settings
for update to authenticated
using (
  exists (
    select 1
    from public.merchant_chat_threads t
    join public.merchants m on m.id = t.merchant_id
    where t.id = merchant_chat_ai_settings.thread_id
      and (m.owner_profile_id = (select auth.uid()) or public.is_admin())
  )
)
with check (
  exists (
    select 1
    from public.merchant_chat_threads t
    join public.merchants m on m.id = t.merchant_id
    where t.id = merchant_chat_ai_settings.thread_id
      and (m.owner_profile_id = (select auth.uid()) or public.is_admin())
  )
);

create policy mcas_delete_owner
on public.merchant_chat_ai_settings
for delete to authenticated
using (
  exists (
    select 1
    from public.merchant_chat_threads t
    join public.merchants m on m.id = t.merchant_id
    where t.id = merchant_chat_ai_settings.thread_id
      and (m.owner_profile_id = (select auth.uid()) or public.is_admin())
  )
);

grant select, insert, update, delete on public.merchant_chat_ai_settings to authenticated;

-- Idempotency receipts: one AI reply per customer message (supports webhook retries)
create table if not exists public.merchant_chat_ai_receipts (
  message_id uuid primary key references public.merchant_chat_messages(id) on delete cascade,
  thread_id uuid not null references public.merchant_chat_threads(id) on delete cascade,
  created_at timestamptz not null default now()
);

create index if not exists merchant_chat_ai_receipts_thread_id_idx on public.merchant_chat_ai_receipts(thread_id);

alter table public.merchant_chat_ai_receipts enable row level security;

drop policy if exists mcar_select_participant on public.merchant_chat_ai_receipts;
drop policy if exists mcar_no_write on public.merchant_chat_ai_receipts;

-- Only allow participants to read receipts (optional). No authenticated writes.
create policy mcar_select_participant
on public.merchant_chat_ai_receipts
for select to authenticated
using (
  exists (
    select 1
    from public.merchant_chat_threads t
    join public.merchants m on m.id = t.merchant_id
    where t.id = merchant_chat_ai_receipts.thread_id
      and (
        t.customer_id = (select auth.uid())
        or m.owner_profile_id = (select auth.uid())
        or public.is_admin()
      )
  )
);

create policy mcar_no_write
on public.merchant_chat_ai_receipts
for all to authenticated
using (false)
with check (false);

grant select on public.merchant_chat_ai_receipts to authenticated;

commit;
