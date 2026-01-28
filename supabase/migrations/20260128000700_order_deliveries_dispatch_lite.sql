-- P12: Dispatch-lite for merchant orders (deliveries table + driver claim)
--
-- Design notes:
-- - Deliveries are tracked separately from the core rides flow to avoid risky changes.
-- - A delivery is 1:1 with an order (unique order_id).
-- - Driver claim is atomic (UPDATE .. WHERE status='requested' AND driver_id IS NULL RETURNING ..).
-- - RLS allows: customer, merchant owner, assigned driver, admins.
-- - Status changes are guarded + logged into an events table.
-- - Notifications are emitted for: assigned, delivered, cancelled.

begin;

-- -------------------------------------------------------------------
-- 1) Deliveries
-- -------------------------------------------------------------------
create table if not exists public.merchant_order_deliveries (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null unique references public.merchant_orders(id) on delete cascade,
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  customer_id uuid not null references public.profiles(id) on delete restrict,
  driver_id uuid null references public.profiles(id) on delete set null,

  status text not null default 'requested'
    check (status in ('requested','assigned','picked_up','delivered','cancelled')),

  pickup_snapshot jsonb not null default '{}'::jsonb,
  dropoff_snapshot jsonb not null default '{}'::jsonb,

  fee_iqd bigint not null default 0 check (fee_iqd >= 0),

  assigned_at timestamptz,
  picked_up_at timestamptz,
  delivered_at timestamptz,
  cancelled_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists ix_mod_status_created on public.merchant_order_deliveries(status, created_at desc);
create index if not exists ix_mod_driver_active on public.merchant_order_deliveries(driver_id, status) where driver_id is not null;
create index if not exists ix_mod_merchant_created on public.merchant_order_deliveries(merchant_id, created_at desc);
create index if not exists ix_mod_customer_created on public.merchant_order_deliveries(customer_id, created_at desc);

alter table public.merchant_order_deliveries enable row level security;

-- Select policy (single permissive policy to avoid linter warnings)
drop policy if exists merchant_order_deliveries_select on public.merchant_order_deliveries;
drop policy if exists merchant_order_deliveries_select_customer on public.merchant_order_deliveries;
drop policy if exists merchant_order_deliveries_select_merchant_owner on public.merchant_order_deliveries;
drop policy if exists merchant_order_deliveries_select_driver on public.merchant_order_deliveries;

create policy merchant_order_deliveries_select
on public.merchant_order_deliveries
for select
to authenticated
using (
  (select is_admin())
  or customer_id = (select auth.uid())
  or exists (
    select 1
    from public.merchants m
    where m.id = merchant_id
      and m.owner_profile_id = (select auth.uid())
  )
  or (
    exists (select 1 from public.drivers d where d.id = (select auth.uid()))
    and (
      (status = 'requested' and driver_id is null)
      or driver_id = (select auth.uid())
    )
  )
);

-- Updates are allowed only for: (a) assigned driver, (b) merchant owner, (c) admin.
-- Status transitions are still enforced by a guard trigger.
drop policy if exists merchant_order_deliveries_update_actor on public.merchant_order_deliveries;
create policy merchant_order_deliveries_update_actor
on public.merchant_order_deliveries
for update
to authenticated
using (
  (select is_admin())
  or driver_id = (select auth.uid())
  or exists (
    select 1
    from public.merchants m
    where m.id = merchant_id
      and m.owner_profile_id = (select auth.uid())
  )
)
with check (
  (select is_admin())
  or driver_id = (select auth.uid())
  or exists (
    select 1
    from public.merchants m
    where m.id = merchant_id
      and m.owner_profile_id = (select auth.uid())
  )
);

-- No direct inserts/deletes from client. Creation is via SECURITY DEFINER RPC.
revoke insert, delete on public.merchant_order_deliveries from authenticated;

-- Touch updated_at
drop trigger if exists trg_touch_mod_updated_at on public.merchant_order_deliveries;
create trigger trg_touch_mod_updated_at
before update on public.merchant_order_deliveries
for each row
execute function public.touch_updated_at();

-- -------------------------------------------------------------------
-- 2) Delivery events
-- -------------------------------------------------------------------
create table if not exists public.merchant_order_delivery_events (
  id uuid primary key default gen_random_uuid(),
  delivery_id uuid not null references public.merchant_order_deliveries(id) on delete cascade,
  actor_id uuid null,
  actor_role text null,
  from_status text,
  to_status text not null,
  note text,
  created_at timestamptz not null default now()
);

create index if not exists ix_mode_delivery_created on public.merchant_order_delivery_events(delivery_id, created_at asc);

alter table public.merchant_order_delivery_events enable row level security;

-- Mirror select access from the delivery row
drop policy if exists merchant_order_delivery_events_select on public.merchant_order_delivery_events;
create policy merchant_order_delivery_events_select
on public.merchant_order_delivery_events
for select
to authenticated
using (
  exists (
    select 1
    from public.merchant_order_deliveries d
    where d.id = delivery_id
      and (
        d.customer_id = (select auth.uid())
        or d.driver_id = (select auth.uid())
        or exists (
          select 1
          from public.merchants m
          where m.id = d.merchant_id
            and (m.owner_profile_id = (select auth.uid()) or (select is_admin()))
        )
        or (select is_admin())
      )
  )
);

revoke insert, update, delete on public.merchant_order_delivery_events from authenticated;

-- -------------------------------------------------------------------
-- 3) Status guard + notifications
-- -------------------------------------------------------------------
create or replace function public.merchant_order_delivery_guard()
returns trigger
language plpgsql
security definer
set search_path = 'pg_catalog, public'
as $$
declare
  v_from text;
  v_to text;
  v_actor uuid;
  v_actor_role text;
  v_is_admin boolean;
  v_is_driver boolean;
  v_is_merchant_owner boolean;
  v_merch public.merchants;
begin
  v_from := coalesce(old.status, '');
  v_to := coalesce(new.status, '');
  v_actor := (select auth.uid());
  v_is_admin := (select is_admin());
  v_is_driver := exists (select 1 from public.drivers d where d.id = v_actor);

  select * into v_merch from public.merchants m where m.id = new.merchant_id;
  v_is_merchant_owner := (v_merch.owner_profile_id = v_actor);

  -- Prevent changing immutable linkage fields
  if tg_op = 'UPDATE' then
    if new.order_id is distinct from old.order_id
      or new.merchant_id is distinct from old.merchant_id
      or new.customer_id is distinct from old.customer_id
      or new.fee_iqd is distinct from old.fee_iqd
      or new.pickup_snapshot is distinct from old.pickup_snapshot
      or new.dropoff_snapshot is distinct from old.dropoff_snapshot
    then
      raise exception 'immutable_fields';
    end if;
  end if;

  -- Enforce status transitions (admin can override)
  if not v_is_admin and tg_op = 'UPDATE' and v_to is distinct from v_from then
    if v_from = 'requested' and v_to not in ('assigned','cancelled') then
      raise exception 'invalid_transition';
    elsif v_from = 'assigned' and v_to not in ('picked_up','cancelled') then
      raise exception 'invalid_transition';
    elsif v_from = 'picked_up' and v_to not in ('delivered','cancelled') then
      raise exception 'invalid_transition';
    elsif v_from in ('delivered','cancelled') then
      raise exception 'invalid_transition';
    end if;

    -- Actor constraints
    -- - Drivers can only advance their own deliveries (assigned->picked_up->delivered)
    -- - Merchant owners can cancel while not delivered
    if v_is_driver then
      if new.driver_id is distinct from v_actor then
        raise exception 'driver_mismatch';
      end if;
      if v_to = 'cancelled' then
        raise exception 'driver_cannot_cancel';
      end if;
    elsif v_is_merchant_owner then
      if v_to <> 'cancelled' then
        raise exception 'merchant_can_only_cancel';
      end if;
    else
      raise exception 'not_authorized';
    end if;
  end if;

  -- Stamp timestamps
  if tg_op = 'UPDATE' and v_to is distinct from v_from then
    if v_to = 'assigned' then
      new.assigned_at := coalesce(new.assigned_at, now());
    elsif v_to = 'picked_up' then
      new.picked_up_at := coalesce(new.picked_up_at, now());
    elsif v_to = 'delivered' then
      new.delivered_at := coalesce(new.delivered_at, now());
    elsif v_to = 'cancelled' then
      new.cancelled_at := coalesce(new.cancelled_at, now());
    end if;
  end if;

  -- Write event row
  if tg_op = 'INSERT' then
    insert into public.merchant_order_delivery_events(delivery_id, actor_id, actor_role, from_status, to_status, note)
    values (new.id, v_actor, null, null, new.status, null);
  elsif tg_op = 'UPDATE' and v_to is distinct from v_from then
    if v_is_admin then v_actor_role := 'admin';
    elsif v_is_driver then v_actor_role := 'driver';
    elsif v_is_merchant_owner then v_actor_role := 'merchant';
    else v_actor_role := null;
    end if;

    insert into public.merchant_order_delivery_events(delivery_id, actor_id, actor_role, from_status, to_status, note)
    values (new.id, v_actor, v_actor_role, v_from, v_to, null);

    -- Notifications
    if v_to = 'assigned' then
      -- Customer
      insert into public.user_notifications(user_id, kind, title, body, data)
      values (
        new.customer_id,
        'order_delivery',
        'Delivery assigned',
        'A driver has been assigned to your order delivery.',
        jsonb_build_object('order_id', new.order_id, 'delivery_id', new.id)
      );

      -- Merchant owner
      insert into public.user_notifications(user_id, kind, title, body, data)
      values (
        v_merch.owner_profile_id,
        'order_delivery',
        'Delivery assigned',
        'A driver claimed the delivery for an order.',
        jsonb_build_object('order_id', new.order_id, 'delivery_id', new.id)
      );

      -- Driver
      if new.driver_id is not null then
        insert into public.user_notifications(user_id, kind, title, body, data)
        values (
          new.driver_id,
          'order_delivery',
          'New delivery job',
          'You have been assigned a delivery job.',
          jsonb_build_object('order_id', new.order_id, 'delivery_id', new.id)
        );
      end if;

    elsif v_to = 'delivered' then
      insert into public.user_notifications(user_id, kind, title, body, data)
      values (
        new.customer_id,
        'order_delivery',
        'Order delivered',
        'Your order has been marked as delivered.',
        jsonb_build_object('order_id', new.order_id, 'delivery_id', new.id)
      );

      insert into public.user_notifications(user_id, kind, title, body, data)
      values (
        v_merch.owner_profile_id,
        'order_delivery',
        'Order delivered',
        'A delivery has been marked as delivered.',
        jsonb_build_object('order_id', new.order_id, 'delivery_id', new.id)
      );

    elsif v_to = 'cancelled' then
      insert into public.user_notifications(user_id, kind, title, body, data)
      values (
        new.customer_id,
        'order_delivery',
        'Delivery cancelled',
        'The delivery for your order was cancelled.',
        jsonb_build_object('order_id', new.order_id, 'delivery_id', new.id)
      );

      insert into public.user_notifications(user_id, kind, title, body, data)
      values (
        v_merch.owner_profile_id,
        'order_delivery',
        'Delivery cancelled',
        'The delivery for an order was cancelled.',
        jsonb_build_object('order_id', new.order_id, 'delivery_id', new.id)
      );

      if new.driver_id is not null then
        insert into public.user_notifications(user_id, kind, title, body, data)
        values (
          new.driver_id,
          'order_delivery',
          'Delivery cancelled',
          'A delivery you were assigned to was cancelled.',
          jsonb_build_object('order_id', new.order_id, 'delivery_id', new.id)
        );
      end if;
    end if;
  end if;

  return new;
end;
$$;

revoke all on function public.merchant_order_delivery_guard() from public;
revoke all on function public.merchant_order_delivery_guard() from anon;
revoke all on function public.merchant_order_delivery_guard() from authenticated;

drop trigger if exists trg_mod_guard on public.merchant_order_deliveries;
create trigger trg_mod_guard
before insert or update on public.merchant_order_deliveries
for each row
execute function public.merchant_order_delivery_guard();

-- -------------------------------------------------------------------
-- 4) RPCs: request delivery + driver claim
-- -------------------------------------------------------------------
create or replace function public.merchant_order_request_delivery(p_order_id uuid)
returns uuid
language plpgsql
security definer
set search_path = 'pg_catalog, public'
as $$
declare
  v_order public.merchant_orders;
  v_merch public.merchants;
  v_delivery_id uuid;
begin
  select * into v_order
  from public.merchant_orders o
  where o.id = p_order_id
  for update;

  if not found then
    raise exception 'order_not_found';
  end if;

  -- AuthZ: merchant owner or admin
  select * into v_merch from public.merchants m where m.id = v_order.merchant_id;

  if not ( (select is_admin()) or v_merch.owner_profile_id = (select auth.uid()) ) then
    raise exception 'not_authorized';
  end if;

  -- Idempotent: if exists return id
  select d.id into v_delivery_id
  from public.merchant_order_deliveries d
  where d.order_id = v_order.id;

  if v_delivery_id is not null then
    return v_delivery_id;
  end if;

  insert into public.merchant_order_deliveries(
    order_id, merchant_id, customer_id, status,
    pickup_snapshot, dropoff_snapshot,
    fee_iqd
  )
  values (
    v_order.id,
    v_order.merchant_id,
    v_order.customer_id,
    'requested',
    jsonb_build_object(
      'business_name', v_merch.business_name,
      'contact_phone', v_merch.contact_phone,
      'address_text', v_merch.address_text
    ),
    coalesce(v_order.address_snapshot, '{}'::jsonb),
    coalesce(v_order.delivery_fee_iqd, 0)
  )
  returning id into v_delivery_id;

  return v_delivery_id;
end;
$$;

revoke all on function public.merchant_order_request_delivery(uuid) from public;
revoke all on function public.merchant_order_request_delivery(uuid) from anon;
grant execute on function public.merchant_order_request_delivery(uuid) to authenticated;
grant execute on function public.merchant_order_request_delivery(uuid) to service_role;

create or replace function public.driver_claim_order_delivery(p_delivery_id uuid)
returns public.merchant_order_deliveries
language plpgsql
security definer
set search_path = 'pg_catalog, public'
as $$
declare
  v_uid uuid;
  v_row public.merchant_order_deliveries;
begin
  v_uid := (select auth.uid());
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  if not exists (select 1 from public.drivers d where d.id = v_uid) then
    raise exception 'not_a_driver';
  end if;

  update public.merchant_order_deliveries
    set driver_id = v_uid,
        status = 'assigned',
        assigned_at = coalesce(assigned_at, now())
  where id = p_delivery_id
    and status = 'requested'
    and driver_id is null
  returning * into v_row;

  if not found then
    raise exception 'delivery_not_available';
  end if;

  return v_row;
end;
$$;

revoke all on function public.driver_claim_order_delivery(uuid) from public;
revoke all on function public.driver_claim_order_delivery(uuid) from anon;
grant execute on function public.driver_claim_order_delivery(uuid) to authenticated;
grant execute on function public.driver_claim_order_delivery(uuid) to service_role;

-- -------------------------------------------------------------------
-- 5) Realtime publication (deliveries + events)
-- -------------------------------------------------------------------
-- Note: publication exists in Supabase projects as supabase_realtime.
-- Postgres does not support IF NOT EXISTS for publication membership, so we guard duplicates.
do $$
begin
  begin
    alter publication supabase_realtime add table only public.merchant_order_deliveries;
  exception when duplicate_object then
    -- already a member
    null;
  end;

  begin
    alter publication supabase_realtime add table only public.merchant_order_delivery_events;
  exception when duplicate_object then
    null;
  end;
end$$;

commit;
