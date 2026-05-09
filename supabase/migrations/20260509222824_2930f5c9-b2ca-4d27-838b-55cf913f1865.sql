
ALTER TABLE public.stores
  ADD COLUMN IF NOT EXISTS custom_domain text UNIQUE,
  ADD COLUMN IF NOT EXISTS domain_verified boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS domain_verification_token text;

CREATE INDEX IF NOT EXISTS stores_custom_domain_idx ON public.stores (custom_domain) WHERE custom_domain IS NOT NULL;
