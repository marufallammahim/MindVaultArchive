# Internal Service API

The current application has no public HTTP API and no configured backend.

## ArchiveTransferService

Location: `lib/features/archive/data/archive_transfer_service.dart`

- `exportJson()`: returns a versioned JSON document containing supported
  note and category records.
- `importJson(String source)`: validates the document and imports supported
  records transactionally. Existing note IDs are skipped.

The v1 format intentionally excludes attachment bytes and local filesystem
paths. See [BACKUP_RESTORE.md](BACKUP_RESTORE.md).
