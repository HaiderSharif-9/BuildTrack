# BuildTrack QA Report

**Branch:** `buildtrack-completion`  
**Last reviewed:** 2026-11-05

## Automated verification

- GitHub Actions has passed `flutter analyze` and `flutter test` on recent branch commits after the analyzer cleanup.
- The dashboard replacement introduced four informational lint findings; those were corrected and the next run passed.
- The developer reported that the debug app launched on a TECNO BG7 before the latest dashboard and backend changes.

The latest branch head still needs its own CI result and a local device retest after pulling.

## Changes added to this branch

- Resolved the original feature-module analyzer errors and cleaned informational lints.
- Added migration 008 for missing CRUD RLS policies, persisted attendance overtime, wage-payment ledger synchronization, purchase ledger soft-delete synchronization and the safe self-service password-change RPC.
- Added migration 009 with RLS-aware dashboard summary, daily trend and site totals functions.
- Replaced dashboard mock values and placeholder charts/activity with live Supabase-backed data and functional period/site filters.
- Added an admin-only `admin-create-user` Edge Function that creates a real Auth account and assigns manager accounts to a selected site.
- Added labour creation, editing, archiving and site assignment.
- Added site-specific wage-rate calculations, site-required payroll recording and role-based finance visibility.
- Added GitHub Actions for Flutter analyze and unit tests; made APK builds manual or version-tag triggered.

## Required live Supabase verification

### Database and authentication
- [ ] Confirm migrations 001–007 are applied.
- [ ] Apply migration 008.
- [ ] Apply migration 009.
- [ ] Deploy `admin-create-user`.
- [ ] Verify an active admin can create a manager and assign that manager to a site.
- [ ] Verify accountant/admin can create users and non-admin callers receive HTTP 403.
- [ ] Verify a created user can sign in and is forced to change the temporary password.
- [ ] Verify completing password change clears the forced-change flag.

### Role and site access
- [ ] Manager sees only assigned sites and labourers.
- [ ] Manager does not see the Money tab, financial reports, wage rates, wage totals or transaction details.
- [ ] Accountant/admin can access dashboard finance, payroll, ledger and reports.
- [ ] Direct navigation to restricted routes redirects to a safe route.

### Functional tests
- [ ] Dashboard totals, chart, site filter, date periods and recent activity match known transaction data.
- [ ] Create, edit and archive a labourer; verify a private wage-rate row and site assignment are created.
- [ ] Mark attendance, save, refresh and confirm status/time/overtime persist.
- [ ] Verify server-calculated full-day, half-day and overtime wages.
- [ ] Record a payroll payment for a selected site; verify attendance locks and exactly one net wage ledger transaction is created.
- [ ] Soft-delete a payroll payment; verify attendance unlocks and its ledger entry is soft-deleted.
- [ ] Create, edit and soft-delete a purchase; verify exactly one linked Materials transaction exists and is removed from active totals after deletion.
- [ ] Verify ledger totals and site profitability against known sample records.
- [ ] Test English and Urdu layouts, including RTL navigation.

### Automated and device checks
- [ ] Confirm GitHub Actions passes on the latest branch head.
- [ ] Pull the latest branch locally and run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Run the latest debug build on the TECNO BG7 and test the flows above.

## Known limitations

- Language and theme selections are currently session-only.
- User deactivation/role editing and multi-site manager assignment UI are not complete.
- Offline-first synchronization is not implemented.
- PDF/Excel exports are not implemented.
- APK signing and release distribution remain pending.
- Live Supabase end-to-end testing has not yet been completed.

## Release decision

**Not yet production-ready.** The automated Flutter checks have passed on recent commits, but database migrations, Edge Function deployment, live RLS behavior, dashboard aggregates and full end-to-end flows still need verification.
