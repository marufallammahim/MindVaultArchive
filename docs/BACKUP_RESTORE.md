# Archive Transfer

## Current implementation

MindVault Archive provides a versioned JSON transfer service for note and
category records. The service runs against the existing local Drift database
and does not require a network connection.

- Format identifier: `mindvault-archive`
- Format version: `1`
- Export includes note title/body, category IDs, timestamps, favorite/archive/
  trash flags, note color and sort order, plus category records.
- Import validates all records before entering a database transaction.
- Existing note IDs are skipped, never overwritten.
- Categories are upserted by stable ID.
- Notes whose category is unavailable are imported without a category.
- Invalid formats and duplicate IDs are rejected.

## Known v1 limitation

Attachment bytes and binary media are deliberately not included. The export
does not serialize device-local file paths. Consequently, this is a safe
text-and-metadata transfer, not yet a complete archive backup. A future
attachment-aware backup format must copy and verify binary files and preserve
attachment relationships before claiming full archive portability.

## User workflow

Open **Settings → Archive transfer**. Generate JSON and copy it to a safe
location. To import, paste a complete JSON document and choose **Validate and
import**. The app reports how many notes were imported and how many were
skipped.

## Safety

Import is transactional. The current implementation does not delete existing
records or replace notes with matching IDs. Keep an independent device backup
before transferring important data.
