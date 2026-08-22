# Building an Android Release

This repo ships **Dart source only** — no `android/` folder, no Flutter
SDK was ever run against it while it was being built (see the main
README's "First-time setup" section for why). That means everything in
this document is a runbook for **you**, with a real Flutter/Android
toolchain, not something already done in this repo. Nothing below has
been executed or verified by the process that wrote this file — treat
every step as untested until you've run it yourself.

## 0. Prerequisites

- Flutter stable channel installed, `flutter doctor` clean for Android
  (Android SDK, a JDK, and either a device or emulator).
- This repo cloned locally.

## 1. Generate the platform folder

```bash
cd super_kid_adventure
flutter create --platforms=android .
flutter pub get
```

`flutter create` on an existing project only fills in the missing
`android/` folder — it will not touch `pubspec.yaml`, `lib/`,
`analysis_options.yaml`, or `.gitignore`.

## 2. Verify the app actually works first

Do this **before** worrying about signing or store metadata — a signed
release build of a broken app is not a useful artifact.

```bash
flutter analyze      # must be clean
flutter test         # must be green — see "What to check" below
flutter run          # walk the checklist in the main README
```

If `flutter analyze` or `flutter test` surface anything, fix it before
continuing — every phase of this build was written and reviewed without
ever running these commands (no Flutter SDK was available), so this is
the **first real compile** this code will have ever seen. Don't assume
it's clean; find out.

## 3. Set the real app identity

`flutter create` fills in placeholder values that need to become real
choices before release:

- **`applicationId`** (`android/app/build.gradle`, `namespace` in newer
  templates too): the reverse-domain package name identifying the app
  on the Play Store, e.g. `com.yourstudio.superkidadventure`. Cannot be
  changed after first publishing without shipping as a new app.
- **App display name**: `android/app/src/main/AndroidManifest.xml`'s
  `android:label`.
- **`pubspec.yaml`'s `version:`** is already set (`1.0.0+1` as of
  Phase 13) — bump the `+N` build number on every subsequent upload to
  the same release track; bump `1.0.0` itself for user-facing version
  changes.

## 4. App icon

No production art exists yet (see the main README's Assets section) —
the app currently builds with Flutter's default icon. Before any real
release:

- Design or commission a real icon (a simple colored-shape/emoji-style
  icon consistent with the rest of V1's placeholder art would work for
  an initial release; commissioned illustration can follow).
- Generate the Android mipmap set (`flutter_launcher_icons` package, or
  Android Studio's Image Asset Studio) and replace the defaults under
  `android/app/src/main/res/mipmap-*/`.

## 5. Sign the release build

Android requires every release build to be signed with a real key
(distinct from the debug key `flutter create` wires up by default).

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Keep this keystore and its passwords somewhere safe and backed up —
losing it means you can never update the app under the same listing
again. **Never commit it to the repo.**

Create `android/key.properties` (gitignored by the `flutter create`
template by default — confirm it's listed in `android/.gitignore`):

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Wire it into `android/app/build.gradle`'s `signingConfigs`/`buildTypes`
per the
[official Flutter Android deployment guide](https://docs.flutter.dev/deployment/android)
— the exact snippet depends on your Flutter/Gradle template version, so
follow that page rather than a copy pasted here that could drift out of
date with your toolchain.

## 6. Build

```bash
flutter build appbundle --release   # .aab, what Play Store wants
# or, for sideloading/testing:
flutter build apk --release
```

Install the release APK on a real device and walk the full README
checklist again — release builds strip some debug behavior and can
surface issues a debug run doesn't.

## 7. Before submitting to the Play Store

- **Data safety form**: this app collects nothing and makes no network
  calls — everything in `lib/core/storage/` is local-only
  (`shared_preferences`), and there is no backend, no analytics SDK, no
  ad SDK. Answer the Play Console's data-safety questionnaire
  accordingly.
- **Permissions**: no `AndroidManifest.xml` permissions beyond Flutter's
  defaults should be needed — no camera, microphone, location, or
  contacts access exist anywhere in this codebase (see the design
  brief's "Child safety (hard requirements)" section). If `flutter
  create`'s generated manifest or a plugin adds anything beyond
  internet (used only by the Flutter engine's dev tooling, not by app
  code), double-check it's actually necessary.
- **Content rating / target audience**: this is a children's app (Class
  2 / age ~7 focus) — fill out Play Console's "Designed for Families"
  and target-audience sections accordingly, including their ads/data
  policies for child-directed apps.
- **Store listing**: no screenshots or store graphics exist in this
  repo — you'll need to capture real screenshots from a running build.

## What this document is not

This is not a guarantee the app builds cleanly — it's the sequence of
real steps to find out, since nothing here has been Flutter-compiled
before. If step 2 turns up analyzer or test failures, fixing those is
part of finishing the release, not optional polish.
