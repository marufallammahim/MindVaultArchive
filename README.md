# MindVault Archive

**Your Mind. Your Knowledge. Your Archive.**

An offline-first personal knowledge archive built with Flutter, Riverpod, Drift
and SQLite.

## Identity
- App: MindVault Archive
- Android application ID: `com.marufallammahim.mindvaultarchive`
- Developer: Maruf Allam Mahim
- Product promise: local-first notes without advertisements or a mandatory account.

## Current features
- Local SQLite notes with title/body search.
- Note editing with debounced auto-save, retryable save errors and save-before-exit.
- Favorites, archive, trash, restore and permanent deletion.
- Category create, rename, delete, note assignment and category filtering.
- Per-note color palette and tinted note cards.
- Quick Capture for ideas and thoughts.
- Local drawing canvas and drawing attachment metadata.
- Offline tasks with due dates, priorities and completion state.
- Starter templates for journals, meetings, projects, study and developer notes.
- Light, dark and system theme preference.
- Versioned JSON transfer v2 for notes, categories and tasks.
- Import validation, transactional writes and duplicate record protection.
- Flutter CI for formatting, analysis, tests and Android debug builds.

## Important archive-transfer limitation
The JSON transfer includes note, category and task content/metadata but does
not include attachment file bytes, audio, drawings or other binary assets. It
is not yet a full archive backup. See [Backup and Restore](docs/BACKUP_RESTORE.md).

## Not yet implemented
Remote synchronization, cloud backup, encrypted database/attachments, app lock,
rich block editor, tags, nested notebooks, full Bengali localization, OCR/PDF
indexing, audio recording, reminders/notifications, backlinks/knowledge graph,
collaboration and AI archive search. No cloud or AI provider is configured.
See [Feature Specification](docs/FEATURE_SPECIFICATION.md) and
[Roadmap](docs/ROADMAP.md) for accurate status.

## Setup
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Verification
```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

The `Android CI` workflow runs on pushes and pull requests. Use the GitHub
Actions result for the exact commit to confirm the outcome.

## Android production release
Production release builds require your own private Android signing keystore.
Follow [Android release signing setup](docs/ANDROID_RELEASE_SIGNING.md) to
configure GitHub Actions secrets and run **Actions → Signed Android Release**.
Never commit `android/key.properties`, `*.jks` or signing passwords.

## Storage and privacy
Notes are stored locally in an SQLite database in the app documents directory.
No account, remote sync or AI provider is configured. JSON exports are plaintext;
protect them as sensitive data.
