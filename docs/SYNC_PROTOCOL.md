# Sync Protocol

No remote sync protocol is currently implemented. No server endpoint, account,
WebDAV connection or cloud provider is configured.

Proposed protocol requirements for a future implementation:
- Stable record IDs and monotonically tracked revisions.
- Local outbox and idempotency keys.
- Deletion tombstones.
- Conflict records and user-visible resolution.
- Exponential retry with network/battery awareness.
- Attachment hashes and resumable transfers.
- Authenticated transport and end-to-end encryption where supported.

Never report synchronization as successful until a real provider acknowledges
the operation and the resulting remote state is verified.
