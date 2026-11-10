# Offline and Online System

## Current behavior

The Drift SQLite database is the source of truth for note and category records.
Creating, editing, searching, favoriting, archiving, restoring and deleting
notes are local operations and do not require network connectivity. Drawing
files are saved locally and attachment metadata is stored in SQLite.

The application currently has no configured remote sync service, account or
cloud backup. It must not display a successful cloud-sync state.

## Future sync design

A future provider should use local-first writes, an outbox, stable IDs, revision
tracking, idempotent operations, tombstones, retry/backoff, attachment queues
and explicit conflict resolution. Local writes must remain available when a
provider is offline or misconfigured.
