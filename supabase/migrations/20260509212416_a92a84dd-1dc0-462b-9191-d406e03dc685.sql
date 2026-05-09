ALTER TABLE public.stores 
  ADD COLUMN IF NOT EXISTS banner_url text,
  ADD COLUMN IF NOT EXISTS banner_enabled boolean NOT NULL DEFAULT true;