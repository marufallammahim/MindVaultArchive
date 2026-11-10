# Architecture

## Stack and structure

MindVault Archive is a Flutter Android-first client using:
- Riverpod for app and feature state.
- GoRouter for navigation.
- Drift over SQLite for durable offline-first storage.
- SharedPreferences for the current theme preference.

Feature-first source layout:
- `lib/app`: app shell, providers, router and theme.
- `lib/core/database`: Drift tables, schema migrations and database operations.
- `lib/features/<feature>/data`: local feature services.
- `lib/features/<feature>/presentation`: screens and UI.
- `test`: database and feature tests.

## Persistence

The local Drift database is the source of truth. The current schema version is
5 and includes notes, categories, attachments, tasks, tags, note-tag links and
note revisions. Tasks may optionally reference a note; permanent note deletion
clears that reference before removing the note. Schema upgrades are additive and must include migration tests.
Do not delete or recreate the user's database during an application upgrade.

## Feature data flows

- Editor state is held by a Riverpod family notifier. Changes are debounced,
  serialized through a write queue and saved to SQLite.
- Home lists and detail views use Drift streams.
- Global search loads local notes, categories, tags, note-tag relations and
  tasks, then performs case-insensitive substring matching on-device.
- Archive transfer validates the document before opening a transaction and
  protects existing note/task IDs from overwrite. Full ZIP backup verifies
  attachment checksums and restores files to new app-private paths; attachment
  metadata is inserted within the archive import transaction.

## Transfer and attachment boundary

Archive format v4 includes note content/metadata, categories, tags and links,
tasks and revision history. It deliberately excludes local filesystem paths
and binary attachment bytes. It is not a full device backup.

## Offline and network boundaries

Core note CRUD, organization, tasks, templates, capture, search and JSON
transfer do not require a network connection. No cloud account, sync endpoint,
AI provider or collaboration backend is configured.

## Engineering guardrails

- Preserve database identity and existing user data.
- Increment schema version for every persistent schema change and add tested
  Drift migrations.
- Never serialize private local filesystem paths into portable archives.
- Never overwrite local note/task content because of an ID collision.
- Never claim cloud, AI, encryption or collaboration is active without a
  configured and tested implementation.
- Keep secrets and production signing keys out of source control.
