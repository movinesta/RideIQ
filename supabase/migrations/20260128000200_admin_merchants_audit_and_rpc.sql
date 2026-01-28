-- P7: Admin merchant approval workflow + status audit log
-- Goals:
-- - Keep merchants table as-is (minimal schema changes)
-- - Always audit status transitions (who/when/note)
-- - Provide an admin RPC to set status with a note (optional)

begin;

-- 1) Status audit log
create table if not exists public.merchant_status_audit_log (
  id uuid primary key default gen_random_uuid(),
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  from_status text,
  to_status text not null,
  note text,
  actor_id uuid, -- nullable to support server-side/service actions without auth.uid()
  created_at timestamptz not null default now()
);

create index if not exists ix_merchant_status_audit_merchant_created
  on public.merchant_status_audit_log(merchant_id, created_at desc);

alter table public.merchant_status_audit_log enable row level security;

-- Admin-only read
drop policy if exists merchant_status_audit_select_admin on public.merchant_status_audit_log;
create policy merchant_status_audit_select_admin
on public.merchant_status_audit_log
for select
to authenticated
using ((select is_admin()));

-- Admin-only insert (normally inserted via triggers/RPC; this prevents client abuse)
drop policy if exists merchant_status_audit_insert_admin on public.merchant_status_audit_log;
create policy merchant_status_audit_insert_admin
on public.merchant_status_audit_log
for insert
to authenticated
with check ((select is_admin()) and actor_id = (select auth.uid()));

-- 2) Audit trigger on merchants.status change
create or replace function public.merchants_audit_status_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_note text;
begin
  if (tg_op = 'UPDATE') then
    if new.status is distinct from old.status then
      v_note := nullif(current_setting('app.merchant_status_note', true), '');
      insert into public.merchant_status_audit_log (merchant_id, from_status, to_status, note, actor_id)
      values (new.id, old.status, new.status, v_note, (select auth.uid()));
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_merchants_audit_status_change on public.merchants;
create trigger trg_merchants_audit_status_change
after update on public.merchants
for each row
execute function public.merchants_audit_status_change();

-- 3) Admin RPC: set merchant status + optional audit note
create or replace function public.admin_set_merchant_status(
  p_merchant_id uuid,
  p_status text,
  p_note text default null
)
returns public.merchants
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.merchants;
begin
  if not (select is_admin()) then
    raise exception 'Admin only';
  end if;

  if p_status not in ('draft','pending','approved','suspended') then
    raise exception 'Invalid status: %', p_status;
  end if;

  perform set_config('app.merchant_status_note', coalesce(p_note, ''), true);

  update public.merchants
  set status = p_status
  where id = p_merchant_id
  returning * into v_row;

  if not found then
    raise exception 'Merchant not found';
  end if;

  return v_row;
end;
$$;

grant execute on function public.admin_set_merchant_status(uuid, text, text) to authenticated;

commit;
