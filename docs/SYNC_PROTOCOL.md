# Sync Protocol — Design Contract

**Status:** Design only. No remote sync provider is configured.

## Local write path

1. Commit user change to local SQLite.
2. In the same transaction, append an outbox operation with stable operation ID, entity ID/type, revision, operation type, payload reference and UTC timestamp.
3. UI reads local state immediately.
4. A worker sends queued operations only when a provider is configured and authenticated.

## Protocol requirements

- Stable IDs and monotonically increasing per-record revisions.
- Idempotency key for every operation; duplicate delivery must not duplicate records.
- Exponential backoff with jitter and bounded retry; retain pending work across restart.
- Tombstones for deletions; do not infer deletion from absence.
- Attachment uploads are content-hash-addressed and resumable.
- Server checkpoints allow incremental pulls.
- Conflicts are explicit records containing base/local/remote revision metadata.
- Never silently last-write-wins over user content. Offer keep-local, keep-remote, duplicate/merge where safe.
- Validate ownership and authorization server-side.
- Credentials are stored in platform secure storage.

## Offline and failure behavior

No network is required for local reads/writes. Failed sync leaves local records and outbox intact. UI reports pending count, last successful sync and actionable errors. No fake online indicator.

## Security boundary

Transport security is mandatory. E2EE requires a separately reviewed key agreement, key ownership, metadata exposure analysis and recovery model. This document does not claim E2EE.