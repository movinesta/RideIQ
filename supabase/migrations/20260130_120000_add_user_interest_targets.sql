-- Add: user interest targets (for push + in-app personalization)
-- Supports: merchant, product, category, keyword

CREATE TABLE IF NOT EXISTS public.user_interest_targets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    kind text NOT NULL,
    merchant_id uuid,
    product_id uuid,
    category text,
    keyword text,
    enabled boolean DEFAULT true NOT NULL,
    notify_push boolean DEFAULT true NOT NULL,
    notify_inapp boolean DEFAULT true NOT NULL,
    max_per_week integer DEFAULT 2 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_interest_targets_pkey PRIMARY KEY (id),
    CONSTRAINT user_interest_targets_kind_check CHECK (kind = ANY (ARRAY['merchant'::text,'product'::text,'category'::text,'keyword'::text])),
    CONSTRAINT user_interest_targets_max_per_week_check CHECK (max_per_week >= 0),
    CONSTRAINT user_interest_targets_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE,
    CONSTRAINT user_interest_targets_merchant_id_fkey FOREIGN KEY (merchant_id) REFERENCES public.merchants(id) ON DELETE CASCADE,
    CONSTRAINT user_interest_targets_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.merchant_products(id) ON DELETE CASCADE
);

ALTER TABLE public.user_interest_targets ENABLE ROW LEVEL SECURITY;

-- Practical uniqueness: prevent duplicates per target type.
CREATE UNIQUE INDEX IF NOT EXISTS ux_interest_merchant ON public.user_interest_targets (user_id, merchant_id)
  WHERE (kind = 'merchant' AND merchant_id IS NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS ux_interest_product ON public.user_interest_targets (user_id, product_id)
  WHERE (kind = 'product' AND product_id IS NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS ux_interest_category ON public.user_interest_targets (user_id, lower(category))
  WHERE (kind = 'category' AND category IS NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS ux_interest_keyword ON public.user_interest_targets (user_id, lower(keyword))
  WHERE (kind = 'keyword' AND keyword IS NOT NULL);

CREATE INDEX IF NOT EXISTS ix_user_interest_targets_user_enabled ON public.user_interest_targets (user_id, enabled);
CREATE INDEX IF NOT EXISTS ix_user_interest_targets_kind_enabled ON public.user_interest_targets (kind, enabled);
CREATE INDEX IF NOT EXISTS ix_user_interest_targets_merchant ON public.user_interest_targets (merchant_id) WHERE (kind = 'merchant');
CREATE INDEX IF NOT EXISTS ix_user_interest_targets_product ON public.user_interest_targets (product_id) WHERE (kind = 'product');
CREATE INDEX IF NOT EXISTS ix_user_interest_targets_category ON public.user_interest_targets (category) WHERE (kind = 'category');
CREATE INDEX IF NOT EXISTS ix_user_interest_targets_keyword ON public.user_interest_targets (keyword) WHERE (kind = 'keyword');

-- Policies (drop + recreate to be idempotent)
DROP POLICY IF EXISTS user_interest_targets_select_own ON public.user_interest_targets;
DROP POLICY IF EXISTS user_interest_targets_insert_own ON public.user_interest_targets;
DROP POLICY IF EXISTS user_interest_targets_update_own ON public.user_interest_targets;
DROP POLICY IF EXISTS user_interest_targets_delete_own ON public.user_interest_targets;

CREATE POLICY user_interest_targets_select_own ON public.user_interest_targets
  FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY user_interest_targets_insert_own ON public.user_interest_targets
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY user_interest_targets_update_own ON public.user_interest_targets
  FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY user_interest_targets_delete_own ON public.user_interest_targets
  FOR DELETE TO authenticated USING (auth.uid() = user_id);

-- Table privileges (RLS still applies)
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_interest_targets TO authenticated;
