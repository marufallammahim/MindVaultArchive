# MindVaultArchive — Project Completion Roadmap

Repository: `marufallammahim/MindVaultArchive`  
Target branch: `feature/ultimate-all-in-one-mindvault`  
Last reviewed: 2026-11-14  
Baseline validation commit: `a89a4a18074a72ceb6a0d0404a8b370af3e69955`\nLatest workflow-maintenance commit: `25cc51d38b4e04b4d5a6783fd39af033b1a87531`

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
- [x] Upgrade workflow references: checkout v4→v5, setup-java v4→v6, upload-artifact v4→v6 (new versions still require validation on latest SHA).
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


## Workflow action maintenance — 2026-11-13
- Updated all six workflow files to use `actions/checkout@v5`, `actions/setup-java@v6`, and `actions/upload-artifact@v6` where applicable.
- Official action documentation/release notes identify setup-java v1-v4 as deprecated and v6 as current; upload-artifact v6 uses Node 24. See the upstream action documentation and releases.
- The commits generated several intermediate workflow runs which were cancelled by the branch concurrency policy. The most recent observed run was for SHA `468f56dadec6ed49f90ffa5ad2d9c8ce937ece12`, not the latest branch SHA `25cc51d38b4e04b4d5a6783fd39af033b1a87531`. Therefore the action upgrades are NOT yet verified. A fresh complete validation on the exact latest SHA is required.
- CI baseline success on `a89a4a18074a72ceb6a0d0404a8b370af3e69955` remains valid only for that SHA; it does not validate subsequent workflow edits.


## Home display and theme contrast remediation — 2026-11-13

Implementation commit before documentation: `ad3f0265bd63bbb7d27d3a691e8b54d66bad3970`.

- [x] Make the Home `Recent Notes` heading use the active semantic text color.
- [x] Choose readable black/white note-card foregrounds from the actual card color luminance; remove reduced-opacity metadata/body text.
- [x] Use a distinct dark-mode note-card palette and high-contrast outline while retaining the reference palette in light mode.
- [x] Make the bottom dock surface, border and inactive labels follow the active theme; keep the Stats action routed directly to `/insights` using `go`.
- [x] Make the Flutter build-error fallback use the active theme and provide a Return to Home action. The fallback already logs the underlying exception and stack; the precise production exception still needs device logs to identify its originating widget.
- [x] Add semantic ColorScheme container/on-container pairs and consistent IconButton, TextButton, ElevatedButton, text-selection and input foreground styles.
- [x] Add contrast assertions and widget tests for Home rendering in both themes and Stats navigation to Archive Insights.
- [ ] Validate formatting, analyzer, widget/regression tests and APK build on the latest commit after this documentation update.
- [ ] Obtain device log/stack trace if the Home error fallback still appears; emulator/physical-device QA and phone screenshot comparison remain outstanding.

Research basis: Flutter Material 3 defines paired foreground/background color roles (for example `primary` / `onPrimary`) and recommends at least 4.5:1 contrast for text. Official references: Flutter `ColorScheme` API and Flutter theming cookbook. The chosen brand colors were retained, with theme-specific semantic pairings rather than relying on hard-coded black/white text across every surface.


## Feature acceptance test expansion — 2026-11-13

### Newly confirmed Home regressions (run 43406738374, SHA `9c2305f8866f856c1e2c338bcc6371932172bdd6`)
- Home note cards threw a Flutter assertion because `Material` received both `borderRadius` and `shape`. This was an application runtime defect, not merely a test harness issue.
- The Home bottom dock also overflowed vertically by 2 px in the widget-test viewport (RenderFlex at `home_screen.dart:515`).
- The test failed to find the saved note because the NoteCard build crashed; the Stats navigation assertion was consequently not a valid independent proof of navigation.
- The first test run also timed out while widget resources/streams remained mounted. Tests now explicitly unmount their widget trees and close their in-memory database, and use bounded frame pumps.
- Corrections committed after the failed run: remove the conflicting Material borderRadius while retaining the rounded shape; reduce bottom-dock icon/label/padding footprint; expand Home rendering coverage across 320x640, 360x800 and 412x915 viewports in both light and dark themes.
- These corrections are awaiting CI verification on the latest branch SHA. Do not mark the Home regression closed until the widget test passes.

### Current automated coverage inventory
Existing test files cover database CRUD/relations/revisions, task database operations, editor-provider autosave/reload, Markdown toolbar, search service, JSON and ZIP backup services, app-lock service/gate, startup, theme contrast, Home (new screen-level test), and user profile persistence.

### Screen-level acceptance matrix — pending unless explicitly evidenced by a passing test
| Area | Acceptance checks to add/verify |
|---|---|
| Home | Empty/loading/error/saved-note states; light/dark/AMOLED; 320/360/412 logical-pixel widths; note open; pin/favorite/archive/trash actions; categories/filters; Stats route; no overflow or uncaught exception |
| Editor | New and existing note; title/body typing; cursor/selection; Markdown formatting/preview; autosave debounce; save-before-exit; reload/recovery; attachment validation; share/export; category/color; linked task; revision/drawing routes |
| Tasks | Create/edit/delete; complete/uncomplete; priority; due date; linked note; invalid/empty title; completed filter; narrow screen; persistence after remount |
| Search | Title/body/task/tag/category; case/prefix/wildcard behavior; empty/no-result/error; deleted item exclusion; open selected result |
| Tags/categories | Create/rename/delete; assign/unassign; duplicate/empty names; detach references safely; persistence and filtering |
| Quick Capture | Draft restore after remount; title-only/body-only; empty validation; save and open editor; clear draft only after successful persistence |
| Templates | Built-in template creates note with exact starter content; custom create/edit/delete; malformed preferences; search/filter; persistence after restart |
| Drawing/attachments | Undo/redo/clear; empty drawing validation; PNG file written; attachment metadata points to file; restore/backup includes bytes; missing file failure |
| Archive transfer | JSON round-trip; version mismatch; malformed JSON; ID collisions; referential integrity; ZIP hash/path traversal/duplicate/missing attachment; interrupted restore/rollback |
| Revision history | Snapshot creation; order/limit; restore old content; deleted note/missing revision; route back to correct editor |
| Trash | Soft delete; restore; permanent-delete confirmation; attachments/revisions cleanup; deleted notes excluded elsewhere |
| Insights/timeline | Empty and populated archive; task counts; duplicate title/wikilink detection; date boundary; note navigation |
| Settings/profile | Theme mode, AMOLED, accent, display name/avatar, category management, archive tools route, settings persistence |
| Protector | Enable/change/disable PIN; invalid PIN; retry lockout; secure-store unavailable; app background/resume; disclose it is not data encryption |
| Developer notebook/About/Splash | All actions and links; empty/error states; startup route and first-run setup; no inert controls |
| Responsive/accessibility | 320/360/412/768 widths; large text scaling; keyboard insets; touch target/semantics; light/dark/AMOLED; contrast and overflow checks |

### Validation policy
- Run focused tests for each changed feature, then the complete `flutter test --reporter expanded` suite.
- Run `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, and the Android APK build against the exact same SHA.
- Add route-level widget tests and UI interaction/persistence tests; service/database tests alone are not evidence that visible buttons work.
- Inspect logs for uncaught widget exceptions, RenderFlex overflow, asynchronous errors, database warnings and plugin channel failures. Never suppress a warning or loosen an assertion to obtain a green run.
- Keep emulator/physical-device acceptance as a separate required check. CI APK build success alone does not prove runtime behavior on a phone.
- Any feature requiring a real backend, provider, permission or platform capability must be marked blocked/not implemented until that dependency exists; do not replace it with fake success.


## Latest implementation and CI review — 2026-11-14

### Reviewed branch and commits

- Repository: `marufallammahim/MindVaultArchive`
- Branch: `feature/ultimate-all-in-one-mindvault`
- Source head before this workflow/roadmap synchronization: `1aaecefbf45ab9d9348ad804dc57c00b58050c03`
- Pre-format test-fix source: `882c5d19e4b3cbee8ee58f21a554fb36f04f2d7a`
- The Code Check workflow run `43570404964` completed successfully on `882c5d19`; `flutter analyze` reported `No issues found!`. Its format step changed `test/feature_ui_workflow_test.dart` and generated `lib/core/database/database.g.dart`, then committed those formatting changes as `1aaecefb`. Because the run created a new commit, it does not count as validation of `1aaecefb`.

### Required workflow state

| Workflow | Run | SHA | Result at review | Interpretation |
|---|---:|---|---|---|
| Feature Branch - Code Check | 43570404964 | 882c5d19 | PASS | Analyzer clean; formatter created a new commit, so rerun on the new head is required |
| Feature Branch - Regression Tests | 43570405016 | 882c5d19 | IN PROGRESS | No pass/fail conclusion available at review; cannot count as success |
| Feature Branch - Android APK Artifact | 43570405019 | 882c5d19 | IN PROGRESS | No artifact available for this run at review |
| Previous Regression Tests | 43425554560 | d6349918 | CANCELLED | Four widget tests reached the 10-minute test timeout; later `!inTest` errors were cascade failures |
| Previous Android APK Artifact | 43425554635 | d6349918 | PASS | Artifact `MindVaultArchive-debug-184`, 100,739,691 bytes; expires 2026-12-13. This is not the latest branch SHA |

### Regression-test investigation

Run `43425554560` logged:
- Quick Capture local-save widget test: `TimeoutException after 0:10:00`.
- Tasks create/update widget test: `TimeoutException after 0:10:00`.
- Home responsive render widget test: `TimeoutException after 0:10:00`.
- Drawing missing-note widget test: `TimeoutException after 0:10:00`.
- Tags persistence test wrote one tag to the database, but asserted the stream-rendered label before pumping the updated widget frame.
- The suite was cancelled at the 45-minute job limit. The follow-on `!inTest` assertions are consistent with a timed-out widget test leaving the binding active; they are not independent product failures.

Changes made on the feature branch before the formatter commit:
- Widget polling now pumps frames before awaiting conditions.
- Database and SharedPreferences reads in the affected widget tests use `tester.runAsync` so real asynchronous executor/plugin work can complete outside the fake-async zone.
- Home's initial database fixture and Drawing's persistence/error assertions were made explicitly bounded.
- Tags now pumps the stream frame after the database write before asserting the rendered tag.

These changes are diagnostic/remedial test-harness changes only. They are NOT accepted as fixes until the regression workflow passes on one exact latest SHA.

### Workflow reproducibility correction

The required workflows previously ran `dart fix --apply --code=migrate_design_widgets` in their working trees, while only Code Check could commit the resulting modifications. This meant Regression Tests and APK could validate a modified workspace rather than the exact checked-out commit. The Code Check workflow also auto-formatted and pushed a commit, which prevented the other workflows from automatically validating that new head.

The workflow files are being changed to:
- Make all required checks read-only (`contents: read`).
- Remove the already-applied design migration from CI.
- Verify generated Drift/Riverpod sources with `git diff --exit-code -- lib`.
- Check formatting with `dart format --output=none --set-exit-if-changed lib test`.
- Keep analysis, regression tests and APK build in their dedicated workflows.

A new push after this change must produce all three required runs on the same SHA. No workflow result from a different SHA may be combined into a final pass.

### Warning status

- Drift multiple-`AppDatabase` warning: tests create separate `NativeDatabase.memory()` executors and close their instances in test teardown. Drift's current warning implementation increments a counter by database runtime type rather than comparing executor identity; therefore the warning alone does not prove executor sharing. Do not suppress it globally. Confirm all test teardown and executor lifecycles before deciding whether a narrowly scoped test-only setting is justified. Upstream implementation: https://github.com/simolus3/drift/blob/develop/drift/lib/src/runtime/api/db_base.dart
- Riverpod generator warning on `test/feature_ui_workflow_test.dart`: still needs investigation.
- Shell portability: `tool/regenerate_platforms.sh` still uses `cp -Rn`; replace only after validating a portable no-overwrite equivalent.
- Kotlin/Gradle plugin warnings: inspect resolved `file_picker` and `share_plus` versions and AGP/Kotlin compatibility before any upgrade.
- GitHub action references already use checkout v5, setup-java v6 and upload-artifact v6; confirm the next clean logs for any remaining Node runtime deprecation warnings.

### Screen and feature acceptance state

The detailed 19-route inventory and source-level visual gaps are recorded in `docs/UI_FUNCTIONALITY_AUDIT.md` (2026-11-14 reference review). All screens remain subject to visual QA; no pixel-identical claim is made. Local features remain partial until each action → provider/controller → service/repository → persistence path has success, error, edge-case and remount tests. External provider/platform features remain blocked as specified above.
