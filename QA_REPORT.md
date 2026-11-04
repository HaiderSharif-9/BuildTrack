# BuildTrack QA Report

**Branch:** `buildtrack-completion`  
**Last reviewed:** 2026-11-05

## Verified locally (reported by developer)

- Flutter stable 3.47.9 dependency resolution completed.
- `flutter analyze` reported **0 errors**, with 19 informational lint suggestions.
- The debug app was launched on the TECNO BG7 before the latest backend and UI commits in this branch.

The latest GitHub commits must be pulled and rechecked locally before treating those results as verification of the current branch head.

## Changes added to this branch

- Resolved the analyzer errors found in the new feature modules.
- Added database migration 008 for missing CRUD RLS policies and persisted attendance overtime.
- Updated the server-side attendance wage trigger to use saved overtime.
- Added an admin-only `admin-create-user` Supabase Edge Function. It creates a real Auth account, updates its profile and requires a password change on first login.
- Updated payroll so a payment must be assigned to a selected site and the database trigger creates the matching net wage ledger entry.
- Hid wage rates and wage totals from manager attendance views.
- Added GitHub Actions for Flutter analyze and unit tests.

## Required verification before release

### Database and authentication
- [ ] Confirm migrations 001–007 are applied to the target Supabase project.
- [ ] Apply migration 008.
- [ ] Deploy `admin-create-user`.
- [ ] Verify an active admin can create a manager and accountant.
- [ ] Verify non-admin users receive HTTP 403 from the user-creation function.
- [ ] Verify the created user can sign in and is forced to change the temporary password.

### Functional tests
- [ ] Create, edit and soft-delete a site/client/supplier/labour record using the correct role.
- [ ] Mark attendance, save it, refresh the screen and confirm the status and overtime persist.
- [ ] Verify server-computed wages for full day, half day and overtime cases.
- [ ] Verify a manager cannot read wage rates, payroll or financial transactions.
- [ ] Record a payroll payment for a selected site; verify attendance locks and one net wage ledger transaction is created.
- [ ] Verify reopening/soft-deleting a payment unlocks attendance and soft-deletes its ledger entry.
- [ ] Create, edit and soft-delete a purchase; verify exactly one linked Materials transaction exists.
- [ ] Verify ledger totals and site profitability against known sample records.
- [ ] Test English and Urdu layouts, including RTL navigation.

### Automated checks
- [ ] Run `flutter analyze` on the latest branch head.
- [ ] Run `flutter test` on the latest branch head.
- [ ] Confirm the GitHub Actions workflow passes.
- [ ] Test all core flows on the TECNO BG7 after pulling the latest commits.

## Known limitations

- Offline-first synchronization is not implemented.
- PDF/Excel exports are not implemented.
- APK signing and release distribution remain pending.
- No end-to-end test has yet verified the live Supabase project after migration 008.

## Release decision

**Not yet production-ready.** The app has a successful local analyzer run and a reported debug launch, but database migration, Edge Function deployment, full CRUD, RLS and payroll integration still require verification.
