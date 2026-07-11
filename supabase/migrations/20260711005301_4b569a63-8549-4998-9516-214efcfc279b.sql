REVOKE ALL ON public.admin_payment_settings FROM anon;
GRANT SELECT (id, self_serve_amount, done_for_you_first_amount, done_for_you_recurring_amount) ON public.admin_payment_settings TO anon;