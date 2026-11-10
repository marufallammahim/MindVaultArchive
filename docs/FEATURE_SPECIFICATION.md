# Feature Specification — implementation status

This document reports repository functionality, not the aspirational product
vision. A feature is not marked complete merely because a route or button exists.

## Implemented in the current source

- Offline SQLite notes using Drift.
- Note creation and editing with debounced autosave and save-before-exit.
- Favorites, archive, trash, restore and confirmed permanent deletion.
- Category creation, rename, deletion, note assignment and category-filtered view.
- Per-note color selection and tinted archive cards.
- Quick Capture for fast local idea capture.
- Local drawing canvas with PNG attachment metadata.
- Title/body search over the loaded local note list.
- Light, dark and system theme selection with local persistence.
- Offline task manager with title/details, due date, priority, completion state,
  editing and deletion.
- Reusable starter templates for daily journal, meeting, project plan, study
  notes and developer notes.
- Versioned JSON transfer v2 for notes, categories and tasks; v1 remains
  importable.
- Import validation, transactional writes and duplicate note/task-ID protection.
- Existing Flutter CI and Android build workflows.

## Partial

- Search: local title/body substring matching; no FTS index, advanced filters
  or OCR index.
- Editor: plain text fields plus drawing attachments; not a block-based rich editor.
- Organization: categories and template starters exist; nested notebooks,
  tags, smart views and backlinks are not implemented.
- Attachments: drawing metadata is stored locally; archive transfer does not
  package attachment bytes.
- Security: app-level lock and encrypted database/attachments are not implemented.
- Sync: no remote sync provider or account is configured.
- AI: no provider integration or archive RAG is implemented.
- Localization: full Bengali UI translation is not complete.

## Not implemented yet

Reminders/notifications, calendar, habits, projects, backlinks, knowledge graph,
semantic search, OCR/PDF indexing, audio recording/transcription, handwriting,
visual canvas boards, collaboration, cloud backup, WebDAV/Nextcloud sync,
end-to-end encryption, and full importers for third-party archive formats.

## External infrastructure required

Cloud sync, collaboration and cloud AI require a configured backend/provider
and user credentials. None is represented as active until a real provider is
connected and tested.
