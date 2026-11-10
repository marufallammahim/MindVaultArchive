# Roadmap and delivery status

## Completed foundation

- Existing Flutter/Riverpod/Drift application retained.
- Dedicated feature branch created from current `main`.
- Offline notes, favorites, pinning, archive/trash lifecycle and autosave.
- Category management, note assignment and category filtering.
- Tag management and multi-tag note assignment.
- Per-note color selection, quick capture and drawing canvas.
- Title-based wikilinks and live backlinks.
- Version history with bounded retention and restore.
- Offline tasks with priorities, due dates, completion and optional note links.
- Five reusable note starter templates.
- Markdown authoring toolbar and selectable rendered preview.
- Global offline search across notes, categories, tags and tasks.
- JSON archive v5 for notes, tags, tasks and revisions.
- Full ZIP backup/restore for attachment bytes with SHA-256 validation.
- Optional six-digit app access PIN using Android secure storage.
- Transactional import validation and duplicate record protection.

## Next engineering milestones

1. SQLite FTS5 search, query filters and ranking.
2. Nested notebooks, smart views and saved searches.
3. Block editor with drag/drop, tables and embeds.
4. Local notifications, recurring tasks and calendar views.
5. Authenticated encryption for the database and attachments, with key recovery.
6. Biometric unlock as an optional convenience layer.
7. Sync outbox, conflict resolution and a real provider implementation.
8. OCR, PDF annotation and audio recording/transcription pipelines.
9. AI provider interfaces with explicit per-request consent and archive citations.
10. Visual boards and persistent knowledge graph.
11. Third-party importers/exporters and collaboration providers.
12. Complete Bengali localization and accessibility review.

## External dependencies

Remote sync, collaboration and cloud AI cannot be considered implemented until
a real server/provider, authentication and integration tests are configured.
