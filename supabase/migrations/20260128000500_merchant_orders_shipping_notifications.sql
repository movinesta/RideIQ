-- P10: Merchant orders + shipping addresses + order notifications
-- Design notes:
-- - Shipping address is stored as a snapshot on the order, so later edits to a saved address won't affect history.
-- - Money is stored in IQD minor units using BIGINT (no floating point).
-- - Order creation and status updates are done via SECURITY DEFINER RPCs to keep totals authoritative.

begin;

-- 1) Customer saved addresses
create table if not exists public.customer_addresses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  label text,
  recipient_name text,
  phone text,
  city text not null,
  area text,
  address_line1 text not null,
  address_line2 text,
  notes text,
  loc geography(point, 4326),
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists ix_customer_addresses_user on public.customer_addresses(user_id);
create index if not exists ix_customer_addresses_user_default on public.customer_addresses(user_id) where is_default = true;

alter table public.customer_addresses enable row level security;

create policy customer_addresses_select_own_or_admin
on public.customer_addresses
for select
to authenticated
using (
  user_id = (select auth.uid())
  or (select public.is_admin())
);

create policy customer_addresses_insert_own
on public.customer_addresses
for insert
to authenticated
with check (
  user_id = (select auth.uid())
);

create policy customer_addresses_update_own_or_admin
on public.customer_addresses
for update
to authenticated
using (
  user_id = (select auth.uid())
  or (select public.is_admin())
)
with check (
  user_id = (select auth.uid())
  or (select public.is_admin())
);

create policy customer_addresses_delete_own_or_admin
on public.customer_addresses
for delete
to authenticated
using (
  user_id = (select auth.uid())
  or (select public.is_admin())
);

drop trigger if exists trg_touch_customer_addresses_updated_at on public.customer_addresses;
create trigger trg_touch_customer_addresses_updated_at
before update on public.customer_addresses
for each row
execute function public.touch_updated_at();

-- Ensure only one default per user
create or replace function public.customer_addresses_enforce_single_default()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.is_default then
    update public.customer_addresses
      set is_default = false
    where user_id = new.user_id
      and id <> new.id;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_customer_addresses_single_default on public.customer_addresses;
create trigger trg_customer_addresses_single_default
after insert or update of is_default on public.customer_addresses
for each row
execute function public.customer_addresses_enforce_single_default();


-- 2) Merchant orders + items
create table if not exists public.merchant_orders (
  id uuid primary key default gen_random_uuid(),
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  customer_id uuid not null references public.profiles(id) on delete restrict,
  status text not null default 'placed' check (status in ('placed','accepted','preparing','out_for_delivery','fulfilled','cancelled')),
  currency text not null default 'IQD',
  subtotal_iqd bigint not null default 0 check (subtotal_iqd >= 0),
  discount_iqd bigint not null default 0 check (discount_iqd >= 0),
  delivery_fee_iqd bigint not null default 0 check (delivery_fee_iqd >= 0),
  total_iqd bigint not null default 0 check (total_iqd >= 0),
  address_id uuid references public.customer_addresses(id) on delete set null,
  address_snapshot jsonb not null default '{}'::jsonb,
  customer_note text,
  merchant_note text,
  status_changed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists ix_merchant_orders_merchant_created on public.merchant_orders(merchant_id, created_at desc);
create index if not exists ix_merchant_orders_customer_created on public.merchant_orders(customer_id, created_at desc);
create index if not exists ix_merchant_orders_status on public.merchant_orders(status);

alter table public.merchant_orders enable row level security;

-- Customer can see their orders; merchant owner can see their merchant orders; admin can see all
create policy merchant_orders_select
on public.merchant_orders
for select
to authenticated
using (
  customer_id = (select auth.uid())
  or exists (
    select 1
    from public.merchants m
    where m.id = merchant_id
      and m.owner_profile_id = (select auth.uid())
  )
  or (select public.is_admin())
);

-- Updates are primarily done via RPC (SECURITY DEFINER). We still allow UPDATE but guard in trigger.
create policy merchant_orders_update
on public.merchant_orders
for update
to authenticated
using (
  customer_id = (select auth.uid())
  or exists (
    select 1
    from public.merchants m
    where m.id = merchant_id
      and m.owner_profile_id = (select auth.uid())
  )
  or (select public.is_admin())
)
with check (
  customer_id = (select auth.uid())
  or exists (
    select 1
    from public.merchants m
    where m.id = merchant_id
      and m.owner_profile_id = (select auth.uid())
  )
  or (select public.is_admin())
);

create table if not exists public.merchant_order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.merchant_orders(id) on delete cascade,
  product_id uuid references public.merchant_products(id) on delete set null,
  name_snapshot text not null,
  unit_price_iqd bigint not null check (unit_price_iqd >= 0),
  qty integer not null check (qty > 0),
  line_total_iqd bigint not null check (line_total_iqd >= 0),
  meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists ix_merchant_order_items_order on public.merchant_order_items(order_id);

alter table public.merchant_order_items enable row level security;

create policy merchant_order_items_select
on public.merchant_order_items
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


-- 3) Order write RPCs

-- Helper: pick the best active promotion for a product (max savings)
create or replace function public.merchant_best_promo(p_merchant_id uuid, p_product_id uuid, p_price_iqd bigint)
returns table(promo_id uuid, unit_price_iqd bigint, savings_iqd bigint)
language plpgsql
security definer
set search_path = public
as $$
declare
  r record;
  best_savings bigint := 0;
  best_unit bigint := p_price_iqd;
  best_id uuid := null;
  now_ts timestamptz := now();
  savings bigint;
  pct numeric;
  fixed numeric;
begin
  for r in
    select id, discount_type, value
    from public.merchant_promotions
    where merchant_id = p_merchant_id
      and is_active = true
      and (starts_at is null or starts_at <= now_ts)
      and (ends_at is null or ends_at >= now_ts)
      and (product_id is null or product_id = p_product_id)
  loop
    if r.discount_type = 'percent' then
      pct := r.value;
      savings := floor((p_price_iqd::numeric * pct) / 100)::bigint;
    else
      fixed := r.value;
      savings := floor(fixed)::bigint;
    end if;

    if savings > best_savings then
      best_savings := savings;
      best_id := r.id;
      best_unit := greatest(p_price_iqd - savings, 0);
    end if;
  end loop;

  promo_id := best_id;
  savings_iqd := greatest(best_savings, 0);
  unit_price_iqd := best_unit;
  return next;
end;
$$;

revoke all on function public.merchant_best_promo(uuid,uuid,bigint) from public;
grant execute on function public.merchant_best_promo(uuid,uuid,bigint) to authenticated;
grant execute on function public.merchant_best_promo(uuid,uuid,bigint) to service_role;


-- Create an order atomically from a list of items.
-- p_items JSON format: [{"product_id":"uuid","qty":2}, ...]
create or replace function public.merchant_order_create(
  p_merchant_id uuid,
  p_address_id uuid,
  p_customer_note text,
  p_items jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid;
  order_id uuid;
  it jsonb;
  product_id uuid;
  qty integer;
  prod record;
  promo record;
  unit_price bigint;
  line_total bigint;
  subtotal bigint := 0;
  discount bigint := 0;
  delivery_fee bigint := 0;
  total bigint := 0;
  addr record;
  addr_snapshot jsonb := '{}'::jsonb;
begin
  uid := auth.uid();
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  if not exists (
    select 1 from public.merchants m
    where m.id = p_merchant_id
      and m.status = 'approved'
  ) then
    raise exception 'Merchant not available';
  end if;

  if p_items is null or jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) = 0 then
    raise exception 'Empty order';
  end if;

  if p_address_id is not null then
    select * into addr
    from public.customer_addresses a
    where a.id = p_address_id
      and a.user_id = uid;

    if not found then
      raise exception 'Invalid address';
    end if;

    addr_snapshot := jsonb_build_object(
      'id', addr.id,
      'label', addr.label,
      'recipient_name', addr.recipient_name,
      'phone', addr.phone,
      'city', addr.city,
      'area', addr.area,
      'address_line1', addr.address_line1,
      'address_line2', addr.address_line2,
      'notes', addr.notes
    );
  end if;

  -- Insert order shell
  insert into public.merchant_orders(
    merchant_id,
    customer_id,
    status,
    subtotal_iqd,
    discount_iqd,
    delivery_fee_iqd,
    total_iqd,
    address_id,
    address_snapshot,
    customer_note
  ) values (
    p_merchant_id,
    uid,
    'placed',
    0,
    0,
    delivery_fee,
    0,
    p_address_id,
    addr_snapshot,
    nullif(p_customer_note, '')
  ) returning id into order_id;

  -- Items
  for it in select * from jsonb_array_elements(p_items)
  loop
    product_id := (it->>'product_id')::uuid;
    qty := greatest((it->>'qty')::int, 0);
    if qty <= 0 or qty > 99 then
      raise exception 'Invalid qty';
    end if;

    select id, name, price_iqd, is_active into prod
    from public.merchant_products
    where id = product_id
      and merchant_id = p_merchant_id;

    if not found or prod.is_active is not true then
      raise exception 'Invalid product';
    end if;

    select * into promo
    from public.merchant_best_promo(p_merchant_id, product_id, prod.price_iqd);

    unit_price := promo.unit_price_iqd;
    line_total := unit_price * qty;
    subtotal := subtotal + (prod.price_iqd * qty);
    discount := discount + (greatest(prod.price_iqd - unit_price, 0) * qty);

    insert into public.merchant_order_items(
      order_id,
      product_id,
      name_snapshot,
      unit_price_iqd,
      qty,
      line_total_iqd,
      meta
    ) values (
      order_id,
      product_id,
      prod.name,
      unit_price,
      qty,
      line_total,
      jsonb_build_object(
        'promo_id', promo.promo_id,
        'original_price_iqd', prod.price_iqd,
        'savings_iqd', promo.savings_iqd
      )
    );
  end loop;

  total := greatest(subtotal - discount + delivery_fee, 0);

  update public.merchant_orders
    set subtotal_iqd = subtotal,
        discount_iqd = discount,
        delivery_fee_iqd = delivery_fee,
        total_iqd = total
  where id = order_id;

  return order_id;
end;
$$;

revoke all on function public.merchant_order_create(uuid,uuid,text,jsonb) from public;
grant execute on function public.merchant_order_create(uuid,uuid,text,jsonb) to authenticated;
grant execute on function public.merchant_order_create(uuid,uuid,text,jsonb) to service_role;


-- Change order status (merchant owner/admin any, customer can only cancel when placed)
create or replace function public.merchant_order_set_status(
  p_order_id uuid,
  p_status text,
  p_merchant_note text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid;
  o record;
  is_owner boolean := false;
  is_customer boolean := false;
begin
  uid := auth.uid();
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  select * into o from public.merchant_orders where id = p_order_id;
  if not found then
    raise exception 'Order not found';
  end if;

  is_customer := (o.customer_id = uid);
  is_owner := exists (
    select 1 from public.merchants m
    where m.id = o.merchant_id
      and m.owner_profile_id = uid
  );

  if (select public.is_admin()) then
    is_owner := true;
  end if;

  if is_owner then
    update public.merchant_orders
      set status = p_status,
          merchant_note = nullif(p_merchant_note, '')
    where id = p_order_id;
    return;
  end if;

  if is_customer then
    -- customer can only cancel while still placed
    if p_status <> 'cancelled' or o.status <> 'placed' then
      raise exception 'Not allowed';
    end if;
    update public.merchant_orders
      set status = 'cancelled'
    where id = p_order_id;
    return;
  end if;

  raise exception 'Not allowed';
end;
$$;

revoke all on function public.merchant_order_set_status(uuid,text,text) from public;
grant execute on function public.merchant_order_set_status(uuid,text,text) to authenticated;
grant execute on function public.merchant_order_set_status(uuid,text,text) to service_role;


-- 4) Guard rails + status timestamps
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
begin
  uid := auth.uid();
  is_customer := (uid is not null and uid = old.customer_id);
  is_owner := (uid is not null and exists (
    select 1 from public.merchants m where m.id = old.merchant_id and m.owner_profile_id = uid
  ));
  if (select public.is_admin()) then
    is_owner := true;
  end if;

  -- Protect totals from client tampering (only allow changes via privileged RPC / admin)
  if (new.subtotal_iqd is distinct from old.subtotal_iqd
      or new.discount_iqd is distinct from old.discount_iqd
      or new.delivery_fee_iqd is distinct from old.delivery_fee_iqd
      or new.total_iqd is distinct from old.total_iqd)
     and not (select public.is_admin()) then
    raise exception 'Totals are immutable';
  end if;

  -- Status transitions:
  if new.status is distinct from old.status then
    new.status_changed_at := now();
    -- customer can only cancel from placed
    if is_customer and not is_owner then
      if not (old.status = 'placed' and new.status = 'cancelled') then
        raise exception 'Not allowed';
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

drop trigger if exists trg_merchant_orders_guard on public.merchant_orders;
create trigger trg_merchant_orders_guard
before update on public.merchant_orders
for each row
execute function public.merchant_orders_guard();

drop trigger if exists trg_touch_merchant_orders_updated_at on public.merchant_orders;
create trigger trg_touch_merchant_orders_updated_at
before update on public.merchant_orders
for each row
execute function public.touch_updated_at();


-- 5) Notifications for orders (DB-first; push can be layered via outbox)
create or replace function public.notify_merchant_order_created()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  owner_id uuid;
  merchant_name text;
begin
  select m.owner_profile_id, m.business_name into owner_id, merchant_name
  from public.merchants m
  where m.id = new.merchant_id;

  -- merchant owner
  if owner_id is not null then
    insert into public.user_notifications(user_id, kind, title, body, data)
    values (
      owner_id,
      'merchant_order_created',
      'New order received',
      'Order from customer' || case when merchant_name is not null then ' • ' || merchant_name else '' end,
      jsonb_build_object('order_id', new.id, 'merchant_id', new.merchant_id)
    );
  end if;

  -- customer
  insert into public.user_notifications(user_id, kind, title, body, data)
  values (
    new.customer_id,
    'merchant_order_created',
    'Order placed',
    case when merchant_name is not null then 'Your order was placed • ' || merchant_name else 'Your order was placed' end,
    jsonb_build_object('order_id', new.id, 'merchant_id', new.merchant_id)
  );

  return new;
end;
$$;

drop trigger if exists trg_notify_merchant_order_created on public.merchant_orders;
create trigger trg_notify_merchant_order_created
after insert on public.merchant_orders
for each row
execute function public.notify_merchant_order_created();


create or replace function public.notify_merchant_order_status_changed()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  owner_id uuid;
  merchant_name text;
begin
  if new.status is not distinct from old.status then
    return new;
  end if;

  select m.owner_profile_id, m.business_name into owner_id, merchant_name
  from public.merchants m
  where m.id = new.merchant_id;

  -- customer
  insert into public.user_notifications(user_id, kind, title, body, data)
  values (
    new.customer_id,
    'merchant_order_status',
    'Order status updated',
    'Status: ' || new.status || case when merchant_name is not null then ' • ' || merchant_name else '' end,
    jsonb_build_object('order_id', new.id, 'merchant_id', new.merchant_id, 'status', new.status)
  );

  -- merchant owner
  if owner_id is not null then
    insert into public.user_notifications(user_id, kind, title, body, data)
    values (
      owner_id,
      'merchant_order_status',
      'Order status updated',
      'Status: ' || new.status || case when merchant_name is not null then ' • ' || merchant_name else '' end,
      jsonb_build_object('order_id', new.id, 'merchant_id', new.merchant_id, 'status', new.status)
    );
  end if;

  return new;
end;
$$;

drop trigger if exists trg_notify_merchant_order_status_changed on public.merchant_orders;
create trigger trg_notify_merchant_order_status_changed
after update of status on public.merchant_orders
for each row
execute function public.notify_merchant_order_status_changed();


-- 6) Realtime (optional): allow clients to subscribe to order changes.
-- Note: enabling Postgres Changes replication is required for supabase_realtime.
do $$
begin
  begin
    alter publication supabase_realtime add table only public.merchant_orders;
  exception when duplicate_object then
    null;
  end;

  begin
    alter publication supabase_realtime add table only public.merchant_order_items;
  exception when duplicate_object then
    null;
  end;
end;
$$;

commit;
