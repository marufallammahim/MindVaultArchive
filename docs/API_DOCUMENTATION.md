# API Documentation

## Current public boundary

The app currently has no configured remote HTTP API. The active application is a local Flutter client backed by Drift/SQLite and app-private files. Therefore there are no production REST endpoints, credentials or server contracts to publish.

## Internal service contracts to maintain

- Database/repository operations: notes, categories, tags, tasks, revisions, attachments.
- Archive transfer service: versioned JSON import/export with validation and duplicate protection.
- Full backup service: ZIP manifest, attachment bytes and SHA-256 integrity validation.
- App lock service: optional local PIN gate backed by secure storage.
- Theme preference provider: local persistent system/light/dark selection.

Document method signatures, input validation, transaction boundaries and errors alongside each service as it evolves. Avoid exposing Drift row types directly to remote provider interfaces.

## Future remote API versioning

Any future remote service must publish versioned schemas, authentication/authorization, ownership rules, rate limits, idempotency, pagination, error codes, deletion/tombstone semantics and export/deletion behavior before integration.