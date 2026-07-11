REVOKE EXECUTE ON FUNCTION public.apply_approved_subscription_payment() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.apply_approved_subscription_payment() FROM anon;
REVOKE EXECUTE ON FUNCTION public.apply_approved_subscription_payment() FROM authenticated;

REVOKE EXECUTE ON FUNCTION public.grant_super_admin_by_email() FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.grant_super_admin_by_email() FROM anon;
REVOKE EXECUTE ON FUNCTION public.grant_super_admin_by_email() FROM authenticated;

REVOKE EXECUTE ON FUNCTION public.has_role(UUID, app_role) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION public.has_role(UUID, app_role) FROM anon;
GRANT EXECUTE ON FUNCTION public.has_role(UUID, app_role) TO authenticated;