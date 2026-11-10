# Architecture

## Current structure

The application is a Flutter Android-first client using Riverpod for state,
GoRouter for navigation, Drift/SQLite for local persistence and SharedPreferences
for lightweight theme preference storage.

- `lib/app`: app shell, routes and providers.
- `lib/core/database`: Drift schema, migrations and database operations.
- `lib/features`: feature-oriented presentation and service modules.
- `test`: database and widget/unit tests.

## Data flow

Widgets call Riverpod providers and feature notifiers. Database reads use Drift
streams so local changes are reflected in the UI. The database is the source of
truth; no network is required for note CRUD.

## Transfer boundary

`ArchiveTransferService` is a data-layer service that serializes supported
database records to a versioned JSON format. It validates an entire input before
starting a transaction. It does not serialize private filesystem paths.

## Guardrails

- Preserve existing database identity and schema unless a migration is added.
- Never claim a provider is configured when credentials/backend are absent.
- Keep binary attachment backup separate until bytes and integrity checks are
  implemented.
- Do not overwrite a local note during import because of an ID collision.
