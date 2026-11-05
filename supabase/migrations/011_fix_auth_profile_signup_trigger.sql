-- Allow the Supabase Auth service to create the matching profile row safely.
-- This function is invoked only by the auth.users INSERT trigger.
CREATE OR REPLACE FUNCTION public.create_profile_on_signup()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, login_id, role, active)
  VALUES (
    NEW.id,
    COALESCE(
      NULLIF(NEW.raw_user_meta_data->>'full_name', ''),
      NEW.email,
      NEW.phone,
      'New user'
    ),
    COALESCE(NEW.phone, NEW.email),
    'manager',
    TRUE
  );

  RETURN NEW;
END;
$$;

-- Trigger execution does not require application roles to call this function directly.
REVOKE ALL ON FUNCTION public.create_profile_on_signup() FROM PUBLIC, anon, authenticated;
