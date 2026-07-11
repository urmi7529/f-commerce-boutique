
-- 1. Move domain_verification_token off the publicly-readable stores table
CREATE TABLE IF NOT EXISTS public.store_domain_verifications (
  store_id uuid PRIMARY KEY REFERENCES public.stores(id) ON DELETE CASCADE,
  token text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.store_domain_verifications TO authenticated;
GRANT ALL ON public.store_domain_verifications TO service_role;

ALTER TABLE public.store_domain_verifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owners manage their domain verification token"
  ON public.store_domain_verifications
  FOR ALL
  TO authenticated
  USING (EXISTS (SELECT 1 FROM public.stores s WHERE s.id = store_id AND s.owner_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.stores s WHERE s.id = store_id AND s.owner_id = auth.uid()));

CREATE TRIGGER store_domain_verifications_set_updated_at
  BEFORE UPDATE ON public.store_domain_verifications
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

INSERT INTO public.store_domain_verifications (store_id, token)
SELECT id, domain_verification_token
FROM public.stores
WHERE domain_verification_token IS NOT NULL
ON CONFLICT (store_id) DO NOTHING;

ALTER TABLE public.stores DROP COLUMN IF EXISTS domain_verification_token;

-- 2. Remove paid-file download URLs from public products table
ALTER TABLE public.products DROP COLUMN IF EXISTS download_url;

-- 3. Scope authenticated-read on admin_payment_settings so it isn't USING(true)
DROP POLICY IF EXISTS "Authenticated read admin payment settings" ON public.admin_payment_settings;

CREATE POLICY "Authenticated read admin payment settings"
  ON public.admin_payment_settings
  FOR SELECT
  TO authenticated
  USING (id = 'default');

-- 4. Scope public order insert so WITH CHECK isn't just `true`
DROP POLICY IF EXISTS "orders public insert" ON public.orders;

CREATE POLICY "orders public insert"
  ON public.orders
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (EXISTS (SELECT 1 FROM public.stores s WHERE s.id = store_id));

-- 5. Prevent anon / signed-in users from directly executing internal SECURITY DEFINER trigger helpers
REVOKE EXECUTE ON FUNCTION public.apply_approved_subscription_payment() FROM anon, authenticated, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.grant_super_admin_by_email() FROM anon, authenticated, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM anon, authenticated, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.send_welcome_message_on_approval() FROM anon, authenticated, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.set_updated_at() FROM anon, authenticated, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.mark_store_message_seen_at() FROM anon, authenticated, PUBLIC;
