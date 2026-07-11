ALTER TABLE public.stores
  -- SEO
  ADD COLUMN IF NOT EXISTS meta_title TEXT,
  ADD COLUMN IF NOT EXISTS meta_description TEXT,
  ADD COLUMN IF NOT EXISTS favicon_url TEXT,
  ADD COLUMN IF NOT EXISTS og_image_url TEXT,
  ADD COLUMN IF NOT EXISTS tagline TEXT,
  -- Announcement bar
  ADD COLUMN IF NOT EXISTS announcement_enabled BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS announcement_text TEXT,
  -- Policy pages
  ADD COLUMN IF NOT EXISTS footer_return_text TEXT,
  ADD COLUMN IF NOT EXISTS footer_return_url TEXT,
  ADD COLUMN IF NOT EXISTS footer_privacy_text TEXT,
  ADD COLUMN IF NOT EXISTS footer_privacy_url TEXT,
  -- Payment methods
  ADD COLUMN IF NOT EXISTS payment_cod_enabled BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS payment_bkash_enabled BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS payment_bkash_number TEXT,
  ADD COLUMN IF NOT EXISTS payment_nagad_enabled BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS payment_nagad_number TEXT,
  ADD COLUMN IF NOT EXISTS payment_rocket_enabled BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS payment_rocket_number TEXT,
  ADD COLUMN IF NOT EXISTS payment_instructions TEXT,
  -- Delivery zones (array of {name, charge}) — falls back to inside/outside Dhaka when empty
  ADD COLUMN IF NOT EXISTS delivery_zones JSONB NOT NULL DEFAULT '[]'::jsonb,
  -- Business hours + holiday
  ADD COLUMN IF NOT EXISTS business_hours TEXT,
  ADD COLUMN IF NOT EXISTS business_days TEXT,
  ADD COLUMN IF NOT EXISTS holiday_mode BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS holiday_message TEXT,
  -- Minimum order
  ADD COLUMN IF NOT EXISTS min_order_amount NUMERIC NOT NULL DEFAULT 0,
  -- Social
  ADD COLUMN IF NOT EXISTS instagram_url TEXT,
  ADD COLUMN IF NOT EXISTS youtube_url TEXT,
  ADD COLUMN IF NOT EXISTS tiktok_url TEXT,
  ADD COLUMN IF NOT EXISTS whatsapp_channel_url TEXT,
  -- Brand
  ADD COLUMN IF NOT EXISTS brand_primary_color TEXT;