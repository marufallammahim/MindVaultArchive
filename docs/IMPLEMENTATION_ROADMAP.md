# Implementation Roadmap

## P0 — Foundation and data safety
Inspect and baseline repository; complete master spec; document architecture/navigation/schema; audit migrations and logical references; verify lockfile and CI; test note CRUD/autosave/restart/search/backup; harden app lock wording and recovery. **Exit:** safe offline note lifecycle is tested.

## P1 — Essential offline notebook
Structured editor, block model, attachments lifecycle, templates, quick capture, backlinks/daily notes, trash/revisions and import/export. **Exit:** end-to-end offline knowledge workflow with attachment-safe backup.

## P2 — Productivity and multimedia
Task/subtask/project relationships, reminders, calendar, Kanban, habits, goals, focus, audio, OCR/PDF and drawing. **Exit:** tasks and multimedia link to canonical notes/projects.

## P3 — Knowledge and intelligence
Graph, smart folders, duplicate detection, semantic search, AI provider interfaces with consent/citations, timeline, canvas/mind maps. **Exit:** suggestions are reviewable and source-grounded.

## P4 — Online ecosystem
Provider authentication, outbox, idempotent sync, tombstones, conflicts, remote backup, sharing and collaboration. **Exit:** configured provider syncs actual records and passes conflict/recovery tests.

## P5 — Production hardening
Large archive performance, migration/recovery/security tests, accessibility/localization, tablet/landscape, battery behavior, release signing and documentation. **Exit:** reproducible build and evidence-backed release report.

All 22 feature categories remain in scope. Phase completion does not remove later requirements. Track exact test evidence and external blockers in `EXECUTION_STATE.md`.

## Latest implementation slice — 2026-11-11
- Added local archive insights: note/task aggregates, duplicate-title groups and missing-wikilink target review. These are deterministic local checks, not AI or semantic analysis.
- Added a merged note/task activity timeline.
- Added a developer snippet notebook using canonical note records.
- Added local Quick Capture draft restore and editor word/character/reading-time indicators.
- Centralized Material 3 visual tokens for light and dark themes.
- These additions improve F01, F03, F15, F16, F17 and F22; they do not close those feature categories. See the master checklist for remaining gates.

## Remaining high-priority work
1. Add widget/share-intent entry points and robust thought-inbox processing.
2. Add a real notebook/folder model, saved searches and transactional bulk actions.
3. Complete attachment lifecycle, supported document/PDF viewing and tested backup.
4. Add task subtasks/projects and Android reminder delivery with timezone tests.
5. Add encrypted-at-rest storage or accurately scope privacy guarantees; a PIN screen gate alone is not encryption.
6. Add migration fixtures, crash recovery, editor acceptance tests and CI evidence for the latest commit.
7. Complete adaptive navigation, tablet/landscape, accessibility and localization.
