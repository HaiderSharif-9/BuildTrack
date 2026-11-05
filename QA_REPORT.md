# BuildTrack — Quality Assurance Report

**Source branch:** `master`  
**Last reviewed:** 5 November 2026  
**Latest reviewed commit:** See the latest commit on the repository's `master` branch.

## 1. Automated verification

<details>
<summary>Latest GitHub Actions result</summary>

- Workflow: **Flutter CI**
- Run: [41973329749](https://github.com/HaiderSharif-9/BuildTrack/actions/runs/41973329749)
- Commit: `dffaae744f5d500cba4e8ec3f296ef3bbfe9aa01`
- Result: **Passed**

The workflow checks Flutter analysis, Flutter tests and the Deno type-check for the administrator user-provisioning Edge Function.

</details>

A passing CI run confirms the automated checks for that commit. It does **not** prove that the connected Supabase project is configured correctly or that every screen has passed live end-to-end testing.

## 2. Implemented areas

- Authentication, role-aware navigation and forced password change for provisioned staff accounts.
- Dashboard summaries, date/site filters, trends and recent activity.
- Site and client management, including site overview and manually controlled project status.
- Labour records, editing/archive flow and site assignment.
- Attendance records with work hours and overtime.
- Payroll calculations and payment recording.
- Material purchase records and linked ledger entries.
- Ledger and financial reporting screens.
- Admin-only staff account provisioning through a Supabase Edge Function.
- English and Urdu localization.
- GitHub Actions for Flutter analysis, tests and Edge Function type-checking.

## 3. Required live verification

The following checks must be completed against the intended Supabase project before describing the application as production-ready.

### Database and authentication

- [ ] Confirm migrations `001`–`014` are applied in the correct project and sequence.
- [ ] Confirm the first Admin profile exists and has the correct role.
- [ ] Deploy the `admin-create-user` Edge Function.
- [ ] Verify an active Admin can create an Accountant and a Manager.
- [ ] Verify Manager creation requires a valid site assignment.
- [ ] Verify non-Admin callers receive HTTP 403 from the user-provisioning function.
- [ ] Verify provisioned users can sign in and are required to change their temporary password.
- [ ] Verify the forced-password-change flag clears after a successful password update.

### Role and site access

- [ ] Manager sees only assigned sites and permitted operational information.
- [ ] Manager cannot access restricted financial screens or records.
- [ ] Admin and Accountant can access their permitted finance, payroll, ledger and reporting features.
- [ ] Restricted routes and direct navigation enforce the same role restrictions as the UI.

### Functional workflows

- [ ] Create, edit and update a site; verify its manually selected status persists.
- [ ] Create, edit and archive a labour record; verify site assignment and wage-rate data.
- [ ] Record attendance, refresh and confirm status, hours and overtime persist.
- [ ] Verify full-day, half-day and overtime wage calculations against known examples.
- [ ] Record a payroll payment and verify the related attendance and ledger behavior.
- [ ] Create, edit and soft-delete a purchase; verify its linked Materials ledger entry.
- [ ] Verify ledger totals and site summaries against known test records.
- [ ] Test English and Urdu layouts, including right-to-left rendering.

### Local and device testing

- [ ] Pull the latest `buildtrack-completion` branch.
- [ ] Run `flutter analyze` locally.
- [ ] Run `flutter test` locally.
- [ ] Launch the app in Chrome and test the main workflows.
- [ ] Test the latest build on a physical Android device.

## 4. Known limitations

- First-time Admin setup is performed during Supabase project initialization; the one-time in-app Initial Admin Setup screen remains a planned future enhancement.
- Full live end-to-end verification is not yet complete.
- User deactivation and role-editing screens need further work.
- Multi-site manager assignment needs additional UI support.
- Offline-first synchronization is not implemented.
- PDF/Excel report exports are not implemented.
- A release-mode APK can be built for testing using the documented command; production keystore signing and distribution are pending.

## 5. Release assessment

**Status: Development / testing build — not yet production-ready.**

The latest reviewed CI run passed. Production readiness still depends on completing the live Supabase, role-permission, functional and device checks listed above.
