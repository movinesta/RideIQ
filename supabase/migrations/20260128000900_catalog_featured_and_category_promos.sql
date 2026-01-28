-- P14: Catalog improvements (minimal schema changes)
--
-- Goals
-- - Featured products flag for merchandising
-- - Category-wide promotions (reuse merchant_products.category; no new tables)
-- - Search acceleration indexes (pg_trgm) for name/description
-- - Update merchant_best_promo to consider category scope

begin;

-- 1) Featured products
alter table public.merchant_products
  add column if not exists is_featured boolean not null default false;

-- Lightweight merchandising queries (only true values)
create index if not exists ix_merchant_products_merchant_featured
  on public.merchant_products(merchant_id, is_featured)
  where is_featured = true;

-- Sort/pagination helpers (supports stable ordering, keyset-ready)
create index if not exists ix_merchant_products_merchant_active_created_id_desc
  on public.merchant_products(merchant_id, is_active, created_at desc, id desc);

create index if not exists ix_merchant_products_merchant_active_price_id
  on public.merchant_products(merchant_id, is_active, price_iqd, id);

-- 2) Search acceleration for ILIKE / partial match
create extension if not exists pg_trgm with schema extensions;

create index if not exists ix_merchant_products_name_trgm
  on public.merchant_products using gin (name gin_trgm_ops);

create index if not exists ix_merchant_products_description_trgm
  on public.merchant_products using gin (description gin_trgm_ops);

-- 3) Category-wide promotions (keeps existing product_id + merchant-wide semantics)
alter table public.merchant_promotions
  add column if not exists category text;

alter table public.merchant_promotions
  drop constraint if exists merchant_promotions_scope_check;

alter table public.merchant_promotions
  add constraint merchant_promotions_scope_check
  check (
    not (product_id is not null and category is not null)
    and (category is null or length(btrim(category)) > 0)
  );

create index if not exists ix_merchant_promotions_category_active
  on public.merchant_promotions(merchant_id, category, is_active)
  where category is not null;

-- 4) Update best promo picker to consider category scope.
-- Scopes supported:
-- - merchant-wide: product_id is null AND category is null
-- - product-specific: product_id = p_product_id
-- - category-specific: category = merchant_products.category for that product
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
  v_category text;
begin
  select category into v_category
  from public.merchant_products
  where id = p_product_id and merchant_id = p_merchant_id;

  for r in
    select id, discount_type, value
    from public.merchant_promotions
    where merchant_id = p_merchant_id
      and is_active = true
      and (starts_at is null or starts_at <= now_ts)
      and (ends_at is null or ends_at >= now_ts)
      and (
        (product_id is null and category is null)
        or (product_id = p_product_id)
        or (category is not null and v_category is not null and category = v_category)
      )
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

commit;
