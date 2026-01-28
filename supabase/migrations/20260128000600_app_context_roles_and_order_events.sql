-- P11: App context RPC + safe role switching + order status state machine + status events timeline
--
-- Goals
-- - Avoid direct client tampering with profiles.active_role by enforcing eligibility via trigger + RPC.
-- - Provide a single RPC to fetch app context (role + eligibility) efficiently.
-- - Enforce sane order status transitions (state machine) at the database layer.
-- - Record order status history for UI timelines and auditing.

begin;

-- 1) App context (single round trip)
create or replace function public.get_my_app_context()
returns table(
  user_id uuid,
  active_role text,
  role_onboarding_completed boolean,
  locale text,
  has_driver boolean,
  driver_vehicle_type text,
  has_merchant boolean,
  merchant_id uuid,
  merchant_status text
)
language sql
stable
security definer
set search_path = public
as $$
  select
    p.id as user_id,
    p.active_role,
    coalesce(p.role_onboarding_completed, false) as role_onboarding_completed,
    coalesce(p.locale, 'en') as locale,
    exists (select 1 from public.drivers d where d.id = p.id) as has_driver,
    (select d.vehicle_type from public.drivers d where d.id = p.id) as driver_vehicle_type,
    exists (select 1 from public.merchants m where m.owner_profile_id = p.id) as has_merchant,
    (select m.id from public.merchants m where m.owner_profile_id = p.id) as merchant_id,
    (select m.status from public.merchants m where m.owner_profile_id = p.id) as merchant_status
  from public.profiles p
  where p.id = auth.uid();
$$;

revoke all on function public.get_my_app_context() from public;
grant execute on function public.get_my_app_context() to authenticated;
grant execute on function public.get_my_app_context() to service_role;


-- 2) Safe role switching (server-side validation)
create or replace function public.set_my_active_role(p_role text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid;
begin
  uid := auth.uid();
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  if p_role is null or p_role not in ('rider','driver','merchant') then
    raise exception 'Invalid role';
  end if;

  if p_role = 'driver' and not exists (select 1 from public.drivers d where d.id = uid) then
    raise exception 'Driver not setup';
  end if;

  if p_role = 'merchant' and not exists (select 1 from public.merchants m where m.owner_profile_id = uid) then
    raise exception 'Merchant not setup';
  end if;

  update public.profiles
    set active_role = p_role
  where id = uid;
end;
$$;

revoke all on function public.set_my_active_role(text) from public;
grant execute on function public.set_my_active_role(text) to authenticated;
grant execute on function public.set_my_active_role(text) to service_role;


-- 3) Guard: prevent invalid direct UPDATEs to profiles.active_role
create or replace function public.profiles_guard_active_role()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.active_role is distinct from old.active_role then
    if (select public.is_admin()) then
      return new;
    end if;

    if new.active_role is null or new.active_role not in ('rider','driver','merchant') then
      raise exception 'Invalid role';
    end if;

    if new.active_role = 'driver' and not exists (select 1 from public.drivers d where d.id = new.id) then
      raise exception 'Driver not setup';
    end if;

    if new.active_role = 'merchant' and not exists (select 1 from public.merchants m where m.owner_profile_id = new.id) then
      raise exception 'Merchant not setup';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_profiles_guard_active_role on public.profiles;
create trigger trg_profiles_guard_active_role
before update of active_role on public.profiles
for each row
execute function public.profiles_guard_active_role();


-- 4) Order state machine enforcement (merchant side)
-- Update the existing guard to enforce allowed transitions for merchant owner (admin can override).
create or replace function public.merchant_orders_guard()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid;
  is_owner boolean;
  is_customer boolean;
  is_admin boolean;
begin
  uid := auth.uid();
  is_admin := (select public.is_admin());
  is_customer := (uid is not null and uid = old.customer_id);
  is_owner := (uid is not null and exists (
    select 1 from public.merchants m where m.id = old.merchant_id and m.owner_profile_id = uid
  ));
  if is_admin then
    is_owner := true;
  end if;

  -- Protect totals from client tampering (only allow changes via privileged RPC / admin)
  if (new.subtotal_iqd is distinct from old.subtotal_iqd
      or new.discount_iqd is distinct from old.discount_iqd
      or new.delivery_fee_iqd is distinct from old.delivery_fee_iqd
      or new.total_iqd is distinct from old.total_iqd)
     and not is_admin then
    raise exception 'Totals are immutable';
  end if;

  -- Status transitions:
  if new.status is distinct from old.status then
    new.status_changed_at := now();

    -- Customer can only cancel from placed
    if is_customer and not is_owner then
      if not (old.status = 'placed' and new.status = 'cancelled') then
        raise exception 'Not allowed';
      end if;
      return new;
    end if;

    -- Merchant owner state machine (admin can override)
    if is_owner and not is_admin then
      -- Final states cannot change
      if old.status in ('fulfilled','cancelled') then
        raise exception 'Order is final';
      end if;

      if old.status = 'placed' and new.status not in ('accepted','cancelled') then
        raise exception 'Invalid status transition';
      elsif old.status = 'accepted' and new.status not in ('preparing','cancelled') then
        raise exception 'Invalid status transition';
      elsif old.status = 'preparing' and new.status not in ('out_for_delivery','cancelled') then
        raise exception 'Invalid status transition';
      elsif old.status = 'out_for_delivery' and new.status not in ('fulfilled','cancelled') then
        raise exception 'Invalid status transition';
      end if;
    end if;
  end if;

  -- merchant_note can only be set by owner/admin
  if new.merchant_note is distinct from old.merchant_note and not is_owner then
    raise exception 'Not allowed';
  end if;

  return new;
end;
$$;


-- 5) Order status events timeline
create table if not exists public.merchant_order_status_events (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.merchant_orders(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  from_status text,
  to_status text not null,
  note text,
  created_at timestamptz not null default now()
);

create index if not exists ix_order_status_events_order_created
on public.merchant_order_status_events(order_id, created_at desc);

alter table public.merchant_order_status_events enable row level security;

create policy merchant_order_status_events_select
on public.merchant_order_status_events
for select
to authenticated
using (
  exists (
    select 1
    from public.merchant_orders o
    join public.merchants m on m.id = o.merchant_id
    where o.id = order_id
      and (
        o.customer_id = (select auth.uid())
        or m.owner_profile_id = (select auth.uid())
        or (select public.is_admin())
      )
  )
);


create or replace function public.merchant_order_status_events_on_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.merchant_order_status_events(order_id, actor_id, from_status, to_status, note)
  values (new.id, coalesce(auth.uid(), new.customer_id), null, new.status, null);
  return new;
end;
$$;

drop trigger if exists trg_order_status_events_on_insert on public.merchant_orders;
create trigger trg_order_status_events_on_insert
after insert on public.merchant_orders
for each row
execute function public.merchant_order_status_events_on_insert();


create or replace function public.merchant_order_status_events_on_status_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid;
  is_owner boolean := false;
begin
  if new.status is not distinct from old.status then
    return new;
  end if;

  uid := auth.uid();
  if uid is not null then
    is_owner := exists (
      select 1
      from public.merchants m
      where m.id = new.merchant_id
        and m.owner_profile_id = uid
    ) or (select public.is_admin());
  end if;

  insert into public.merchant_order_status_events(order_id, actor_id, from_status, to_status, note)
  values (
    new.id,
    uid,
    old.status,
    new.status,
    case when is_owner then nullif(new.merchant_note, '') else null end
  );

  return new;
end;
$$;

drop trigger if exists trg_order_status_events_on_status_change on public.merchant_orders;
create trigger trg_order_status_events_on_status_change
after update of status on public.merchant_orders
for each row
execute function public.merchant_order_status_events_on_status_change();


-- 6) Realtime (optional)
do $$
begin
  begin
    alter publication supabase_realtime add table only public.merchant_order_status_events;
  exception when duplicate_object then
    null;
  end;
end;
$$;

commit;
