# MindVault Archive

**Your Mind. Your Knowledge. Your Archive.**

An offline-first personal knowledge archive built with Flutter, Riverpod, Drift
and SQLite.

## Identity
- App: MindVault Archive
- Android application ID: `com.marufallammahim.mindvaultarchive`
- Developer: Maruf Allam Mahim
- Product promise: local-first notes without advertisements or a mandatory account.

## Implemented features
- Local SQLite notes with debounced autosave and save-before-exit.
- Favorites, pinning, archive, trash, restore and permanent deletion.
- Categories, tags, note colors, wikilinks and backlinks.
- Quick Capture and five reusable note templates.
- Offline tasks with due dates, priorities, completion tracking and note linking.
- Note version history with up to 30 snapshots and restore.
- Markdown authoring toolbar with bold, italic, headings, lists, checklists,
  quotes, links and code snippets, plus rendered preview.
- Drawing canvas with local PNG attachment metadata.
- Home search plus global offline FTS5 token/prefix search across note and task text, with category/tag name filters.
- Optional six-digit app lock using Android secure storage (screen gate only).
- System/light/dark theme preference and Material 3 burgundy branding.
- Versioned JSON archive v5 for notes, categories, tags, tag links, note-linked
  tasks and note revisions; v1-v4 remain importable.
- Full ZIP backup/restore with attachment files, SHA-256 integrity checks and
  safe app-private restore paths.
- Transactional import validation and duplicate record protection.

## Important limitations
JSON transfer does not include attachment bytes. Use the full ZIP backup for
drawing/audio/file attachments; it verifies checksums and does not export local
absolute paths. Search uses local FTS5 token/prefix matching, not semantic search. The editor supports Markdown authoring and preview, but is not a full WYSIWYG block editor.
See [Feature Specification](docs/FEATURE_SPECIFICATION.md).

## Not yet implemented
Encrypted database/attachments, biometric unlock, reminders/notifications,
calendar, audio recording/transcription, OCR/PDF indexing, visual boards,
remote sync, cloud backup, collaboration and AI archive search. No cloud or AI
provider is configured. See [Roadmap](docs/ROADMAP.md).

## Setup
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Feature-branch verification and APK

The `feature/ultimate-all-in-one-mindvault` branch has three independent
GitHub Actions workflows. A push to that branch starts all three in parallel:

1. **Feature Branch - Code Check** — resolves dependencies, generates Drift and
   Riverpod sources, formats Dart files, commits formatting corrections when
   needed, and runs `flutter analyze`.
2. **Feature Branch - Regression Tests** — runs the complete Flutter test
   suite after dependency and code generation.
3. **Feature Branch - Android APK Artifact** — builds a debug APK and uploads
   `MindVaultArchive-debug.apk`, its SHA-256 checksum, and build metadata as a
   30-day artifact.

Each workflow also supports manual execution with GitHub Actions
`workflow_dispatch`. Open the [feature-branch Actions runs](https://github.com/marufallammahim/MindVaultArchive/actions?query=branch%3Afeature%2Fultimate-all-in-one-mindvault)
and inspect each workflow for the exact commit. The APK can be downloaded from
the successful build run's **Artifacts** section. A queued or failed run does
not mean an APK is available.

The equivalent local verification commands are:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
flutter build apk --debug
```

## Android production release
Production release builds require a private owner-controlled signing keystore.
Follow [Android release signing setup](docs/ANDROID_RELEASE_SIGNING.md).
Never commit `android/key.properties`, `*.jks` or signing passwords.

## Storage and privacy
Notes and tasks are stored in an app-private SQLite database. No account, remote
sync or AI provider is configured. JSON exports are plaintext; protect them as
sensitive personal data.
