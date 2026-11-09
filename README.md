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

## Android release

```bash
flutter build apk --release
```

Drift's generated `database.g.dart` is produced by build_runner and should be regenerated after dependency installation.

## Storage and privacy
Notes are stored locally in an SQLite database in the app documents directory. No account or remote sync is configured.
