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
- Home search plus global offline search across notes, categories, tags and tasks.
- System/light/dark theme preference and Material 3 burgundy branding.
- Versioned JSON archive v5 for notes, categories, tags, tag links, note-linked
  tasks and note revisions; v1-v4 remain importable.
- Transactional import validation and duplicate record protection.

## Important limitations
JSON transfer does not include drawing/audio/PDF attachment bytes or private
device paths, so it is not yet a full backup. Search is local substring matching,
not semantic search. The editor supports Markdown authoring and preview, but is not a full WYSIWYG block editor.
See [Feature Specification](docs/FEATURE_SPECIFICATION.md).

## Not yet implemented
Encrypted vault/app lock, full attachment backup, reminders/notifications,
calendar, audio recording/transcription, OCR/PDF indexing, visual boards,
remote sync, cloud backup, collaboration and AI archive search. No cloud or AI
provider is configured. See [Roadmap](docs/ROADMAP.md).

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

The `Android CI` workflow runs these checks on pushes and pull requests. Use
the Actions result for the exact feature-branch commit to confirm the outcome.

## Android production release
Production release builds require a private owner-controlled signing keystore.
Follow [Android release signing setup](docs/ANDROID_RELEASE_SIGNING.md).
Never commit `android/key.properties`, `*.jks` or signing passwords.

## Storage and privacy
Notes and tasks are stored in an app-private SQLite database. No account, remote
sync or AI provider is configured. JSON exports are plaintext; protect them as
sensitive personal data.
