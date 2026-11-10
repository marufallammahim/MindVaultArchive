# Roadmap and delivery status

## Completed foundation

- Existing Flutter/Riverpod/Drift application retained.
- Dedicated feature branch created from current `main`.
- Offline notes, favorites, archive/trash lifecycle and autosave retained.
- Category management, note assignment and category filtering.
- Drawing canvas and local attachment metadata retained.
- Offline tasks with priorities, due dates and completion state.
- Five reusable note starter templates.
- JSON transfer v2 for notes, categories and tasks, with v1 import compatibility.
- Transactional validation and duplicate record protection.

## Next engineering milestones

1. Attachment-aware full backup with checksums and safe restore staging.
2. Tags, nested notebooks and smart views.
3. Full-text search with incremental indexing.
4. Block document editor, markdown preview and version history.
5. Local notifications for task reminders and calendar views.
6. Local encryption and app lock.
7. Sync outbox plus a real provider implementation.
8. OCR/PDF/audio pipelines.
9. AI provider interfaces with explicit per-request consent.
10. Visual boards, backlinks and knowledge graph.
11. Third-party importers/exporters and collaboration providers.
12. Complete Bengali localization and accessibility review.

## External dependencies

Remote sync, collaboration and cloud AI cannot be considered implemented until
a real server/provider, authentication and integration tests are configured.
