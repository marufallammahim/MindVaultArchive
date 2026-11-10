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

## Full ZIP backup

The Archive Transfer screen also provides a separate full ZIP backup workflow.
The ZIP contains the v5 JSON archive, attachment bytes and a manifest containing
attachment metadata plus SHA-256 checksums. It never exports absolute local file
paths. Restore validates the manifest, safe archive paths, note relationships
and checksums before writing data. Attachment files are restored to new
app-private paths.

- ZIP format: `mindvault-full-backup` version 1.
- Maximum compressed and uncompressed size: 250 MB.
- Maximum attachments: 1,000.
- A missing source attachment stops backup creation instead of silently
  producing an incomplete backup.
- Existing note, task and attachment IDs are not overwritten.
- A duplicate or note-colliding attachment is skipped and its staged file is
  removed.
- Attachment metadata is inserted in the same SQLite transaction as the
  imported note/task data.

The JSON-only transfer remains useful for text/metadata exchange but does not
contain attachment bytes. Use the full ZIP workflow when media files must be
preserved.

## User workflow

Open **Settings → Archive transfer**. Use **Create full ZIP backup** and the
system share sheet to save/share the complete archive. Use **Restore full ZIP
backup** to choose and validate a backup. For text-only exchange, generate
JSON and copy/share it; JSON files can also be selected for import. The app reports imported and skipped note/task/tag/revision/attachment counts.

## Safety

Import validates records before starting its transaction. It does not delete
existing records or replace notes/tasks with matching IDs. Keep an independent
device backup before transferring important data. JSON exports are plaintext;
protect them as sensitive data.
