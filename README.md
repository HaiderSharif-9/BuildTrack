# BuildTrack

**A Flutter-based construction project management system**

BuildTrack helps construction teams manage sites, workforce, attendance, payroll, purchases and project finances from one application. It is built with Flutter and Supabase, with role-based access for administrators, accountants and site managers.

[![Flutter CI](https://github.com/HaiderSharif-9/BuildTrack/actions/workflows/flutter-ci.yml/badge.svg?branch=master)](https://github.com/HaiderSharif-9/BuildTrack/actions/workflows/flutter-ci.yml)

> **Project status:** Development and testing release. The primary source is the `master` branch. Automated checks cover static analysis, automated tests and Edge Function type-checking. Live role-by-role end-to-end verification and production release preparation remain outstanding.

## Project overview

Construction projects involve several connected activities: tracking sites, assigning labour, recording attendance, calculating wages, managing purchases and monitoring expenses. BuildTrack brings these workflows into a single role-aware application backed by a central database.

### Main modules

| Module | Purpose |
| --- | --- |
| Dashboard | View project summaries, financial totals, trends and recent activity |
| Sites | Create and manage construction sites, clients, budgets and project status |
| Labour | Maintain labour records, site assignments and wage-rate information |
| Attendance | Record daily attendance, work hours and overtime |
| Payroll | Calculate wages, record payments and track payment periods |
| Purchases | Record material purchases and link them to project expenses |
| Ledger | Review income and expenses recorded in the system |
| Reports | Review financial and site-level summaries |
| Team & Users | Allow administrators to provision staff accounts and assign managers to sites |
| Settings | Manage account and application preferences |

### User roles

- **Admin:** Manages the organization’s users and has access to administrative and financial workflows.
- **Accountant:** Handles financial records, purchases, payroll and related reporting.
- **Manager:** Works with assigned sites and operational information according to role permissions.

The login screen includes a **Create New Account** option for initial organization setup. The Supabase database trigger grants the Admin role only to the first profile when no profile exists. Once that first profile is created, public registration is blocked; additional staff accounts must be created by an authorized Admin through the server-side user-provisioning function. This restriction is enforced by the database, not only by hiding a UI option.

For a fresh Supabase project, follow the migration and initial-Admin bootstrap sequence in [Supabase Setup](docs/SUPABASE_SETUP.md) before using the app. The in-app first-account flow depends on the signup trigger and migrations being configured correctly.

## Technology stack

- **Frontend:** Flutter and Dart
- **Backend:** Supabase
- **Authentication:** Supabase Auth
- **Database:** PostgreSQL with Row Level Security (RLS)
- **State management:** Riverpod
- **Navigation:** GoRouter
- **Localization:** Flutter localization (English and Urdu)
- **Server-side operations:** Supabase Edge Functions (Deno)
- **Automated checks:** GitHub Actions, Flutter analyzer, Flutter tests and Deno type-checking

## Repository structure

```text
BuildTrack/
├── .github/
│   └── workflows/          # CI workflows
├── android/                # Android platform configuration
├── ios/                    # iOS platform configuration
├── lib/
│   ├── app/                # App shell and routing
│   ├── core/               # Shared models, repositories, services and UI
│   ├── features/           # Feature-based application modules
│   ├── l10n/               # English and Urdu localization
│   └── main.dart           # Application entry point
├── supabase/
│   ├── functions/           # Server-side Edge Functions
│   ├── migrations/          # Database schema, policies and functions
│   └── seed.sql             # Development seed data
├── test/                    # Automated tests
├── docs/                    # Project and setup documentation
├── analysis_options.yaml
└── pubspec.yaml
```

## Getting started

### Requirements

- Flutter SDK (the CI workflow currently uses Flutter **3.47.9**)
- Dart SDK compatible with the Flutter SDK
- Android Studio or another supported Flutter development environment
- A Supabase project
- Git

### 1. Clone the repository

```bash
git clone https://github.com/HaiderSharif-9/BuildTrack.git
cd BuildTrack
```

The submission-ready source is maintained on the default **`master`** branch.

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

The app reads its Supabase configuration from Dart compile-time environment values. Create a local file named `env.json` in the project root:

```json
{
  "SUPABASE_URL": "https://YOUR_PROJECT_ID.supabase.co",
  "SUPABASE_ANON_KEY": "YOUR_SUPABASE_PUBLISHABLE_OR_ANON_KEY"
}
```

Use your own Supabase project URL and publishable/anon key. The `env.json` file is ignored by Git and must never be committed. **Never place a Supabase service-role key in the Flutter application or this file.**

### 4. Set up the database

Database setup is documented in [Supabase Setup](docs/SUPABASE_SETUP.md). Apply migrations in numeric order and follow the documented one-time Admin bootstrap instructions for a fresh project. Do not rerun an already-applied bootstrap migration.

### 5. Run the app

Run in Chrome:

```bash
flutter run -d chrome --dart-define-from-file=env.json
```

Run on a connected Android device:

```bash
flutter run --dart-define-from-file=env.json
```

## Build an Android APK

### Requirements

- Flutter SDK installed and available on your PATH.
- Android SDK and Android build tools installed (Android Studio can install these).
- A configured Supabase project and a local `env.json` file as described above.
- Android licenses accepted (`flutter doctor --android-licenses`).

### Build a release-mode APK for testing

From the repository root, run:

```powershell
flutter doctor
flutter pub get
flutter build apk --release --dart-define-from-file=env.json
```

When the build completes, the APK is generated at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Transfer that APK to an Android phone and install it to test the app. Do not share an APK until the live Supabase configuration and role-based workflows have been tested.

### Important signing status

The current Android Gradle configuration uses the default **debug signing key** for the release build. This is suitable only for development/testing distribution. Before publishing or distributing a production release, create a private upload/release keystore, configure the release signing properties securely, and never commit the keystore or passwords to Git. See [Android APK Build Guide](docs/ANDROID_BUILD.md) for the full procedure.

## Development checks

Run these commands before submitting code changes:

```bash
flutter analyze
flutter test
```

The Flutter CI workflow runs the analyzer and automated tests. It also type-checks the `admin-create-user` Edge Function with Deno. These automated checks do not connect to the live Supabase database and do not replace manual end-to-end testing.

## Security notes

- Supabase Row Level Security policies enforce data access at the database layer.
- The administrator-only `admin-create-user` Edge Function verifies the caller’s authenticated session and active Admin role before creating staff accounts.
- The service-role key must remain in the Supabase server-side environment only.
- Local configuration files, signing keys and environment files are excluded through `.gitignore`.
- Do not commit real user data, credentials, API keys or production database exports.

## Roadmap and future enhancements

- Guided first-time organization setup and clearer deployment diagnostics.
- More complete user deactivation and role-management workflows.
- Expanded multi-site Manager assignment controls.
- Offline-first synchronization.
- PDF and Excel report exports.
- Production Android signing and store distribution.

These are future enhancements and must not be presented as already implemented.

## Current limitations

- First-Admin signup depends on the correct Supabase migrations and signup trigger being applied; verify it against the target project before demonstration.
- Full live end-to-end verification for all roles and CRUD workflows remains in progress.
- User deactivation and role-editing screens need further work.
- Multi-site Manager assignment needs further UI support.
- Offline-first synchronization is not implemented.
- PDF and Excel report exports are not implemented.
- Production Android release signing and store distribution remain pending. The documented APK command currently produces a debug-key-signed release-mode build for testing.

For a more detailed feature and verification checklist, see [QA Report](QA_REPORT.md). For the high-level design, see [Architecture Overview](docs/ARCHITECTURE.md).

## Author

**Developed by Haider Sharif**

- GitHub: [HaiderSharif-9](https://github.com/HaiderSharif-9)
- Repository: [BuildTrack](https://github.com/HaiderSharif-9/BuildTrack)

---

*BuildTrack — Construction project operations, organized in one place.*
