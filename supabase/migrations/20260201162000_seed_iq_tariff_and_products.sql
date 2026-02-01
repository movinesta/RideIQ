-- Session 2
-- Seed baseline Iraq tariff + minimal ride products.
--
-- Note: Values are intended as an initial operating prior (adjust via admin UI).

-- Ensure there is at least one active default pricing config.
insert into public.pricing_configs (
  name, version, effective_from, effective_to, is_default,
  active, currency, base_fare_iqd, per_km_iqd, per_min_iqd, minimum_fare_iqd, max_surge_multiplier
)
select
  'Iraq default v1',
  1,
  now(),
  null,
  true,
  true,
  'IQD',
  1500,
  450,
  40,
  2000,
  1.8
where not exists (select 1 from public.pricing_configs);

-- Minimal product catalog (used for multipliers in quoting).
insert into public.ride_products (
  code, name, description, capacity_min, price_multiplier, sort_order, is_active
)
values
  ('standard', 'Standard', 'Default car class', 4, 1.000, 0, true),
  ('suv', 'SUV', 'Larger vehicle / higher operating cost', 4, 1.250, 1, true),
  ('premium', 'Premium', 'Higher comfort / newer vehicles', 4, 1.400, 2, true)
on conflict (code) do nothing;
