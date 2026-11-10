# Internal Service API

The current application has no public HTTP API and no configured backend.

## ArchiveTransferService

Location: `lib/features/archive/data/archive_transfer_service.dart`

- `exportJson()`: returns versioned JSON format v5 for notes, categories, tags,
  note-tag relations, tasks and note revisions.
- `importJson(String source, {List<AttachmentImportRecord> attachments})`:
  validates the complete archive before a database transaction, skips existing
  note/task/attachment IDs, and returns imported/skipped counts.

JSON transfer excludes binary attachment bytes and local filesystem paths.

## FullBackupService

Location: `lib/features/archive/data/full_backup_service.dart`

- `exportZip()`: creates a ZIP containing the JSON archive, registered
  attachment bytes and a manifest with SHA-256 checksums.
- `importZip(Uint8List zipBytes)`: validates ZIP paths, manifest fields,
  note relationships and checksums before staging files and importing metadata.
- Limits: 250 MB compressed/uncompressed and 1,000 attachments.
- Restored attachments use new app-private paths; original absolute paths are
  never exported.
- Existing IDs are skipped rather than overwritten.

See [BACKUP_RESTORE.md](BACKUP_RESTORE.md) for format and restore semantics.

## AppLockService

Location: `lib/features/security/data/app_lock_service.dart`

- `setPin(String pin)`: stores a random salt and SHA-256 PIN hash in platform
  secure storage; accepts six digits.
- `verifyPin(String pin)`: verifies the salted hash.
- `disablePin(String currentPin)`: requires the current PIN.

This is an app access gate only, not database or attachment encryption.
