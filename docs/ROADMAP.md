# Roadmap and delivery status

## Completed foundation

- Existing Flutter/Riverpod/Drift application retained.
- Dedicated feature branch created from current `main`.
- Offline notes, favorites, archive/trash lifecycle and autosave retained.
- Category management and drawing attachment workflow retained.
- JSON transfer v1 for note/category metadata, with validation and duplicate
  protection, added in this branch.

## Next engineering milestones

1. Attachment-aware full backup with checksums and safe restore staging.
2. Notebook/folder/tag model and migrations.
3. Full-text search with incremental indexing.
4. Block document editor and version history.
5. Tasks, reminders and calendar.
6. Local encryption and app lock.
7. Sync outbox plus a real provider implementation.
8. OCR/PDF/audio pipelines.
9. AI provider interfaces with explicit per-request consent.
10. Visual boards, backlinks and knowledge graph.
11. Importers/exporters and collaboration providers.

## External dependencies

Remote sync, collaboration and cloud AI cannot be considered implemented until
a real server/provider, authentication and integration tests are configured.
