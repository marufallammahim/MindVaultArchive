# MindVault Archive

**Capture everything. Organize naturally. Never lose a thought.**

An offline-first personal knowledge archive built with Flutter, Riverpod, Drift and SQLite.

## Identity
- App: MindVault Archive
- Android application ID: `com.marufallammahim.mindvaultarchive`
- Developer: Maruf Allam Mahim

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Verification

The project has GitHub Actions workflows for Flutter formatting, static analysis, tests, and Android release-mode APK/AAB candidate builds with CI signature verification.

## Android debug build

```bash
flutter build apk --debug
```

Debug APKs are for testing and are signed with the Android debug key. They are not production release builds.

## App features and current scope

- Offline SQLite notes with title/content search.
- Favorites, archive, trash, restore, and permanent deletion.
- Drawing canvas with local PNG attachments.
- Category create, rename, and delete controls.
- Light/dark/system theme with local persistence.
- Editor autosave with queued writes, retryable errors, and save-before-exit behavior.

Voice recording, audio playback, note-to-category assignment, rich-text editing, backup/restore, and full Bengali localization remain planned work; do not assume these are complete.

## Android production release

Production release builds require your own private Android signing keystore. Follow [Android release signing setup](docs/ANDROID_RELEASE_SIGNING.md) to configure GitHub Actions secrets and run **Actions → Signed Android Release**. The workflow verifies both APK and AAB signatures before uploading release artifacts.

Never commit `android/key.properties`, `*.jks`, or signing passwords.

## Storage and privacy

Notes are stored locally in an SQLite database in the app documents directory. No account or remote sync is configured.
