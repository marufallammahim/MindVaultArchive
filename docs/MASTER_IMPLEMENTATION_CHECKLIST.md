# Master Implementation Checklist

Use `[x]` only when evidence exists in code/tests/docs. A category is not complete merely because one child feature works.

## P0 — Foundation and data safety
- [x] Existing repository and feature branch access verified.
- [ ] Complete all master specification documents and gate review.
- [ ] Architecture and navigation decisions reconciled with current source.
- [x] Database schema/relationships, FK policy, indexes and migration chain audited in source; migration fixtures remain outstanding.
- [ ] Data-safe migration and backup recovery tests.
- [x] Shared Material 3 design tokens refreshed for AMOLED black and dynamic accent colors; reusable component contract and adaptive UI audit remain outstanding.
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

- [ ] Quick Capture draft persistence has been added; restart/recovery acceptance tests remain outstanding.
- [ ] Editor word/character/reading-time indicators have been added; full editor acceptance suite remains outstanding.
- [ ] Local archive insights, duplicate-title checks, broken-wikilink report and note/task timeline have been added; analytical correctness/performance tests remain outstanding.
- [ ] Developer snippet notebook has been added using canonical note records; snippet workflow tests remain outstanding.
- [ ] Material 3 shared theme tokens and optional AMOLED mode have been added; reusable component contract and adaptive UI audit remain outstanding.
- [ ] User-created Markdown templates can be saved, applied and deleted locally; template variables/import/export tests remain outstanding.
- [ ] Individual notes can be shared/exported as Markdown; broader export/import format coverage and round-trip tests remain outstanding.
- [ ] Local note file attachments can be added, listed, image-previewed, shared and removed; PDF annotation, OCR, audio/video capture and attachment lifecycle/backup acceptance tests remain outstanding.

## Evidence log
Record commit SHA, environment, exact command, exit status and artifact path for each test run. Never infer a passing test from an old README statement.


## Visual redesign progress (2026-11-11)
- [x] Dark + true-black AMOLED is the first-run default; saved user preferences are preserved.
- [x] Burgundy default accent, preset color palette and custom HEX accent selection persist locally.
- [x] Profile display name and profile image can be edited from the home header and Settings.
- [x] Notes dashboard and task list refreshed with reference-inspired colorful cards and navigation.
- [x] Existing PIN access gate surfaced as Protector without misrepresenting it as encryption.
- [ ] Rework and visually audit every remaining route (search, archive, history, drawing, capture, insights, timeline, templates and security).
- [ ] Add profile/theme persistence tests, run full analyzer and test suite, and confirm a successful Android debug APK artifact.


## Reference UI implementation progress (2026-11-12)
- [x] Home note cards restyled with the supplied colorful-card reference, compact metadata, edit affordance and floating arrow.
- [x] Task dashboard includes a horizontally selectable date strip, date-aware task creation, custom floating navigation dock and a dedicated calendar/progress view with locally computed task metrics.
- [x] Editor Markdown controls restyled as a compact dark floating toolbar; note deletion is connected to a dedicated full-screen confirmation route.
- [x] Dedicated delete confirmation screen added with dark composition, brand illustration treatment and explicit Move to Trash / No, keep it actions.
- [x] Trash destination added with restore and permanent-delete actions.
- [ ] Continue visual pass across search, archive tools, history, drawing, quick capture, insights, timeline, templates, settings, security, developer notebook and about screens.
- [ ] User-requested visual-first sequence: finish the remaining screen redesigns before starting analyzer, widget tests, integration tests or APK build.
