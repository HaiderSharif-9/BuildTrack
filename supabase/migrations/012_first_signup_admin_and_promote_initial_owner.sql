-- Promote the sole existing first account and make the first-ever profile an admin.
-- Advisory lock serializes concurrent first signups.
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
  ELSE
    assigned_role := 'manager';
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

DO $migration$
DECLARE
  auth_count bigint;
  profile_count bigint;
BEGIN
  SELECT count(*) INTO auth_count FROM auth.users;
  SELECT count(*) INTO profile_count FROM public.profiles;

  IF auth_count <> 1 OR profile_count <> 1 THEN
    RAISE EXCEPTION 'Safe first-admin promotion aborted: expected exactly one auth user and one profile; found % auth users and % profiles', auth_count, profile_count;
  END IF;

  UPDATE public.profiles
  SET role = 'admin', updated_at = now()
  WHERE id = (SELECT id FROM auth.users LIMIT 1);
END;
$migration$;
