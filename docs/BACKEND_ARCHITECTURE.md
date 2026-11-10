# Backend Architecture

## Local-first boundary

Flutter presentation → feature use cases/repositories → Drift/SQLite and app-private file storage. Local writes commit first and update the UI without waiting for network access. Remote adapters are optional consumers of committed local changes.

## Provider interfaces

Define narrow interfaces for SyncProvider, BackupProvider, AIProvider, EmbeddingProvider and SharingProvider. Keep provider DTOs out of UI and database models. Each adapter must expose configuration validation, capability reporting, cancellation, structured errors and health checks.

## Provider evaluation

- WebDAV/Nextcloud: user-controlled server and portable file protocols; requires careful locking, versioning and conflict semantics.
- Supabase/Firebase: managed auth/database/storage; evaluate pricing, data residency, offline semantics and rules before selection.
- Custom REST: maximum protocol control, but creates hosting, maintenance, security and operational-cost obligations.

No backend is selected or configured in the current repository. Do not embed credentials or make cloud capability appear active by adding a settings page.

## Remote service requirements

Authentication and authorization; per-user ownership; device identity; API versioning; validation; rate limiting; attachment storage; idempotency; tombstones; conflict resolution; sync checkpoints; account export/deletion; secure credential handling; audit-safe logs.

## Cost and privacy

Default to local-only. Document recurring infrastructure cost before selecting a service. External AI/sync must be opt-in, and failure must not break offline notes.