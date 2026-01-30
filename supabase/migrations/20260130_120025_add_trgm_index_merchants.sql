-- Add: trigram index to speed up merchant name search
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA extensions;
CREATE INDEX IF NOT EXISTS ix_merchants_business_name_trgm
  ON public.merchants USING gin (business_name extensions.gin_trgm_ops);
