# MindVaultArchive — Project Completion Roadmap

Repository: `marufallammahim/MindVaultArchive`  
Target branch: `feature/ultimate-all-in-one-mindvault`  
Last reviewed: 2026-11-13  
Baseline commit reviewed: `a89a4a18074a72ceb6a0d0404a8b370af3e69955`

This roadmap is evidence-based. A feature is not complete merely because a screen or button exists. Completion requires a working UI-to-provider/service-to-storage flow, user-visible loading/empty/error states, and focused tests.

## CI baseline

All three required workflows completed successfully on baseline commit `a89a4a18074a72ceb6a0d0404a8b370af3e69955`:

| Workflow | Result | Evidence |
|---|---|---|
| Feature Branch - Code Check | PASS | Run 43398969671; `flutter analyze` logged `No issues found!` |
| Feature Branch - Regression Tests | PASS | Run 43398969696; `51: All tests passed!` |
| Feature Branch - Android APK Artifact | PASS | Run 43398969673; artifact `MindVaultArchive-debug-136`, 100,738,323 bytes, not expired |

Artifact metadata step passed. APK archive is available from the run's Artifacts section. CI success is not equivalent to physical-device QA.

## Log findings requiring follow-up

| Finding | Evidence | Plan |
|---|---|---|
| Drift warns about multiple `AppDatabase` instances during tests | Regression job 131796761097; repeated Drift warning | Trace all test constructors and executor sharing. The backup test intentionally creates source and target databases; confirm distinct executors and close lifecycle before changing. Do not silence the warning without proof. |
| GitHub Actions Node 20 deprecation | Code Check, Regression, APK job logs | Review action compatibility and migrate supported actions versions in a dedicated workflow change. |
| `actions/setup-java@v4` deprecation | APK job log | Verify v5 compatibility and update in same workflow maintenance milestone. |
| Node `punycode` and `url.parse()` deprecation | APK job log | Identify which action/tool emits it; upgrade only the responsible dependency/action. |
| `cp -n` portability warnings | APK build log | Inspect `tool/regenerate_platforms.sh`; replace with portable, behavior-preserving logic and test reruns. |
| Kotlin Gradle Plugin warning for `file_picker` and `share_plus` | APK build log | Inspect resolved plugin versions and Android Gradle configuration; do not perform broad dependency upgrades without compatibility review. |

## Milestones

### 0. Build and runtime stability — IN PROGRESS
- [x] Correct Editor `prefer_const_constructors` lint.
- [x] Flutter formatting workflow passed on baseline SHA.
- [x] `flutter analyze` passed on baseline SHA.
- [x] Unit/widget regression suite passed (51 tests) on baseline SHA.
- [x] Android debug APK build and artifact upload passed on baseline SHA.
- [ ] Investigate Drift multiple-database warnings and verify executor isolation.
- [ ] Resolve deprecated GitHub Actions runtime/action versions.
- [ ] Resolve shell portability warnings.
- [ ] Review Kotlin/Gradle plugin warnings and apply safe compatibility updates.
- [ ] Repeat all required CI workflows on the final updated branch SHA.

### 1. Shared Neo-Brutalist UI across every route — PARTIAL
Reference direction: warm cream/dotted canvas; palette yellow `#F7CB46`, cream `#FCEFE8`, cyan `#C0F7FE`, green `#99E885`, pale pink `#E9E0E8`; strong high-contrast outlines; hard offset shadows; bold typography; visible focus/pressed/disabled states.
- [ ] Inventory every GoRouter route and screen widget.
- [ ] Audit hard-coded colors, borders, shadows, padding, typography and icon surfaces per screen.
- [ ] Apply shared design tokens and reusable Neo-Brutalist components without changing behavior.
- [ ] Verify Light, Dark and AMOLED contrast and text scaling.
- [ ] Capture emulator screenshots at phone sizes and compare against supplied references; document unavoidable differences.

### 2. Notes, editor and recovery — PARTIAL / VERIFY
- [ ] Trace create/edit/autosave/debounce/retry/save-before-exit end-to-end.
- [ ] Verify title/body typing, cursor/selection, Markdown toolbar and preview.
- [ ] Verify attachments, drawing, linked tasks, color, revisions and restore.
- [ ] Test navigation away/back, app lifecycle interruption and draft recovery.
- [ ] Ensure all editor actions have error/loading feedback and persistence tests.

### 3. Search, tags, categories and organization — PARTIAL / VERIFY
- [ ] Verify FTS5 note/task search, category/tag filtering and empty/error states.
- [ ] Verify create/rename/delete/assign/unassign flows and referential cleanup.
- [ ] Record unsupported semantic search, nested notebooks, smart folders and graph features honestly.

### 4. Tasks and productivity — PARTIAL
- [ ] Verify task CRUD, due date, priority, completion and linked-note persistence.
- [ ] Add validation and tests for edge dates, invalid links and deleted notes.
- [ ] Reminders, recurrence, calendar, habits and project boards remain NOT IMPLEMENTED until local scheduling/storage and platform permission flows are designed and tested.

### 5. Templates, drawing and attachments — PARTIAL / VERIFY
- [ ] Verify built-in/custom template create/use/delete persistence.
- [ ] Verify drawing save-to-note, attachment metadata, file lifecycle and restore.
- [ ] Verify missing/corrupt attachment errors and backup integrity.
- [ ] Document unsupported template variables/import-export and audio/video capture/preview where applicable.

### 6. Backup, restore and revision history — IMPLEMENTED LOCALLY / VERIFY EDGE CASES
- [ ] Verify JSON archive versions, ZIP attachment bytes, SHA-256, safe paths and collision behavior.
- [ ] Test malformed archive, missing file, duplicate ID, interrupted restore and rollback.
- [ ] Verify revision limit, restore semantics and history cleanup.

### 7. App lock, settings and privacy — PARTIAL
- [ ] Verify PIN creation, salted hash, secure storage, retry lockout and lifecycle gate.
- [ ] Ensure UI clearly states this is an app access gate, not database/file encryption.
- [ ] Biometric unlock, PIN recovery and encrypted local database remain NOT IMPLEMENTED until designed and tested.
- [ ] Verify theme mode, AMOLED, accent, categories/tags, archive tools and settings navigation.

### 8. Insights, timeline and remaining routes — VERIFY
- [ ] Inventory all remaining routes including capture, tags, search, history, transfer, insights, timeline, developer notebook, drawing and about.
- [ ] Trace each visible control to a real callback and persisted/local result.
- [ ] Remove dead controls or clearly label unavailable functionality.
- [ ] Add route/widget interaction tests.

### 9. External integrations — BLOCKED / NOT IMPLEMENTED
- AI, cloud sync, collaboration, WebDAV/Nextcloud and multi-device conflict resolution require real providers, authentication, privacy controls and user configuration. Do not fake these features or transmit note contents without explicit consent.
- OCR/PDF indexing and biometric unlock require suitable platform/provider capability and dedicated tests.
- Ask the user when credentials, backend decisions, privacy policy or destructive migrations are required.

## Definition of done

- Every routed screen is inventoried and visually reviewed.
- Every advertised local feature has a complete tested action → provider → service/repository → persistence flow.
- No dead buttons or misleading placeholders remain.
- `dart format`, `flutter analyze`, all unit/widget tests and Android APK build pass on the same latest branch SHA.
- APK artifact and build metadata are verified.
- Actionable warnings are resolved or explicitly justified with evidence.
- Remaining external/backend/device QA blockers are disclosed; no unsupported 100% claim.
