-- Add: promotion_notification_receipts (idempotency for promo notifications)
CREATE TABLE IF NOT EXISTS public.promotion_notification_receipts (
    promotion_id uuid NOT NULL,
    user_id uuid NOT NULL,
    notification_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT promotion_notification_receipts_pkey PRIMARY KEY (promotion_id, user_id),
    CONSTRAINT promotion_notification_receipts_promotion_id_fkey FOREIGN KEY (promotion_id) REFERENCES public.merchant_promotions(id) ON DELETE CASCADE,
    CONSTRAINT promotion_notification_receipts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE,
    CONSTRAINT promotion_notification_receipts_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.user_notifications(id) ON DELETE SET NULL
);

ALTER TABLE public.promotion_notification_receipts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS promotion_notification_receipts_select_own ON public.promotion_notification_receipts;
CREATE POLICY promotion_notification_receipts_select_own ON public.promotion_notification_receipts
  FOR SELECT TO authenticated USING (auth.uid() = user_id);

GRANT SELECT ON public.promotion_notification_receipts TO authenticated;
