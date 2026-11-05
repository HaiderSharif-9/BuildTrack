-- Harden callable privileges for helper and trigger-only functions.
-- Trigger functions are invoked by PostgreSQL triggers and do not need direct
-- EXECUTE grants for application roles.

ALTER FUNCTION public.app_role() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.app_role() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.app_role() TO authenticated;

ALTER FUNCTION public.clear_own_must_change_password() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.clear_own_must_change_password() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.clear_own_must_change_password() TO authenticated;

ALTER FUNCTION public.audit_trigger() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.audit_trigger() FROM PUBLIC, anon, authenticated;

ALTER FUNCTION public.compute_attendance_pay() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.compute_attendance_pay() FROM PUBLIC, anon, authenticated;

ALTER FUNCTION public.mark_period_paid() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.mark_period_paid() FROM PUBLIC, anon, authenticated;

ALTER FUNCTION public.sync_purchase_transaction() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.sync_purchase_transaction() FROM PUBLIC, anon, authenticated;

ALTER FUNCTION public.set_attendance_hours() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.set_attendance_hours() FROM PUBLIC, anon, authenticated;

ALTER FUNCTION public.update_attendance_updated_at() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.update_attendance_updated_at() FROM PUBLIC, anon, authenticated;

ALTER FUNCTION public.update_purchases_updated_at() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.update_purchases_updated_at() FROM PUBLIC, anon, authenticated;

ALTER FUNCTION public.update_advances_updated_at() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.update_advances_updated_at() FROM PUBLIC, anon, authenticated;

ALTER FUNCTION public.update_profiles_updated_at() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.update_profiles_updated_at() FROM PUBLIC, anon, authenticated;

ALTER FUNCTION public.create_profile_on_signup() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.create_profile_on_signup() FROM PUBLIC, anon, authenticated;

ALTER FUNCTION public.update_projects_updated_at() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.update_projects_updated_at() FROM PUBLIC, anon, authenticated;

ALTER FUNCTION public.update_labour_updated_at() SET search_path = public, pg_temp;
REVOKE ALL ON FUNCTION public.update_labour_updated_at() FROM PUBLIC, anon, authenticated;
