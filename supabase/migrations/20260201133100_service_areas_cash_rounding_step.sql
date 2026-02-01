-- Service-area configurable cash rounding step (IQD)
-- Iraq is primarily cash; rounding-to-step is a UX + operational requirement.

alter table public.service_areas
  add column if not exists cash_rounding_step_iqd integer not null default 250;

-- Basic sanity check (allow 1 for fully exact pricing, but typical is >= 250).
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'service_areas_cash_rounding_step_check'
  ) then
    alter table public.service_areas
      add constraint service_areas_cash_rounding_step_check
      check (cash_rounding_step_iqd >= 1);
  end if;
end $$;
