# Feature Specification — implementation status

This document reports repository functionality, not the aspirational product
vision. A feature is not marked complete merely because a route or button exists.

## Implemented in the current source

- Offline SQLite notes using Drift.
- Note creation and editing with debounced autosave and save-before-exit.
- Favorites, archive, trash, restore and confirmed permanent deletion.
- Category creation, rename and deletion with note detachment.
- Local drawing canvas with PNG attachment metadata.
- Title/body search over the loaded local note list.
- Light, dark and system theme selection with local persistence.
- Versioned JSON transfer for note and category records (format v1).
- Import validation, transactional writes and duplicate note-ID protection.
- Existing Flutter CI and Android build workflows.

## Partial

- Search: local title/body substring matching; no FTS index, filters or OCR index.
- Editor: plain text fields plus drawing attachments; not a block-based rich editor.
- Organization: categories exist; nested notebooks, folders, tags and smart views
  are not implemented.
- Attachments: drawing metadata is stored locally; archive transfer v1 does not
  package attachment bytes.
- Security: app-level lock and encrypted database/attachments are not implemented.
- Sync: no remote sync provider or account is configured.
- AI: no provider integration or archive RAG is implemented.
- Localization: Flutter localization dependencies exist, but full Bengali UI
  translation is not complete.

## Not implemented yet

Tasks and reminders, calendar, habits, projects, backlinks, knowledge graph,
semantic search, OCR/PDF indexing, audio recording/transcription, handwriting,
visual canvas boards, collaboration, cloud backup, WebDAV/Nextcloud sync,
end-to-end encryption, and full importers for third-party archive formats.

## External infrastructure required

Cloud sync, collaboration, public sharing and cloud AI require a configured
backend/provider and user credentials. None is represented as active until a
real provider is connected and tested.
