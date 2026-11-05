# Architecture Overview

## Application architecture

BuildTrack uses a feature-oriented Flutter structure. The app entry point initializes Supabase and starts the Riverpod provider scope. GoRouter manages navigation, while feature-specific providers and repositories load and update backend data.

```text
Flutter UI
   │
   ├── Screens and reusable widgets
   │
   ├── Riverpod providers
   │
   └── Feature repositories
           │
           ▼
      Supabase Flutter client
           │
           ├── Supabase Auth
           ├── PostgreSQL
           │     └── Row Level Security policies
           └── Supabase Edge Functions
                 └── Privileged server-side operations
```

## Main code areas

| Directory | Responsibility |
| --- | --- |
| `lib/app/` | Application shell and route configuration |
| `lib/core/models/` | Shared data models and money types |
| `lib/core/repositories/` | Shared data access |
| `lib/core/services/` | Shared business logic |
| `lib/core/theme/` | Theme definitions |
| `lib/core/widgets/` | Reusable UI components |
| `lib/features/` | Feature-specific screens, providers and repositories |
| `lib/l10n/` | English and Urdu localization resources |
| `supabase/migrations/` | Database schema, functions, triggers and RLS policies |
| `supabase/functions/` | Server-side Edge Functions |
| `test/` | Automated Flutter tests |

## Data and access control

- Supabase Auth manages user identities and sessions.
- The `profiles` table stores application-level roles and account status.
- PostgreSQL Row Level Security policies enforce access to protected records.
- Site assignments connect Managers to the projects they are permitted to access.
- Financial and administrative actions are restricted according to the caller’s role.
- The `admin-create-user` Edge Function checks the caller’s identity and active Admin role before using server-side privileges to create a staff account.

The UI may hide unavailable actions for usability, but database policies and server-side checks are the security boundary.

## Money and payroll

Money values are represented with decimal-aware types in the Flutter application. Attendance and payroll calculations are supported by database-side functions and triggers so that important wage and ledger updates are not dependent only on client-side calculations.

Purchases and wage payments can create linked ledger transactions. Soft-delete and update behavior is handled by database logic to keep related financial records synchronized.

## Localization

The app includes English and Urdu localization resources. Urdu layouts use Flutter's text direction and localization support for right-to-left presentation.

## Automated quality checks

GitHub Actions runs:

1. Flutter dependency resolution.
2. `flutter analyze`.
3. `flutter test`.
4. Deno type-checking for `supabase/functions/admin-create-user/index.ts`.

These checks validate code quality and selected automated behavior. They do not run database migrations or verify a live Supabase deployment.
