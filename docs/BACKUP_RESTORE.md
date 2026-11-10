# Archive Transfer and Restore

## Current implementation

MindVault Archive provides a versioned JSON transfer service for note,
category and task records. The service runs against the local Drift database
without a network connection.

- Format identifier: `mindvault-archive`
- Current format version: `2`
- Version 2 includes note title/body, category IDs, timestamps,
  favorite/archive/trash flags, note color/sort order, category records and
  task title/details/due date/priority/completion state.
- Import validates the document before writing and runs writes transactionally.
- Existing note and task IDs are skipped, never overwritten.
- Categories are upserted by stable ID.
- Version 1 archives remain importable; they contain no task records.
- Notes whose category is unavailable are imported without a category.

## Known v2 limitation

Attachment bytes and binary media are deliberately not included. The export
does not serialize device-local file paths. This is a portable content and
metadata transfer, not yet a full archive backup. A future attachment-aware
backup format must copy and verify binary files, preserve attachment
relationships and restore into a staging area before claiming full portability.

## User workflow

Open **Settings → Archive transfer**. Generate JSON and copy it to a safe
location. To import, paste a complete JSON document and choose **Validate and
import**. The app reports imported and skipped note/task counts.

## Safety

Import validates records before starting its transaction. It does not delete
existing records or replace notes/tasks with matching IDs. Keep an independent
device backup before transferring important data. JSON exports are plaintext;
protect them as sensitive data.
