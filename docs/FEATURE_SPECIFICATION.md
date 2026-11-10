# Feature Specification — verified source inventory

This is an implementation inventory, not a marketing checklist. A feature is
only called implemented when the repository contains a usable local workflow.

## Implemented

### Notes and organization
- Offline Drift/SQLite notes with title and body editing.
- Debounced autosave, serialized writes, retryable save errors and save-before-exit.
- Favorites, pinning, archive, trash, restore and permanent deletion.
- Categories with create, rename, delete, note assignment and category filtering.
- Tags with create, rename, delete and multi-tag assignment.
- Per-note color selection and tinted archive cards.
- Lightweight `[[Note title]]` wikilinks and title-based backlinks.
- Up to 30 previous note revisions, version history and restore.

### Capture and productivity
- Quick Capture for title/body ideas.
- Five starter templates: daily journal, meeting, project, study and developer notes.
- Offline tasks with title/details, due date, priority, completion, edit and delete.
- Local drawing canvas with PNG attachment metadata.

### Search and transfer
- Home search across title/body in the active note view.
- Global offline search across note titles/bodies, category names, tag names,
  and task titles/details.
- Versioned JSON archive transfer v4 for notes, categories, tags, tag links,
  tasks and note revisions.
- Import supports formats v1-v4, validates input before transaction, and
  protects existing note/task IDs from overwrite.
- Import/export deliberately excludes private device paths and binary
  attachment bytes.

### App foundation
- Flutter, Riverpod, GoRouter and Drift/SQLite architecture.
- Persistent system/light/dark theme preference.
- Material 3 burgundy brand seed.
- Android CI workflow for dependency resolution, Drift code generation,
  formatting, static analysis, tests and debug APK build.

## Partial

- Search is local substring matching, not FTS5, semantic or OCR search.
- Editor stores Markdown source and provides formatting shortcuts plus a
  selectable rendered preview; it is not a WYSIWYG block editor.
- Organization supports categories/tags and title-based links; nested
  notebooks, smart views and a graph visualization are absent.
- Drawing attachment records are local; export does not package attachment
  files or verify their hashes.
- Task due dates are stored and displayed, but scheduled notifications,
  recurrence and calendar views are absent.
- Theme supports system/light/dark, not user-defined palettes, fonts or
  layout customization.
- Bengali localization is not complete.

## Not implemented

- Full attachment-aware ZIP backup and staged restore.
- Voice recording, audio playback/transcription and OCR/PDF indexing.
- App lock, biometric vault and encrypted database/attachment storage.
- Local reminder notifications, recurrence, calendar, habits and project boards.
- Visual canvas/whiteboard and graph exploration.
- Cloud sync, WebDAV/Nextcloud provider and multi-device conflict resolution.
- Collaboration, sharing permissions and multi-user editing.
- AI provider integration, local semantic index and retrieval-augmented answers.
- Third-party importers and migration from other note applications.

## External infrastructure and privacy

Cloud sync, collaboration and cloud AI require a real provider/backend,
authentication and explicit user configuration. No such service is active.
Any future AI workflow must ask before sending note content off-device and
must preserve local-only operation when AI is disabled.
