# MindVault Archive — Master Feature Specification

**Product:** MindVault Archive — Your Mind. Your Knowledge. Your Archive.  
**Application ID:** `com.marufallammahim.mindvaultarchive`  
**Branch:** `feature/ultimate-all-in-one-mindvault`  
**Specification status:** Baseline created; implementation status is evidence-based and must be revised with each delivery.

## 1. Product contract

MindVault is an Android-first, offline-first personal knowledge archive. Local records are the source of truth. Notes, search, organization, tasks, templates, local attachments, export and local backup must remain usable without an account or network. Remote AI, synchronization, sharing and cloud backup are optional integrations and must not be represented as active until a real provider is configured and tested.

### Global engineering rules

- Preserve the existing repository, Git history, application ID, useful assets and working features.
- Keep all work on the already-existing feature branch; do not create another branch.
- Never replace persistent user data with in-memory demo data.
- Use stable IDs, UTC timestamps, explicit migrations and transactions for multi-record operations.
- Do not claim a capability is implemented merely because a route, setting or provider interface exists.
- Never silently overwrite conflicting data or delete user content.
- External AI transmission requires explicit consent; locked content is excluded.
- Every feature record below must be tracked through: specified, mapped, implemented, tested, documented, blocked/remaining.

## 2. Existing implementation baseline (verified from repository documentation and source inventory)

The current application uses Flutter, Riverpod, GoRouter and Drift/SQLite. Existing documented workflows include local notes with debounced autosave, favorites, pinning, archive/trash/restore, categories, tags, title-based wikilinks/backlinks, quick capture, five templates, note-linked tasks, bounded note revision history, Markdown authoring/preview, a local drawing canvas, FTS5 token/prefix search, optional six-digit app access PIN, theme persistence, versioned JSON archive transfer and ZIP backup/restore with SHA-256 checks.

Known limitations already documented by the repository: the PIN gate is not database encryption; the editor is not a WYSIWYG block editor; search is not semantic/OCR search; schema relationships do not yet consistently use database foreign keys; no remote sync, cloud AI or collaboration provider is configured. See `FEATURE_SPECIFICATION.md`, `DATABASE_SCHEMA.md`, `BACKUP_RESTORE.md` and `ROADMAP.md`.

## 3. Feature specification catalogue

Each category below is mandatory in the product vision. Status refers to the verified current baseline, not the desired end state.

### F01 — Advanced Core Notes System
- **Purpose/workflow:** Create, edit, autosave, recover and manage long-form structured notes offline.
- **Entry/screens:** Home → note list → editor; Markdown preview; revision history; attachment browser.
- **UI/actions:** Title/body editor, formatting controls, block menu, preview toggle, undo/redo, find/replace, word count, reading time, focus/fullscreen controls, attachment actions.
- **Logic/data:** Stable note IDs; structured blocks; serialized debounced writes; draft/cursor recovery; revisions; attachments; safe save-before-exit.
- **Offline/backend/permissions:** LOCAL; no backend; file/media permissions only when a platform API requires them.
- **Security/errors:** Never lose unsaved edits silently; surface save failures; exclude private text from logs.
- **Acceptance/tests:** Create/edit/reopen persistence; autosave after interruption; failed-write recovery; formatting round-trip; block ordering and attachment reopen.
- **Baseline:** PARTIAL — Markdown authoring/preview and autosave exist; live word/character/reading-time indicators and Quick Capture draft recovery were added in the latest source slice. WYSIWYG/block editor, advanced formatting and full recovery acceptance tests remain incomplete.

### F02 — Advanced Organization
- **Purpose/workflow:** Organize notes through notebooks, folders, tags, saved searches and lifecycle states.
- **Entry/screens:** Notes, notebook/folder/tag browsers, smart folders, favorites, pinned, archive, trash, bulk actions.
- **Logic/data:** Notes, notebooks, hierarchical folders, tags, join records, saved searches, revisions and soft-delete state.
- **Offline/backend:** LOCAL; no backend.
- **Security/errors:** Validate moves and deletes transactionally; preserve attachments and links.
- **Acceptance/tests:** Move/restore/bulk action correctness; tag filtering; nested folder integrity; duplicate/merge/split behavior.
- **Baseline:** PARTIAL — categories, tags, favorites, pinning, archive/trash, title links and revisions exist; notebooks, nested folders, smart folders and graph are not complete.

### F03 — Quick Capture
- **Purpose/workflow:** Capture ideas quickly and safely, then process them into notes/tasks/projects.
- **Entry/screens:** Quick Capture, notification/widget/shortcut entry points, thought inbox.
- **Logic/data:** Draft/capture records with timestamps and processing state; optional attachment links.
- **Offline/backend:** LOCAL; Android device services for widgets, intents, speech and notifications.
- **Permissions:** Request camera/microphone/notification permissions only at point of use.
- **Acceptance/tests:** Capture offline, survive app restart, recover drafts, convert capture without losing content.
- **Baseline:** PARTIAL — in-app Quick Capture now restores a local draft; widgets, notification capture, share intents, voice capture and thought-inbox processing require implementation/verification.

### F04 — AI-Powered MindVault
- **Purpose/workflow:** Optional writing assistance and source-grounded questions over selected notes/archive.
- **Entry/screens:** AI home, conversation, Ask Your Notes, provider settings, consent and source references.
- **Logic/data:** AI conversations/references, provider interfaces, retrieval index and per-request context selection.
- **Offline/backend:** HYBRID for local models; BACKEND REQUIRED for remote providers.
- **Security:** Explicit transmission consent; no locked content; secure API key storage; citations must resolve to source notes; AI remains optional.
- **Acceptance/tests:** Consent gate, source citation accuracy, locked-note exclusion, provider failure fallback, deletion of conversation history.
- **Baseline:** NOT IMPLEMENTED — no AI provider is configured.

### F05 — Multimedia Notebook
- **Purpose/workflow:** Attach, browse and annotate supported image, document, PDF, audio and video assets.
- **Entry/screens:** Attachment library, camera/scanner, image/PDF viewer, OCR, audio recorder/player/transcription, drawing.
- **Logic/data:** Attachment metadata, content hashes, safe app-private paths, note/block relations and derived OCR/transcript text.
- **Offline/backend:** LOCAL for downloaded/local files; DEVICE SERVICE for capture/recording; HYBRID for optional remote processing.
- **Security/errors:** Validate MIME/type/size; never trust imported paths; preserve referenced files; report unsupported formats.
- **Acceptance/tests:** Attach/reopen; remove one reference without deleting shared content; backup/restore bytes and metadata; OCR indexing.
- **Baseline:** PARTIAL — drawing, ZIP attachment backup and local file attachment add/list/remove with image preview/share handoff now exist; scanner, OCR, PDF annotation, audio/video capture and full attachment lifecycle tests remain incomplete.

### F06 — Task Manager and Productivity
- **Purpose/workflow:** Create tasks in notes or globally, schedule and track progress across projects.
- **Entry/screens:** Task dashboard/list/details/editor, subtasks, Kanban, calendar, planners, habits, goals, focus.
- **Logic/data:** Tasks, subtasks, projects, reminders, calendar events, habits/entries and goals.
- **Offline/backend:** LOCAL; reminders additionally require Android device notification service.
- **Acceptance/tests:** Note-created task appears globally; edits remain consistent; due dates/timezones and completion persist; recurrence/reminder delivery.
- **Baseline:** PARTIAL — offline note-linked tasks, priorities, due dates and completion exist; reminders, recurrence, calendar, projects and habits remain incomplete.

### F07 — Universal Search
- **Purpose/workflow:** Search locally available notes, tasks, tags, attachments and extracted text.
- **Entry/screens:** Global search, filters, result preview, saved searches/history.
- **Logic/data:** FTS index, incremental index updates, metadata filters, query history and optional semantic embeddings.
- **Offline/backend:** LOCAL for indexed local content; HYBRID for optional semantic provider.
- **Security:** Locked content must not leak into results/snippets.
- **Acceptance/tests:** Offline query, update-after-edit, exact phrase/filter behavior, ranking, index rebuild and locked-content tests.
- **Baseline:** PARTIAL — FTS5 token/prefix search exists for notes/tasks with category/tag filters; semantic, OCR/PDF and advanced query support remain incomplete.

### F08 — Security and Privacy
- **Purpose/workflow:** Protect app access, individual records, files, backups and credentials.
- **Entry/screens:** App lock, PIN/biometric setup, encryption settings, locked notes, privacy dashboard.
- **Logic/data:** Key metadata, secure key storage, encrypted database/files/backups, lock policy and audit-safe logging.
- **Offline/backend:** LOCAL + DEVICE SERVICE for biometrics.
- **Acceptance/tests:** Auth failure handling, encrypted-at-rest verification, backup integrity, recovery and sensitive-preview checks.
- **Baseline:** PARTIAL — optional PIN screen gate exists; it is not data encryption. Database/attachment/backup encryption and biometric unlock are not implemented.

### F09 — Online and Offline Sync
- **Purpose/workflow:** Preserve local-first editing and synchronize configured devices/providers with visible conflict resolution.
- **Entry/screens:** Sync dashboard, provider setup, history, conflicts, device management.
- **Logic/data:** Outbox, stable operation IDs, revisions, tombstones, checkpoints, retry/backoff and conflict records.
- **Offline/backend:** LOCAL editing; BACKEND REQUIRED for multi-device sync.
- **Security:** Authenticated provider, ownership checks, credential protection; claim E2EE only after protocol verification.
- **Acceptance/tests:** Offline queue, idempotent replay, reconnect, simulated conflict and user-selected resolution.
- **Baseline:** NOT IMPLEMENTED — no sync provider configured.

### F10 — Import and Export
- **Purpose/workflow:** Validate, preview, import and export portable user-owned archive data.
- **Entry/screens:** Import center/source/preview/validation/progress; export format/progress; backup/restore.
- **Logic/data:** Versioned transfer schema, mapping, duplicate policy, attachment bytes, metadata and relationship preservation.
- **Offline/backend:** LOCAL for local files; cloud destinations require configured provider.
- **Acceptance/tests:** Invalid archive rejection; no destructive action before validation; JSON/ZIP round-trip; report partial failures.
- **Baseline:** PARTIAL — versioned JSON transfer, ZIP backup/restore, individual Markdown note share/export and file attachment handoff exist; broad third-party importers, multi-note Markdown export and additional formats remain incomplete.

### F11 — Visual Workspace
- **Purpose/workflow:** Arrange notes/tasks/projects spatially and connect them visually.
- **Entry/screens:** Canvas browser, infinite canvas, mind map, flowchart, research/project boards, element properties.
- **Logic/data:** Boards, elements, coordinates, viewport, connections and links to canonical records.
- **Offline/backend:** LOCAL.
- **Acceptance/tests:** Persist/reopen positions, zoom and connections; linked record opens canonical source; large-board performance.
- **Baseline:** NOT IMPLEMENTED — drawing canvas is not an infinite workspace.

### F12 — Templates Library
- **Purpose/workflow:** Browse, preview, customize and apply reusable note structures.
- **Entry/screens:** Library, categories, preview, editor, variables and custom management.
- **Logic/data:** Template records, category, variable definitions and generated editable notes.
- **Offline/backend:** LOCAL.
- **Acceptance/tests:** Apply template creates persistent editable note; variables resolve; import/export and duplicate/delete behavior.
- **Baseline:** PARTIAL — five starter templates and a locally persisted custom Markdown template library with create/apply/delete now exist; variables, template import/export and acceptance tests remain incomplete.

### F13 — Complete Customization
- **Purpose/workflow:** Persist accessible appearance, editor, navigation and language preferences.
- **Entry/screens:** Appearance/editor/notes/search/language settings.
- **Logic/data:** UserPreferences with schema/version and defaults.
- **Offline/backend:** LOCAL.
- **Acceptance/tests:** Preferences survive restart; themes apply consistently; text scaling and reduced motion work.
- **Baseline:** PARTIAL — system/light/dark theme preference, shared Material 3 visual tokens and an optional true-black AMOLED mode exist; custom palettes, typography/layout controls, adaptive shell and complete Bengali localization remain incomplete.

### F14 — Collaboration and Sharing
- **Purpose/workflow:** Share local content safely and optionally collaborate through a real service.
- **Entry/screens:** Share note/notebook, permissions, comments, public link management.
- **Logic/data:** Share links, permissions, comments, collaborators and change history.
- **Offline/backend:** DEVICE SERVICE for Android share sheet; BACKEND REQUIRED for public links and collaboration.
- **Security:** Explicit visibility/expiry/password/permission controls; revoke links; ownership enforcement.
- **Acceptance/tests:** Local share works offline; remote permission and revocation tests; unauthorized access rejected.
- **Baseline:** PARTIAL — archive export/share capabilities exist; collaboration and public sharing backend are absent.

### F15 — Advanced Note Intelligence
- **Purpose/workflow:** Find relationships, duplicates, broken links and actionable information with reviewable suggestions.
- **Entry/screens:** Related notes, duplicate finder, note health, smart archive, timeline and connection suggestions.
- **Logic/data:** Deterministic local analyzers, derived relationship records and optional AI suggestions.
- **Offline/backend:** LOCAL deterministic features; HYBRID AI enhancements.
- **Acceptance/tests:** Explainable suggestions; user approval before mutation; no false claim of automatic accuracy.
- **Baseline:** PARTIAL — title-based links/backlinks plus deterministic duplicate-title and broken-wikilink checks now exist; semantic similarity, orphan-note analysis and richer review workflows remain incomplete.

### F16 — Developer and Technical Notebook
- **Purpose/workflow:** Store and retrieve code snippets, commands, API notes, diagrams and technical references.
- **Entry/screens:** Code editor/viewer, snippet library, JSON/regex/SQL tools, Mermaid/LaTeX preview.
- **Logic/data:** Code block language metadata, snippet categories and searchable content.
- **Offline/backend:** LOCAL.
- **Security:** Never execute arbitrary shell/code inside the note editor.
- **Acceptance/tests:** Code round-trip, syntax highlighting, copy behavior and safe rendering of untrusted content.
- **Baseline:** PARTIAL — Markdown/code snippet authoring and a basic developer snippet notebook now exist; syntax highlighting, safe language-specific previews and broader technical tools remain incomplete.

### F17 — Unique MindVault Features
- **Purpose/workflow:** Provide a unified memory timeline, thought connections, life archive, inbox, knowledge analytics and portable digital legacy.
- **Entry/screens:** Timeline, thought inbox, connections, archive analytics and full export.
- **Logic/data:** Journal/events, connections, aggregate statistics and portable manifest.
- **Offline/backend:** LOCAL; optional AI suggestions are HYBRID.
- **Acceptance/tests:** Chronological filtering, correct aggregates, relationship integrity and restore-ready export verification.
- **Baseline:** PARTIAL — archive/backup primitives plus a note/task activity timeline and basic local archive aggregates/health checks now exist; richer historical events, productivity trends and legacy export UX remain incomplete.

### F18 — Android-Specific Experience
- **Purpose/workflow:** Integrate widgets, intents, shortcuts, system services and adaptive Android UX.
- **Entry/screens:** Launcher shortcuts, widgets, Quick Settings tile, share receiver, file picker and platform capture.
- **Logic/data:** Platform channels/Android components with lifecycle-safe callbacks.
- **Offline/backend:** DEVICE SERVICE; most local workflows remain LOCAL.
- **Permissions:** Ask only at point of use; handle denial without blocking core notes.
- **Acceptance/tests:** Intent payload validation, background lifecycle, permission denial, keyboard/tablet and accessibility checks.
- **Baseline:** PARTIAL — Android app foundation and file operations exist; widgets, tiles, shortcuts and complete intent integrations need verification.

### F19 — Competitor-Inspired Capabilities
- **Purpose/workflow:** Combine block editing, backlinks, notebooks, quick capture, local-first archive and source-grounded research into one coherent product.
- **Entry/screens:** Cross-feature workflows rather than cloned competitor screens.
- **Logic/data:** Reuse canonical note/task/attachment/board models; avoid duplicate isolated feature stores.
- **Offline/backend:** Inherits the mode of each underlying feature.
- **Acceptance/tests:** Integrated workflows must operate on the same records and respect privacy.
- **Baseline:** PARTIAL — several foundational inspirations are present; advanced workflows are not.

### F20 — Implementation Roadmap
- **Purpose:** Deliver all 22 categories in dependency-aware phases without permanently excluding later requirements.
- **Entry:** `IMPLEMENTATION_ROADMAP.md` and master checklist.
- **Acceptance:** Every phase has entry/exit gates, test evidence, blockers and remaining work.
- **Baseline:** PARTIAL — existing roadmap exists; align it to P0–P5 and this master contract.

### F21 — Production Quality
- **Purpose:** Ensure data safety, reliability, performance, accessibility and reproducible Android builds.
- **Entry:** CI, test suites, diagnostics and release verification.
- **Logic:** Transactions, migrations, indexes, crash recovery, bounded memory, structured logs and artifact provenance.
- **Offline/backend:** LOCAL core; CI requires GitHub Actions.
- **Acceptance/tests:** Real critical workflows, large archive tests, migration/restore tests, static analysis and debug APK.
- **Baseline:** PARTIAL — Android CI and existing tests documented; each current run must be checked against the branch commit.

### F22 — Premium Design System and UI/UX
- **Purpose/workflow:** Deliver consistent, adaptive, accessible interfaces with brand color `#5A0719`.
- **Entry/screens:** Shared theme/tokens/components used by all feature screens.
- **Logic/data:** Central design tokens, theme preferences, localization and responsive breakpoints.
- **Offline/backend:** LOCAL.
- **Acceptance/tests:** Phone/tablet/landscape, Bengali/English typography, accessibility, loading/empty/error/success states.
- **Baseline:** PARTIAL — Material 3 burgundy theme exists; complete tokens/component library and responsive/accessibility audit remain.

## 4. Global completion definition

A category is complete only when every required child workflow has a real entry point, persistent data behavior where applicable, documented offline/backend/security behavior, graceful error handling, acceptance tests and passing verification. A placeholder route, mock button, settings toggle without behavior or unconfigured provider is not completion.

## 5. Dependency and risk decisions

- Keep the currently resolved dependency set until a concrete feature requires a package; verify maintenance, license, Android support, privacy and SDK compatibility before adding it.
- Keep Riverpod as the single state-management approach, GoRouter for routing and Drift/SQLite as the local persistence layer unless a measured compatibility issue justifies a documented change.
- Audit schema foreign keys and migrations before adding broad new entity families.
- Design remote providers behind interfaces; do not select a paid backend without an operational-cost and privacy review.
- Encryption requires a separate threat model, audited authenticated encryption, protected key lifecycle and recovery documentation. PIN gate alone is not encryption.

## 6. Status vocabulary

- **NOT STARTED:** no implementation exists.
- **PARTIAL:** some child workflows exist, but acceptance criteria are incomplete.
- **IMPLEMENTED:** code path and persistent behavior exist.
- **TESTED:** acceptance tests pass on a recorded commit/environment.
- **EXTERNAL BLOCKED:** implementation depends on credentials, service or hardware not available.
- **VERIFIED:** implementation, tests, documentation and delivery evidence all agree.
