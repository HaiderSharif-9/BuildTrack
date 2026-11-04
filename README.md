# BuildTrack

**Construction management app for Care Constructiona Pvt Ltd, Multan, Pakistan.**

BuildTrack is a Flutter + Supabase app for managing construction sites, labour, attendance, payroll, material purchases and project finances. It uses Riverpod for state management, GoRouter for navigation, and an English/Urdu interface with RTL support.

## Current implementation

### Core modules
- Authentication, forced password change and role-aware navigation
- Dashboard with site and financial summaries
- Sites, clients, suppliers and labour management
- Daily attendance with time entries, overtime and wage calculation
- Weekly payroll with advances and payment recording
- Material purchases and automatic expense ledger entries
- Financial ledger and basic site profitability reports
- Team account creation through an admin-only Supabase Edge Function

### Technical foundation
- Flutter / Dart
- Supabase Auth, PostgreSQL and Row Level Security
- Riverpod and GoRouter
- Decimal-based money calculations
- English and Urdu localization

## Important project status

The app has passed a local Flutter analyzer run with **0 errors** (19 informational lint suggestions remained at that point), and the debug app was launched on a TECNO BG7.

The latest backend and UI corrections on the `buildtrack-completion` branch still require local pull-and-retest. In particular, apply migration `008_complete_rls_and_attendance_payroll.sql` and deploy the `admin-create-user` Edge Function before testing the corresponding Supabase features.

**Do not treat this branch as production-ready until the database migration, Edge Function, full test suite, role-based access and real CRUD flows have been verified against the target Supabase project.**

## Supabase setup

1. Configure the Flutter app with your Supabase project URL and anon/publishable key using the existing local environment setup. Never put a service-role key in the Flutter app.
2. Ensure migrations `001` through `007` have already been applied.
3. Apply migrations `008_complete_rls_and_attendance_payroll.sql` and `009_dashboard_reporting_functions.sql`, in that order, to the same Supabase project. If using the Supabase CLI with the project linked, run `supabase db push`; otherwise run each pending migration in order through the Supabase SQL Editor.
4. Bootstrap the first administrator once. First create the intended admin account through the app's initial sign-up flow, then run this in the Supabase SQL Editor, replacing the email with that exact account:

   ```sql
   UPDATE public.profiles
   SET role = 'admin'::user_role,
       active = TRUE
   WHERE id = (
     SELECT id FROM auth.users
     WHERE lower(email) = lower('your-admin-email@example.com')
   )
   AND deleted_at IS NULL;
   ```

   Verify that the account is now an active administrator before creating other team accounts. Do not use this query to promote an account supplied by someone else.
5. Deploy the secure user-creation function:

   ```bash
   supabase functions deploy admin-create-user
   ```

   The function uses Supabase's server-side environment variables. Keep the service-role key inside the Supabase Edge Function environment only; never commit it or expose it to the client.

6. Confirm that at least one active administrator profile exists before using Team & Users.

## Local development

```bash
git clone https://github.com/HaiderSharif-9/BuildTrack.git
cd BuildTrack
flutter pub get
flutter analyze
flutter test
flutter run
```

## Quality checks

A GitHub Actions workflow at `.github/workflows/flutter-ci.yml` runs `flutter analyze` and `flutter test` on pushes to `master` and `buildtrack-completion`, and on pull requests targeting `master`.

## Known scope / not yet included

- Full offline-first synchronization
- PDF/Excel report export
- Production Android signing and release distribution
- End-to-end Supabase integration tests and full role-by-role security verification

## Wage calculation

The app uses a 10-hour standard day and 1.5x overtime by default. The server-side attendance trigger is the authoritative wage calculation source.

Example at a daily rate of Rs. 1,200:
- 08:00–18:00 (10 hours): Rs. 1,200
- 08:00–20:00 (12 hours): Rs. 1,560
- Absent or leave: Rs. 0

## Repository

https://github.com/HaiderSharif-9/BuildTrack
