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
- Offline tasks with priorities, due dates and completion state.
- Five reusable note starter templates.
- JSON transfer v4 for notes, categories, tags, note-tag links, tasks and
  revision history, with v1-v3 import compatibility.
- Transactional validation and duplicate record protection.

## Next engineering milestones

1. Attachment-aware full backup with checksums and safe restore staging.
2. Nested notebooks and smart views.
3. Full-text and semantic search with incremental indexing.
4. Block document editor, markdown preview and version history diff.
5. Local notifications for task reminders and calendar views.
6. Local encryption and app lock.
7. Sync outbox plus a real provider implementation.
8. OCR/PDF/audio pipelines.
9. AI provider interfaces with explicit per-request consent.
10. Visual boards and persistent knowledge graph.
11. Third-party importers/exporters and collaboration providers.
12. Complete Bengali localization and accessibility review.

## External dependencies

Remote sync, collaboration and cloud AI cannot be considered implemented until
a real server/provider, authentication and integration tests are configured.
