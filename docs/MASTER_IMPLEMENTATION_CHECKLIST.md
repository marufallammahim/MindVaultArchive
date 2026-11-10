# Master Implementation Checklist

Use `[x]` only when evidence exists in code/tests/docs. A category is not complete merely because one child feature works.

## P0 — Foundation and data safety
- [x] Existing repository and feature branch access verified.
- [ ] Complete all master specification documents and gate review.
- [ ] Architecture and navigation decisions reconciled with current source.
- [x] Database schema/relationships, FK policy, indexes and migration chain audited in source; migration fixtures remain outstanding.
- [ ] Data-safe migration and backup recovery tests.
- [ ] Design tokens and shared component contract.
- [ ] Core note CRUD, autosave, draft recovery and editor acceptance tests.
- [ ] Notebook/folder/tag organization and local search acceptance tests.
- [ ] App lock threat model; distinguish screen gate from encryption.
- [ ] CI format/analyze/test/debug-build checks verified on this branch.

## P1 — Essential offline notebook
- [ ] Structured block editor, Markdown round-trip, tables and code rendering.
- [ ] Attachments lifecycle and previews.
- [ ] PDF access/annotation where supported.
- [ ] Template library and custom templates.
- [ ] Quick capture and thought inbox recovery.
- [ ] Backlinks, daily notes and version history acceptance tests.
- [ ] Import/export round-trip and restore integrity tests.

## P2 — Productivity and multimedia
- [ ] Task/subtask/project model integration.
- [ ] Reminders, calendar and Kanban.
- [ ] Habits, goals and focus sessions.
- [ ] Audio, OCR, scanning and handwriting pipelines.
- [ ] Productivity analytics with verifiable local aggregates.

## P3 — Knowledge and intelligence
- [ ] Knowledge graph, smart folders and related notes.
- [ ] Duplicate detection and semantic search.
- [ ] AI provider abstraction, explicit consent and source references.
- [ ] Canvas and mind maps.
- [ ] Timeline and thought connections.

## P4 — Online ecosystem
- [ ] Sync outbox, idempotency, tombstones and checkpoints.
- [ ] Provider authentication and secure credential storage.
- [ ] Conflict UI and simulated conflict tests.
- [ ] Remote backup and restore.
- [ ] Sharing/collaboration backend and authorization tests.

## P5 — Production hardening
- [ ] Large archive performance and thousands-of-record tests.
- [ ] Migration, crash recovery, backup/restore and security tests.
- [ ] Accessibility, localization, tablet and landscape audit.
- [ ] Battery/background execution review.
- [ ] Release build and signing configuration verification.
- [ ] Final docs and factual release report.

## 22 category status
F01 Partial; F02 Partial; F03 Partial; F04 Not started; F05 Partial; F06 Partial; F07 Partial; F08 Partial; F09 Not started; F10 Partial; F11 Not started; F12 Partial; F13 Partial; F14 Not started; F15 Partial; F16 Partial; F17 Partial; F18 Partial; F19 Partial; F20 Partial; F21 Partial; F22 Partial.

## Evidence log
Record commit SHA, environment, exact command, exit status and artifact path for each test run. Never infer a passing test from an old README statement.
