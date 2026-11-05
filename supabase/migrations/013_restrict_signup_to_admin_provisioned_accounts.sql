-- Public signup is only allowed to create the very first administrator.
-- Additional staff profiles must be provisioned by the authenticated admin Edge Function,
-- which sets this protected app_metadata marker using the service-role Admin API.
CREATE OR REPLACE FUNCTION public.create_profile_on_signup()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  assigned_role text;
BEGIN
  PERFORM pg_advisory_xact_lock(731904, 1);

  IF NOT EXISTS (SELECT 1 FROM public.profiles) THEN
    assigned_role := 'admin';
  ELSIF COALESCE(NEW.raw_app_meta_data->>'provisioned_by_admin', 'false') = 'true' THEN
    assigned_role := 'manager';
  ELSE
    RAISE EXCEPTION 'Public registration is closed. Ask your BuildTrack administrator for an account.';
  END IF;

  INSERT INTO public.profiles (id, full_name, login_id, role, active)
  VALUES (
    NEW.id,
    COALESCE(NULLIF(NEW.raw_user_meta_data->>'full_name', ''), NEW.email, NEW.phone, 'New user'),
    COALESCE(NEW.phone, NEW.email),
    assigned_role,
    TRUE
  );

  RETURN NEW;
END;
$function$;

REVOKE ALL ON FUNCTION public.create_profile_on_signup() FROM PUBLIC, anon, authenticated;
