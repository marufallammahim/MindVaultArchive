# Architecture

## Stack and structure

MindVault Archive is an Android-first Flutter client using:
- Riverpod for app and feature state.
- GoRouter for navigation.
- Drift over SQLite for durable offline-first storage.
- SharedPreferences for theme preference.
- Android app-private storage for attachment bytes.

Feature-first source layout:
- `lib/app`: app shell, providers, router and theme.
- `lib/core/database`: Drift tables, schema migrations and database operations.
- `lib/features/<feature>`: feature-specific providers, services and presentation.
- `test`: database and feature tests.

## Persistence

The local Drift database is the source of truth. Current schema version is 6 and includes notes, categories, attachments, tasks, tags, note-tag links and note revisions. Task, attachment, revision, category and tag references are currently logical/application-managed references; the table definitions inspected do not declare SQL foreign-key constraints. Permanent note deletion clears linked task references and application operations manage related cleanup. Schema upgrades are additive and must include migration tests. Never delete/recreate the user's database during an application upgrade.

## Feature data flows

- Editor state is held by a Riverpod family notifier. Changes are debounced, serialized through a write queue and saved to SQLite.
- Home lists and detail views use Drift streams.
- Local full-text search uses SQLite FTS5 virtual tables for note title/body and task title/details. Triggers maintain indexes for insert/update/delete. Category/tag name filtering is performed locally. FTS indexes are derived and rebuildable; source rows remain authoritative.
- Archive transfer validates the document before opening a transaction and protects existing note/task IDs from overwrite.
- Full ZIP backup verifies attachment checksums and restores files to new app-private paths; attachment metadata is inserted within the archive import transaction.

## Transfer and attachment boundary

JSON archive format v5 includes note content/metadata, categories, tags and links, tasks and revision history; it deliberately excludes local filesystem paths and binary attachment bytes. It is not a full media backup. The separate full ZIP backup includes registered attachment bytes and a manifest with SHA-256 checksums. JSON exports are plaintext and must be treated as sensitive data.

## Offline and network boundaries

Core note CRUD, organization, tasks, templates, capture, FTS search and local JSON/ZIP transfer do not require a network connection. No cloud account, sync endpoint, AI provider or collaboration backend is configured. The app lock is a PIN access gate, not database or attachment encryption.

## Routing and UI

The current GoRouter is a flat route list for splash, home, editor, drawing, settings, about, tasks, templates, capture, tags, revision history, search, app-lock settings and archive tools. Theme uses Material 3 with the burgundy brand seed `#5A0719` and persisted system/light/dark preference. Adaptive shell navigation and route guards remain future work.

## Engineering guardrails

- Preserve database identity and existing user data.
- Increment schema version for persistent schema changes and add tested Drift migrations.
- Audit orphan references before introducing foreign-key constraints.
- Never serialize private local filesystem paths into portable archives.
- Never overwrite local note/task content because of an ID collision.
- Never claim cloud, AI, encryption or collaboration is active without a configured and tested implementation.
- Keep secrets and production signing keys out of source control.
- See `docs/EXECUTION_STATE.md` for the interruption/resume checkpoint.
