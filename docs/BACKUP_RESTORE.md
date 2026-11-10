# Archive Transfer and Restore

## Current implementation

MindVault Archive provides a versioned JSON transfer service for note,
category, tag, note-tag relation, task and note-revision records. The service
runs against the local Drift database without a network connection.

- Format identifier: `mindvault-archive`
- Current format version: `5`
- Version 5 includes note title/body, category IDs, timestamps,
  favorite/archive/trash flags, note color/sort order, categories, tags,
  note-tag relations, tasks (including optional linked note IDs) and up to 30 retained prior note revisions.
- Import validates the document before writing and runs writes transactionally.
- Existing note and task IDs are skipped, never overwritten.
- Categories and tags are upserted by stable ID.
- Version 1 through 4 archives remain importable; earlier formats may not
  contain tasks, tags, note-tag relations or revisions.
- Notes whose category is unavailable are imported without a category.
- Tag/revision links for colliding local note IDs are skipped to avoid
  modifying the content/history of those existing notes.

## Known v5 limitation

Attachment bytes and binary media are deliberately not included. The export
does not serialize device-local file paths. This is a portable content and
metadata transfer, not yet a full archive backup. A future attachment-aware
backup format must copy and verify binary files, preserve attachment
relationships and restore into a staging area before claiming full portability.

## User workflow

Open **Settings → Archive transfer**. Generate JSON and copy it to a safe
location. To import, paste a complete JSON document and choose **Validate and
import**. The app reports imported and skipped note/task/tag/revision counts.

## Safety

Import validates records before starting its transaction. It does not delete
existing records or replace notes/tasks with matching IDs. Keep an independent
device backup before transferring important data. JSON exports are plaintext;
protect them as sensitive data.
