# Android APK Build Guide

This guide explains how to build and test an Android APK from the BuildTrack Flutter project.

## 1. Prerequisites

Install and configure:

- Flutter SDK (the project CI currently uses Flutter 3.47.9).
- Android Studio and the Android SDK.
- Android SDK platform/build tools required by the installed Flutter version.
- A Supabase project configured using [Supabase Setup](SUPABASE_SETUP.md).
- A local `env.json` file in the project root containing the Supabase URL and publishable/anon key.

Check the setup:

```powershell
flutter doctor -v
flutter doctor --android-licenses
```

Resolve Android toolchain issues reported by `flutter doctor` before building. The Windows desktop Visual Studio workload is not required for an Android APK.

## 2. Get the source and dependencies

From PowerShell, open the project directory and install packages:

```powershell
cd C:\dev\BuildTrack
git checkout master
git pull origin master
flutter pub get
```

If you cloned the repository to another location, use that directory instead. Do not commit or upload `env.json`; it is intentionally excluded from Git.

## 3. Build the APK

For a release-mode APK intended for internal testing:

```powershell
flutter build apk --release --dart-define-from-file=env.json
```

The generated file is:

```text
build\app\outputs\flutter-apk\app-release.apk
```

The first build may take longer because Gradle downloads and prepares Android dependencies. Keep the terminal open until Flutter reports that the build completed. If it fails, fix the first reported configuration or compilation error and rerun the command.

## 4. Install and test on an Android phone

Copy `app-release.apk` to the phone and open it to install. Android may ask you to allow installation from that file manager/browser; only install APKs from a source you trust.

Test at minimum:

- Sign in with the Admin account.
- Create and sign in as an Accountant and a Manager.
- Confirm temporary-password change works.
- Verify Managers see only their assigned sites and permitted screens.
- Create/update a site and manually change its status.
- Test labour, attendance, payroll, purchases and ledger records.
- Confirm data persists after closing and reopening the app.

The APK uses the Supabase environment values supplied at build time. Do not build a distributable APK with placeholder or test credentials.

## 5. Production signing warning

**Current repository status:** `android/app/build.gradle.kts` configures the release build to use the Android debug signing key. The command above therefore creates a release-mode APK suitable for internal testing, not a properly signed production release.

Before publishing or distributing a production version:

1. Create a private Android upload/release keystore.
2. Store the keystore outside the repository and keep a secure backup.
3. Put passwords and signing configuration in a local, Git-ignored properties file or a secure CI secret store.
4. Update the Android Gradle release signing configuration to use that private key instead of the debug key.
5. Verify the signed APK/AAB and keep the same signing key for future updates.

Never commit keystore files, passwords, service-role keys or real environment credentials. Production signing is a separate release-preparation task and has not yet been completed.

## 6. Useful build commands

```powershell
# Check Flutter and Android toolchain
flutter doctor -v

# Fetch packages
flutter pub get

# Build release-mode APK for testing
flutter build apk --release --dart-define-from-file=env.json

# Build a debug APK for quick development testing
flutter build apk --debug --dart-define-from-file=env.json

# Remove generated build output if troubleshooting a stale build
flutter clean
flutter pub get
```
