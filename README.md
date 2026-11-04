# BuildTrack

**Construction management app for Care Constructiona Pvt Ltd, Multan, Pakistan.**

BuildTrack is a Flutter + Supabase app for managing construction sites, labour, attendance, payroll, material purchases and project finances. It uses Riverpod for state management, GoRouter for navigation, and an English/Urdu interface with RTL support.

## Implemented modules

- Authentication, forced password change and role-aware navigation
- Live dashboard totals, date/site filters, income/expense chart, site summaries and recent ledger activity
- Sites, clients and suppliers
- Labour roster with create, edit, archive and site assignment
- Daily attendance with time entries, saved overtime and server-side wage calculation
- Weekly payroll with site selection, advances and payment recording
- Material purchases with database-generated Materials ledger entries
- Financial ledger and basic site profitability reports
- Admin-only team account creation with manager-to-site assignment

## Technical foundation

- Flutter / Dart
- Supabase Auth, PostgreSQL and Row Level Security
- Supabase Edge Functions for privileged account creation
- Riverpod and GoRouter
- Decimal-based money calculations
- English and Urdu localization

## Current quality status

The `buildtrack-completion` branch has a GitHub Actions workflow that runs `flutter analyze`, `flutter test` and a Deno type-check of the admin Edge Function. Recent runs have passed after the analyzer cleanup. The developer also reported a successful debug launch on a TECNO BG7.

The newest dashboard, payroll, security and labour changes still need a local pull-and-retest and live Supabase verification. **Do not treat this branch as production-ready until migrations 008 and 009 are applied, the `admin-create-user` Edge Function is deployed, and the real CRUD and role checks below pass.**

## Supabase setup

1. Configure the Flutter app with your Supabase project URL and anon/publishable key using the existing local environment setup. Never put a service-role key in the Flutter app.
2. Ensure migrations `001` through `007` have already been applied.
3. Apply `supabase/migrations/008_complete_rls_and_attendance_payroll.sql`.
4. Apply `supabase/migrations/009_dashboard_reporting_functions.sql`.
5. Deploy the secure user-creation function:

   ```bash
   supabase functions deploy admin-create-user
   ```

   The function uses Supabase's server-side environment variables. Keep the service-role key inside the Supabase Edge Function environment only; never commit it or expose it to the client.

6. If this is a fresh Supabase project, create the first account from Supabase Dashboard → Authentication → Users, then promote that account's profile from the SQL Editor (replace the email):

   ```sql
   UPDATE public.profiles
   SET role = 'admin', active = TRUE, must_change_password = FALSE
   WHERE id = (
     SELECT id FROM auth.users WHERE email = 'your-admin-email@example.com'
   );
   ```

   Confirm that exactly one profile was updated. After the first administrator is ready, disable public sign-ups in Supabase Auth settings if this is a private company app.

7. Confirm that at least one active administrator profile exists before using Team & Users.

## Local development

```bash
git clone https://github.com/HaiderSharif-9/BuildTrack.git
cd BuildTrack
flutter pub get
flutter analyze
flutter test
flutter run
```

## Automated checks

The workflow at `.github/workflows/flutter-ci.yml` runs `flutter analyze` and `flutter test` on pushes to `master` and `buildtrack-completion`, and on pull requests targeting `master`.

APK builds are deliberately manual or version-tag triggered through `.github/workflows/build-apk.yml`; release signing and distribution remain separate final tasks.

## Known remaining work

- Apply migrations 008 and 009 to the live Supabase project and deploy the Edge Function.
- Complete live end-to-end testing for each role and every CRUD flow.
- Persist language/theme preferences between app launches.
- Add user deactivation/role-edit screens and multi-site manager assignment UI.
- Full offline-first synchronization.
- PDF/Excel report export.
- Production Android signing and release distribution.

## Wage calculation

The default standard day is 10 hours and overtime is 1.5x. The server-side attendance trigger is the authoritative wage calculation source.

Example at a daily rate of Rs. 1,200:
- 08:00–18:00 (10 hours): Rs. 1,200
- 08:00–20:00 (12 hours): Rs. 1,560
- Absent or leave: Rs. 0

## Repository

https://github.com/HaiderSharif-9/BuildTrack
