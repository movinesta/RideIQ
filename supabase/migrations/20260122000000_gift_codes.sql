-- Gift codes for wallet credits
CREATE TABLE IF NOT EXISTS public.gift_codes (
  code text PRIMARY KEY,
  amount_iqd bigint NOT NULL CHECK (amount_iqd > 0),
  memo text,
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  redeemed_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  redeemed_at timestamptz,
  redeemed_entry_id bigint REFERENCES public.wallet_entries(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS ix_gift_codes_created_at ON public.gift_codes(created_at DESC);
CREATE INDEX IF NOT EXISTS ix_gift_codes_redeemed_by ON public.gift_codes(redeemed_by, redeemed_at DESC);

ALTER TABLE public.gift_codes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "gift_codes_select_admin_or_redeemer" ON public.gift_codes;
CREATE POLICY "gift_codes_select_admin_or_redeemer"
ON public.gift_codes FOR SELECT
TO authenticated
USING (public.is_admin() OR redeemed_by = auth.uid());

DROP POLICY IF EXISTS "gift_codes_admin_insert" ON public.gift_codes;
CREATE POLICY "gift_codes_admin_insert"
ON public.gift_codes FOR INSERT
TO authenticated
WITH CHECK (public.is_admin());

DROP POLICY IF EXISTS "gift_codes_admin_update" ON public.gift_codes;
CREATE POLICY "gift_codes_admin_update"
ON public.gift_codes FOR UPDATE
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE OR REPLACE FUNCTION public.admin_create_gift_code(
  p_amount_iqd bigint,
  p_code text DEFAULT NULL,
  p_memo text DEFAULT NULL
)
RETURNS public.gift_codes
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_code text;
  v_row public.gift_codes;
  v_memo text;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not_admin' USING errcode = '42501';
  END IF;

  IF p_amount_iqd IS NULL OR p_amount_iqd <= 0 THEN
    RAISE EXCEPTION 'invalid_amount';
  END IF;

  v_code := upper(trim(coalesce(p_code, '')));
  v_memo := nullif(trim(coalesce(p_memo, '')), '');

  IF v_code = '' THEN
    v_code := upper(encode(gen_random_bytes(6), 'hex'));
  END IF;

  LOOP
    BEGIN
      INSERT INTO public.gift_codes (code, amount_iqd, memo, created_by)
      VALUES (v_code, p_amount_iqd, v_memo, auth.uid())
      RETURNING * INTO v_row;
      EXIT;
    EXCEPTION WHEN unique_violation THEN
      IF p_code IS NOT NULL AND trim(p_code) <> '' THEN
        RAISE EXCEPTION 'gift_code_exists';
      END IF;
      v_code := upper(encode(gen_random_bytes(6), 'hex'));
    END;
  END LOOP;

  RETURN v_row;
END;
$$;

REVOKE ALL ON FUNCTION public.admin_create_gift_code(bigint, text, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_create_gift_code(bigint, text, text) TO authenticated;

CREATE OR REPLACE FUNCTION public.redeem_gift_code(p_code text)
RETURNS public.gift_codes
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid;
  v_code text;
  v_gift public.gift_codes;
  v_entry_id bigint;
  v_memo text;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  v_code := upper(trim(coalesce(p_code, '')));
  IF v_code = '' THEN
    RAISE EXCEPTION 'missing_code';
  END IF;

  SELECT * INTO v_gift
  FROM public.gift_codes
  WHERE code = v_code
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'gift_code_not_found' USING errcode = 'P0002';
  END IF;

  IF v_gift.redeemed_at IS NOT NULL THEN
    RAISE EXCEPTION 'gift_code_already_redeemed';
  END IF;

  INSERT INTO public.wallet_accounts(user_id)
  VALUES (v_uid)
  ON CONFLICT (user_id) DO NOTHING;

  v_memo := coalesce(v_gift.memo, 'Gift code');

  UPDATE public.wallet_accounts
  SET balance_iqd = balance_iqd + v_gift.amount_iqd
  WHERE user_id = v_uid;

  INSERT INTO public.wallet_entries (user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
  VALUES (
    v_uid,
    v_gift.amount_iqd,
    'adjustment',
    v_memo,
    'gift_code',
    NULL,
    jsonb_build_object('code', v_code, 'amount_iqd', v_gift.amount_iqd),
    'gift_code:' || v_code
  )
  RETURNING id INTO v_entry_id;

  UPDATE public.gift_codes
  SET redeemed_by = v_uid,
      redeemed_at = now(),
      redeemed_entry_id = v_entry_id
  WHERE code = v_code
  RETURNING * INTO v_gift;

  RETURN v_gift;
END;
$$;

REVOKE ALL ON FUNCTION public.redeem_gift_code(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.redeem_gift_code(text) TO authenticated;
