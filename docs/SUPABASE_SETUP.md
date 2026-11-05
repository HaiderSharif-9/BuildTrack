# Supabase Setup Guide

This guide describes how to connect BuildTrack to a Supabase project. Perform the setup in a development project first. Do not use production data while learning the deployment process.

## 1. Create a Supabase project

Create a project in the Supabase dashboard and keep its project URL and publishable/anon key available for local development.

The Flutter client requires only the project URL and publishable/anon key. **Never put the service-role key in Flutter code, `env.json`, screenshots or Git.**

## 2. Apply database migrations in order

The SQL files are in `supabase/migrations/`. Apply migrations `001` through `011` in numeric order using the Supabase SQL Editor or your established migration workflow.

### Important: initial Admin bootstrap

Migration `012_first_signup_admin_and_promote_initial_owner.sql` is a one-time bootstrap migration. It deliberately stops unless there is exactly one Auth user and exactly one matching profile.

For a fresh project:

1. Apply migrations `001` through `011`.
2. Create the first Auth user in Supabase Dashboard → Authentication → Users. Provide the user's full name in user metadata if creating the user through an API.
3. Confirm the signup trigger created exactly one row in `public.profiles`.
4. Apply migration `012_first_signup_admin_and_promote_initial_owner.sql`. It promotes that initial account to Admin.
5. Apply migrations `013_restrict_signup_to_admin_provisioned_accounts.sql` and `014_fix_money_transaction_upserts.sql`.

Do not rerun migration `012` on a database that already has its migration recorded or that contains more than one Auth user/profile. For an existing deployment, check the migration history and current Admin profile before making changes.

The app currently displays the Login screen. The initial Admin is provisioned during backend setup; an in-app first-run setup wizard is planned as a future enhancement.

## 3. Configure the Edge Function

The administrator user-provisioning function is located at:

`supabase/functions/admin-create-user/index.ts`

Deploy it using the Supabase CLI:

```bash
supabase functions deploy admin-create-user
```

Ensure the function environment has the Supabase URL, anon key and service-role key expected by the function. Keep the service-role key server-side only. Never add it to Flutter compile-time variables or commit it to this repository.

The function checks the caller's authenticated session and verifies that the caller has an active Admin profile before creating a staff account.

## 4. Configure the Flutter app

Create `env.json` in the repository root:

```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT_ID.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY"
}
```

Run the application:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=env.json
```

The `env.json` file is listed in `.gitignore`. Do not remove that protection or commit real project credentials.

## 5. Verify the setup

- [ ] Confirm the initial Admin can sign in.
- [ ] Confirm the profile role is `admin` and the account is active.
- [ ] Confirm the Edge Function is deployed and can be invoked by the Admin.
- [ ] Confirm non-Admin users cannot provision staff accounts.
- [ ] Confirm a newly provisioned Manager is assigned only to the intended site.
- [ ] Confirm temporary-password change is required on first sign-in.
- [ ] Confirm RLS prevents access to data outside the user's role and site assignments.

## Troubleshooting notes

- **Login fails:** Confirm the Auth user exists, the password is correct and the matching profile is active.
- **Profile missing:** Check whether the Auth signup trigger and migrations were applied successfully.
- **Admin setup migration stops:** Check the exact Auth user and profile counts before applying migration `012`; do not bypass its safety check.
- **Staff account creation fails:** Confirm the Edge Function is deployed, its environment variables are configured and the caller has an active Admin profile.
- **Data is missing:** Check the relevant RLS policy and the signed-in user's role/site assignment. Do not disable RLS as a workaround.
