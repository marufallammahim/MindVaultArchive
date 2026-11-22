# MindVaultArchive — Project Completion Roadmap

Repository: `marufallammahim/MindVaultArchive`  
Target branch: `feature/ultimate-all-in-one-mindvault`  
Last reviewed: 2026-11-19  
Baseline validation commit: `a89a4a18074a72ceb6a0d0404a8b370af3e69955`  
Latest source SHA reviewed: `ce7bd6a8eb60d4b8fd98354b4a54eb2a794e97a6`

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
- [x] Replace non-portable cp -n scaffold copying with copy_missing_tree using find -print0 and guarded cp -pP; Linux runner validation is still required.
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


## CI follow-up — generated Drift binding and shell portability (2026-11-14)

Latest source head at investigation: `417d4a6d3a419e5e46120f6bd3198da861338b11`.

- Code Check run `43570818043` and Regression Tests run `43570818059` failed before formatting/analyzer/tests because `dart run build_runner build --delete-conflicting-outputs` regenerated only `lib/core/database/database.g.dart`. The GitHub job log's sole diff header was `diff --git a/lib/core/database/database.g.dart b/lib/core/database/database.g.dart`; the generated binding was stale relative to locked `drift_dev 2.21.2`. This is generated output, not a manually edited repository file.
- Android APK run `43570818099` failed at the same generated-source check before Gradle build or artifact upload. No APK was produced for SHA `417d4a6`.
- The Code Check workflow is being changed to format and commit only this one generated Drift binding on branch pushes, while rejecting any other generated-source mutation. Regression and APK workflows remain read-only and require the generated binding to be committed before they proceed. After the generated-file commit, create a new feature-branch commit to trigger all three checks on the new exact head; do not combine statuses from earlier SHAs.
- The APK log confirmed two portability warnings from `cp -Rn`: GNU `cp` warns that `-n` behavior is non-portable. `tool/regenerate_platforms.sh` is being changed to copy each missing scaffold file with an explicit existence check and portable `cp -pP`, preserving existing app files.
- The same build log emitted `riverpod_generator`'s analyzer compatibility warning: analyzer `6.4.1` language version `3.4.0` versus Dart SDK language version `3.14.0`; locked `riverpod_generator` is `2.3.10`. Do not add analyzer `14.7.0` alone without checking generator/linter constraints. A coordinated dev-toolchain update needs its own compatibility review.
- The APK job did not reach Gradle, so file_picker/share_plus Kotlin/Gradle warnings are not yet re-evaluated on this source head.


## Flutter 3.50 generated configuration follow-up — 2026-11-14

The failed Code Check log for run `43571130076` showed that `flutter pub get` explicitly printed `Upgrading analysis_options.yaml to exclude build and platform directories.` The resulting tracked-file change was therefore an expected Flutter SDK tooling migration, not an unexpected app-source edit. The generated-source diff also showed only `lib/core/database/database.g.dart`.

The Code Check workflow is now scoped to allow and commit exactly:
- `analysis_options.yaml` (Flutter's generated analyzer exclude configuration)
- `lib/core/database/database.g.dart` (Drift binding regenerated from the locked `drift_dev 2.21.2`)

Any other changed file still fails the scope guard. Regression and APK workflows now explicitly require the analyzer config and generated Drift binding to already be committed before running tests/build. The next Code Check run may create a generated-file commit; if it does, re-read the branch head and trigger a fresh three-workflow validation on that exact new SHA.


## Screen dependency and acceptance map — 2026-11-14

This map records the observed presentation-to-data dependencies. A route or provider reference alone is not acceptance evidence; each listed action still needs a passing success/failure/persistence test.

| Screen | Status | UI/controller and navigation | Data/service dependency | Required acceptance evidence |
|---|---|---|---|---|
| Splash | Partial | Splash state and GoRouter navigation to Home | AnimationController; startup route | Cold start, first frame, reduced motion, no stuck splash |
| Home | Partial | Home screen callbacks; routes to Search, Trash, Editor, Tasks, Insights, Settings | `databaseProvider` note/category streams; `userProfileProvider` profile preference | Empty/loading/error/populated; filters; note actions; responsive widths; theme modes |
| Editor | Partial | Title/body controllers; Markdown toolbar/preview; task, drawing, history and trash routes | `databaseProvider` notes, revisions, tasks and attachment metadata; local file services | Autosave/reload/recovery; save-before-exit; formatting; attachment errors; all visible actions |
| Tasks | Partial | Create/edit/delete/complete controls; linked-note navigation | `databaseProvider` tasks and notes | CRUD, priority, due date, invalid title, completed filter, remount persistence |
| Delete confirmation | Partial | Confirm/cancel route from Trash | `databaseProvider` note/trash lifecycle | Confirm deletes only selected note; cancel preserves note; attachment/revision cleanup |
| Drawing | Partial | Signature canvas and save/undo/redo/clear controls | `databaseProvider`; SignatureController; path_provider; PNG file I/O | Empty drawing; save; missing note; file-write failure; backup/restore bytes |
| Quick Capture | Partial | Title/body input and save/open-editor navigation | SharedPreferences draft keys; `databaseProvider` note save | Title-only/body-only; empty validation; draft remount; clear only after successful save |
| Search | Partial | Query field, result selection, task navigation | `ArchiveSearchService`; SQLite FTS5; `databaseProvider` tags/categories | Title/body/task/tag/category; empty/error; deleted exclusion; open correct result |
| Tags | Partial | Create/rename/delete controls | `databaseProvider` tags and note-tag join table | Duplicate/empty names; assign/unassign; filter; delete safely; remount persistence |
| Templates | Partial | Built-in/custom template selection and note creation | Local template preferences; `databaseProvider` note creation | Five built-ins; custom create/edit/delete; malformed preference recovery; exact starter content |
| Archive tools | Partial | Import/export/backup/restore controls | ArchiveTransferService; FullBackupService; FilePicker; SharePlus; filesystem | JSON v1-v5 round-trip; ZIP hashes; collision/path traversal; missing attachment; rollback |
| Revision history | Partial | Revision list and restore action | `databaseProvider` note_revisions and note content | Snapshot order/limit; restore and editor reload; deleted/missing note |
| Trash | Partial | Restore/permanent-delete actions | `databaseProvider` notes, revisions and attachment metadata/files | Soft delete; restore; permanent-delete confirmation; related-file cleanup |
| Settings | Partial | Theme/AMOLED/accent/profile/category/tag/archive/app-lock controls | themeModeProvider; amoledThemeProvider; accentColorProvider; userProfileProvider; `databaseProvider` | Preference persistence; invalid HEX; profile update; category/tag CRUD; navigation |
| App lock settings | Partial | PIN enable/change/disable and gate | AppLockService; FlutterSecureStorage; app lifecycle | Enable/change/disable; invalid PIN; lockout; storage unavailable; resume behavior |
| Insights | Partial | Metrics cards and local report views | `databaseProvider` note/task streams | Empty/populated counts; date boundaries; no duplicate counting |
| Timeline | Partial | Chronology list and note navigation | `databaseProvider` note timestamps | Empty/populated; ordering; date boundaries; open selected note |
| Developer notebook | Partial | Snippet create/open/editor navigation | `databaseProvider` local snippet/note data | Create/edit/delete; empty/error; persistence; open correct editor |
| About | Implemented static | Static information and links | No mutable persistence dependency | Links work; text scaling; contrast; responsive layout |

### External and platform boundaries

- App lock is a local PIN access gate, not database/file encryption; biometric unlock and PIN recovery remain unavailable.
- AI, cloud sync, collaboration, OCR/PDF indexing, calendar, reminders, recurrence and habits remain blocked until real providers, permissions, backend/authentication, privacy controls and product decisions exist.
- No feature may display a success state for an unavailable external operation.

## Latest generated-source milestone — 2026-11-14

- Code Check run `43571321476` completed successfully on source SHA `f18e112075fa4c3083d120a03cff2cf495a19bc2`: Drift/Riverpod generation, generated-file formatting, scope guard, Dart formatting and `flutter analyze` all passed.
- That run committed Flutter 3.50 analyzer configuration and the regenerated Drift binding in commit `218a05a5eb442387b0af182f8b091cd7a045c80e`. This new head is not yet validated by all three required workflows.
- Regression run `43571320690` and APK run `43571320735` on `f18e1120` stopped before tests/build because Flutter's `flutter pub get` updated `analysis_options.yaml` while Code Check was generating the commit. They are not product test or Gradle failures.
- The next push will trigger fresh Code Check, Regression Tests and Android APK Artifact runs on one exact head. Require all three to finish on that same SHA before claiming CI success.

## Toolchain warning assessment

- Flutter CI uses Flutter 3.50.0 / Dart 3.14.0. Locked versions include `file_picker 10.3.10`, `share_plus 10.1.4`, `riverpod_generator 2.3.10`, and `analyzer 6.4.1`.
- The successful older APK log still reports app/plugin Kotlin Gradle Plugin usage from the app module, `file_picker` and `share_plus`. This is a future compatibility warning, not a current build failure. The app module still applies `kotlin-android`.
- Flutter's built-in Kotlin migration requires Flutter 3.47+ for enabling the feature and requires every Android plugin to be compatible. `share_plus 13.3.1` documents built-in Kotlin support when enabled; `file_picker` 12.x moved to a federated Android plugin that reads the `android.builtInKotlin` flag. These newer majors also require Dart API migrations, so do not bump dependencies or AGP/Gradle in isolation. Review and test the coordinated upgrade after the current CI/test baseline is green:
  - Flutter guide: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers
  - share_plus changelog: https://pub.dev/packages/share_plus/changelog
  - file_picker changelog: https://pub.dev/packages/file_picker/changelog
  - file_picker built-in Kotlin behavior in 12.x: https://github.com/vicajilau/flutter_file_picker/issues/2200
- Riverpod generator still warns that analyzer 6.4.1 supports language version 3.4.0 while CI Dart SDK is 3.14.0. Do not add analyzer 14.7.0 alone until Riverpod generator/linter constraints are reviewed and a coordinated dev-toolchain update is tested.
- The shell scaffold-copy helper now uses explicit no-overwrite checks and `cp -pP` instead of `cp -Rn`. A local shell simulation verified that existing app files are preserved, missing files copied and symlinks retained. The next APK workflow must confirm the actual scaffold path is warning-free.
- No Node 20 deprecation message was found in the inspected logs. Checkout v5, setup-java v6 and upload-artifact v6 are in use; recheck future logs for transitive action warnings.


## CI workspace parity correction — 2026-11-14

Latest reviewed source head: `07ceaea7c7092e8617fbebffdd83eb706246de41`.

- Code Check run `43571583958` passed on `07ceaea7`, but it did not create a new commit.
- Regression run `43571583951` stopped before tests because `build_runner` output for `lib/core/database/database.g.dart` was not formatted before the generated-file diff check. Code Check already normalizes this generated binding before checking/committing it.
- APK run `43571583939` stopped before Gradle because `tool/regenerate_platforms.sh` created the missing iOS scaffold before `flutter pub get`; Flutter then upgraded `analysis_options.yaml` to exclude the newly present platform directories. Code Check and Regression had not generated the same platform scaffold, so their working trees were not equivalent.
- Corrective workflow change: all three workflows now run `bash tool/regenerate_platforms.sh` before `flutter pub get`; Regression and APK also run `dart format lib/core/database/database.g.dart` before comparing generated output. This makes platform files, Flutter's analyzer config migration and generated Drift formatting consistent across the three jobs.
- The tests have still not run on a fully synchronized SHA after the widget-test harness changes. The next three runs must complete on one exact head; no skipped test step counts as success.


## Current branch review — 2026-11-14

### Exact source and CI state

Latest branch head reviewed: 604b1d98fc2e32d2c1485c882ce9fa1745847ebc.

| Workflow | Run / SHA | Result | Interpretation |
|---|---|---|---|
| Format Dart Sources | 43574945773 / parent c3630a3b1c23bd43c9e4319061415ffb4d0472e4 | PASS | Formatter committed two required Dart formatting changes as latest SHA 604b1d98fc2e32d2c1485c882ce9fa1745847ebc. |
| Feature Branch - Code Check | 43574945899 / c3630a3b1c23bd43c9e4319061415ffb4d0472e4 | FAIL at format step | Build generation passed; format check found editor_screen.dart and markdown_toolbar.dart unformatted. Analyzer was skipped. |
| Feature Branch - Android APK Artifact | 43574945830 / c3630a3b1c23bd43c9e4319061415ffb4d0472e4 | FAIL at format step | Native scaffolding, dependencies and generation passed; APK build and upload were skipped. |
| Feature Branch - Regression Tests | Latest SHA | NOT RUN | Deliberately gated until all routed UI work is complete. |

The latest formatter commit was created by the workflow bot and did not trigger downstream Code Check/APK workflows. Validation on the exact latest SHA is still required. No test pass or APK artifact is claimed for this source state.

### Actionable warning review

- Scaffold copy portability: source now uses guarded copy_missing_tree with find -print0 and cp -pP, preserving existing app files and avoiding cp -n. Awaiting runner execution on the latest SHA.
- GitHub Actions runtimes: workflow references have been migrated to checkout v5, setup-java v6 and upload-artifact v6 where used. Latest-SHA validation and warning-log review remain pending.
- Riverpod generator/analyzer compatibility: build_runner reports analyzer language version 3.4.0 against SDK language version 3.14.0 and recommends analyzer 14.7.0. Do not pin analyzer alone: current Riverpod generator/lint stack is older and may constrain analyzer. Review a compatible Riverpod generator, riverpod_lint, custom_lint and analyzer upgrade as one dependency set after UI completion.
- Drift multiple-database warning: the full-backup test intentionally opens source and target databases with separate NativeDatabase.memory() executors and closes both in tearDown. This is a legitimate two-database restore test, not evidence of a shared executor. Confirm the remaining warning against a fresh regression log before changing lifecycle code.
- Kotlin/Gradle warnings: no broad Gradle/Kotlin upgrade was made. Reassess only from the next successful APK log and resolved plugin versions.

### Routed-screen implementation matrix

Status reflects source review, not screenshot/device QA. A screen remains partial until its visible controls and persistence paths have focused tests.

| Screen / route | Status | Evidence and remaining acceptance |
|---|---|---|
| Splash / | Partial | Branded cream/yellow entry; startup and first-run/device QA remain. |
| Home /home | Partial | Profile, search, filters, note cards and dock; home_screen_test.dart covers phone sizes and light/dark rendering; screenshot and all-action tests remain. |
| Editor /editor/:id | Partial | Autosave, Markdown toolbar, preview, attachment, linked tasks, revisions, color, drawing and Trash; editor/provider/toolbar tests exist; overflow actions and recovery edge cases remain. |
| Tasks /tasks | Partial | Local CRUD, due dates, priority, linked notes, completion and progress/calendar view; DB and feature workflow tests exist; date/time boundary and complete UI interaction tests remain. |
| Delete confirmation /delete/:id | Partial | Confirm/cancel plus two-hand/cable custom painter; route and destructive-flow tests remain. |
| Drawing /drawing/:id | Partial | PNG attachment save and undo/redo/clear controls; drawing screen test exists; corrupt/missing attachment and file cleanup tests remain. |
| Settings /settings | Partial | Theme, AMOLED, accent, profile, category/tag and archive links; theme/profile tests exist; full persistence/accessibility matrix remains. |
| About /about | Implemented static | Static app/privacy/developer details; link and responsive visual QA remain. |
| Trash /trash | Partial | Restore/permanent-delete DB operations; shared hero and branded empty/list states; attachment/revision cleanup tests remain. |
| Templates /templates | Partial | Five built-ins and custom local templates; Neo-Brutalist palette cards/hero; custom preference corruption and create/use/delete widget tests remain. |
| Quick Capture /capture | Partial | Local draft persistence and save/open-editor flow; feature workflow tests exist; process-restart and failure-path tests remain. |
| Tags /tags | Partial | Local create/rename/delete; feature workflow test exists; note assignment/filtering and error tests remain. |
| Revision History /history/:id | Partial | Drift snapshots and restore; DB/editor-provider tests exist; screen navigation and restore error tests remain. |
| Search /search | Partial | FTS5 note/task search with category/tag metadata; search service tests exist; result opening, empty/error/loading widget tests remain. |
| Protector /app-lock | Partial | Salted PIN hash, secure storage, cooldown and app gate; service/gate tests exist; biometric, PIN recovery and encryption are explicitly unavailable. |
| Archive Tools /archive-tools | Partial | Versioned JSON transfer and ZIP backup/restore; service tests exist; full UI import/export and rollback acceptance remains. |
| Insights /insights | Partial | Local note/task aggregates, duplicate title and broken wikilink checks; UI aggregate/date-boundary tests remain. |
| Timeline /timeline | Partial | Local note/task chronology and editor navigation; empty/date ordering widget tests remain. |
| Developer Notebook /developer-notebook | Partial | Snippet create/open using canonical note records; edit/delete and widget tests remain. |

### UI milestone recorded in this review

- [x] Shared FeatureHero is flat yellow with cyan icon tile, black keyline and hard offset shadow.
- [x] Home, Tasks and Splash use the reference palette and preserve existing callbacks/navigation.
- [x] Templates, Protector and Trash received a source-level Neo-Brutalist pass without changing their storage/service contracts.
- [x] Delete confirmation now paints the two-hand/cable motif instead of generic symbols.
- [x] Editor app-bar actions are grouped into an overflow menu; Markdown controls use the shared palette.
- [ ] Compare all 19 routed screens against the supplied images on an Android emulator/phone; no pixel-identical claim until this is done.
- [ ] Add focused tests for every new/changed visible control after UI implementation is complete.
- [ ] Finish remaining screen-by-screen redesign and responsive/text-scale/focus/pressed-state QA.

### Feature-level blockers

AI, cloud sync, collaboration, OCR/PDF extraction, biometric unlock, PIN recovery, encrypted database/files, reminders, recurrence, calendar and habits remain NOT IMPLEMENTED/BLOCKED pending actual provider, platform capability, credentials, privacy design or product decisions. The local foundation must remain usable without those integrations.


## 2026-11-15 secondary-screen UI milestone and validation snapshot

### Implementation commits
- `299477616deb0f77b7afae45ee76e41613b4f76c`: introduced the shared `NeoBrutalistPanel` and applied it to Archive Transfer, Search, Tags, Revision History, Insights, Timeline and Developer Notebook. Empty states were brought into the same hero/panel hierarchy; Search input now uses the shared input radius. Tag deletion errors are presented to the user.
- `add9b448ae32f0bb85c3860d2497245a9ff642b3`: corrected an extra closing delimiter in the Insights metric widget and removed duplicated archive-format guidance from Archive Transfer.
- `722fa155f3c0d6899b8db9c74ed56923d041c179`: formatter-generated commit after `dart format lib test` changed seven Dart files. This is the source head reviewed before this roadmap update.

### CI evidence and exact-SHA rules
- Formatter run `43690087164` succeeded on parent SHA `add9b448ae32f0bb85c3860d2497245a9ff642b3`; it formatted seven files and committed the result as `722fa155f3c0d6899b8db9c74ed56923d041c179`.
- Code Check run `43690087230` and Android APK run `43690087159` were started on `add9b448`, not on the formatter-created head `722fa155`; they do not validate the latest source SHA and must not be combined with results from another SHA.
- No Code Check, Regression Tests, or Android APK Artifact success is recorded for `722fa155` at this snapshot.
- Regression Tests were not dispatched because the routed-screen UI work remains incomplete and the workflow is intentionally manual. No test pass is claimed.
- The older SHA `a91d069faff541ad58709ca443ff41174701be32` did have Code Check run `43575879817` and Android APK run `43575879729` pass, but those results do not validate later UI commits.

### Verified older debug artifact
The APK artifact from run `43575879729` was downloaded and inspected:
- Artifact: `MindVaultArchive-debug-216-a91d069faff541ad58709ca443ff41174701be32`, ID `14106472916`, 100,764,366 bytes, not expired at inspection.
- ZIP contents: `MindVaultArchive-debug.apk`, `SHA256SUMS.txt`, `build-info.txt`.
- Build metadata: branch `feature/ultimate-all-in-one-mindvault`, commit `a91d069faff541ad58709ca443ff41174701be32`, version `1.0.0+1`, `build_type=debug`, `installable=true`.
- APK size: 182,394,365 bytes. APK SHA-256: `632025d7887b5b7c5fef74f47ceecb832e7291e39d63d8cbdc387f4d148cc1b8`.
- Artifact ZIP digest: `690e2babf345eab05c9c9ae8826ec628b8739a4d8427f90522fe2c1dd77d25f1`.
- This artifact belongs to `a91d069f`, not the latest UI code.

### Workflow and warning maintenance
- The formatter workflow is now configured to auto-run only on `main`; feature-branch formatting is enforced by Code Check. This prevents a formatter bot commit from racing and invalidating the Code Check/APK runs on the preceding feature-branch SHA. Manual `workflow_dispatch` remains available.
- On the older passing APK log, `tool/regenerate_platforms.sh` completed without the prior `cp -Rn` portability warning. The guarded copy helper remains in place.
- No Node 20 deprecation warning was found in the inspected current Code Check/APK logs; workflows use checkout v5, setup-java v6 and upload-artifact v6.
- The Riverpod generator warning remains: locked analyzer language version 3.4.0 versus Dart SDK language version 3.14.0. Do not upgrade analyzer alone; coordinate Riverpod generator/lint/analyzer compatibility.
- The APK log still reports Kotlin Gradle Plugin usage by the app module, `file_picker` and `share_plus`. A coordinated built-in-Kotlin migration is deferred until the resolved plugin majors and Dart API changes can be upgraded and validated together.
- Drift multiple-`AppDatabase` warnings were not re-evaluated on this latest UI source because Regression Tests were not run. The existing full-backup test creates separate in-memory executors for source/target and closes both in tearDown; keep this as a pending verification rather than marking the warning resolved.

### Remaining acceptance
- All 19 routed destinations still require final per-screen control/state review; the source-level inventory is not device visual QA.
- Settings, Protector, Trash, Drawing and the primary Home/Editor/Tasks/Splash routes still need a final shared-panel/interaction-state review where applicable.
- No emulator or physical-device screenshot comparison has been captured. Pixel-identical replication is not claimed.
- Regression tests, full local-feature success/failure/persistence acceptance, and Android artifact verification on the same latest commit remain outstanding.


## 2026-11-16 About and Drawing visual pass

### Source changes
- `adfa1b56be9cf7793148c051c4a1c1550f31df21`: redesigned About and Drawing using the shared Neo-Brutalist language.
- `0a087090637d3f54e35ada997aff3c2ec9a72e97`: added the missing FeatureHero test import before validation.
- `7256072b73e342c3c1a239398ae3f7c8dddf22dc`: temporarily enabled the existing formatter on the feature branch so the three changed Dart files could be formatted.
- Formatter run `43831982387` passed and created formatting commit `8c71bc6046a453c452c6a3ed57cca60f4ab72a85`. The formatter trigger is restored to main-only in the following documentation/CI maintenance commit to avoid permanent formatter-bot race conditions.

### UI implementation evidence
- **About**: the supplied app logo now sits in a yellow brand panel with a hard shadow; developer and GitHub details share an outlined information panel; privacy/local-storage messaging uses a cyan panel. The GitHub profile copy action now confirms success with a SnackBar. Static content remains local and no remote service is implied.
- **Drawing**: the signature canvas now sits inside a hard-shadow NeoBrutalistPanel; undo/redo/clear controls use outlined palette buttons. The drawing canvas and exported PNG now consistently use a light surface with dark ink so marks remain visible in both app themes.
- Drawing save behavior is unchanged: active-note validation -> PNG export -> app documents file -> Drift attachment row; a failed database insert removes the newly created file. Full ZIP backup already reads registered attachment files and stops if one is missing.
- Added About visual/interaction-presence coverage and expanded Drawing screen visual assertions. These tests have not been executed because routed UI implementation remains incomplete.

### Exact-SHA CI and artifact evidence
- Baseline source SHA `0371ed562efb60aa0d1065f6aef9c6aa39e069e7`: Code Check run `43690233240` PASS; Android APK Artifact run `43690233332` PASS.
- Artifact `MindVaultArchive-debug-219-0371ed562efb60aa0d1065f6aef9c6aa39e069e7`, ID `14151633313`, was downloaded and inspected. ZIP contains the debug APK, `build-info.txt`, and `SHA256SUMS.txt`. Metadata confirms branch `feature/ultimate-all-in-one-mindvault`, commit `0371ed562efb60aa0d1065f6aef9c6aa39e069e7`, version `1.0.0+1`, debug build, and `installable=true`. APK size is 182,396,341 bytes and SHA-256 is `93d10250e38dc269285b0ca6172be6d69e7c47ea3d827640ae6c5d2c9b37414f`.
- Code Check run `43831530062` on `0a087090637d3f54e35ada997aff3c2ec9a72e97` failed only at the Dart formatting gate; analyzer was skipped. Formatter run `43831982387` formatted the three files and passed on parent `7256072b73e342c3c1a239398ae3f7c8dddf22dc`, producing `8c71bc6046a453c452c6a3ed57cca60f4ab72a85`.
- Code Check/APK runs started on `7256072b73e342c3c1a239398ae3f7c8dddf22dc` do not validate the formatter-created SHA. A fresh Code Check and APK run on the post-roadmap latest SHA is required.
- Regression Tests remain intentionally undispatched until routed UI implementation is complete. No test-suite pass is claimed.

### Warning status
- Latest inspected successful Code Check/APK logs on `0371ed56` showed no Node 20 deprecation, setup-java v4, or `cp -n` portability warning.
- Riverpod generator still warns that locked analyzer 6.4.1 exposes language version 3.4.0 while the Flutter 3.50.0 SDK uses 3.14.0. Analyzer 14.7.0 is suggested, but a coordinated Riverpod generator/lint/analyzer compatibility upgrade is required; analyzer-only override is unsafe.
- Android build still warns that the app module, `file_picker`, and `share_plus` apply the Kotlin Gradle Plugin. Built-in Kotlin migration remains deferred until plugin support and Gradle compatibility are verified together.
- Drift multiple-database lifecycle warnings remain unverified because Regression Tests have not been run on the current UI state.

### Route matrix update
- About /about: **implemented static content; visual QA pending**. Branded panels, developer identity, privacy disclosure and GitHub copy feedback are present. Acceptance: run the new widget test, verify light/dark/text-scale rendering and inspect the copy SnackBar.
- Drawing /drawing/:id: **partial**. Shared panel and palette controls are present; attachment persistence and cleanup remain source-verified. Acceptance: execute the new widget test, test successful PNG/file/row persistence, empty canvas, missing/deleted note, file-write failure, database failure cleanup, and ZIP backup restore.

### Remaining UI work
Settings, Protector, Templates, Trash, Quick Capture, Home, Editor, Tasks, Splash, Delete Confirmation and the remaining secondary routes still need the final shared-style/control-state pass and/or screenshot comparison. All 19 routes still require final responsive/accessibility review. No emulator or physical-device screenshot comparison has been performed; pixel identity is not claimed.


## 2026-11-17 Settings UI milestone and exact-SHA CI snapshot

### Settings implementation
- Source commit `d30f7f35791de9164f8a8666d4f05b15eac6cdd0`: added the shared FeatureHero and NeoBrutalistPanel surfaces to Settings profile, appearance, category management, archive navigation and storage information.
- Accent palette controls now have 42px targets, accessible labels/tooltips, selected semantics and contrast-aware check marks.
- Category list now exposes loading, error and empty states; add/rename/delete still call the existing Drift database methods.
- Test commits `cff8da5057b6bdfc6baf681fa2b7c55f47d4e812` and `653f5699bd3ebee4361d78789c8cc64572670eb0` add `test/settings_screen_test.dart` for narrow-screen layout, panel presence, accent preference persistence and category create/rename/delete persistence. The test is not run until all routed UI implementation is complete.
- No database schema, migration, route or provider contract changed.

### Verified workflow state before this Settings milestone
Exact source SHA: `f2fae00276536124128d2ddfa4a0269507513f06`.
| Workflow | Run | Result | Evidence |
|---|---:|---|---|
| Feature Branch - Code Check | 43832286246 | PASS | All generation, generated-file checks, Dart format and `flutter analyze` steps completed successfully. |
| Feature Branch - Regression Tests | — | NOT RUN | Manual-only workflow; routed UI completion gate remains open. |
| Feature Branch - Android APK Artifact | 43832286259 | PASS | Debug APK build, metadata verification and upload all completed. |

Verified artifact from run 43832286259:
- Artifact: `MindVaultArchive-debug-223-f2fae00276536124128d2ddfa4a0269507513f06`, ID `14208684788`, ZIP size 100,767,273 bytes, not expired at inspection.
- Downloaded ZIP contains `MindVaultArchive-debug.apk`, `build-info.txt`, and `SHA256SUMS.txt`.
- Metadata confirms branch `feature/ultimate-all-in-one-mindvault`, commit `f2fae00276536124128d2ddfa4a0269507513f06`, version `1.0.0+1`, `build_type=debug`, `installable=true`.
- APK size: 182,397,685 bytes. APK SHA-256: `d5e4fa67c311f87634ad4811f1e3ae9b6663c5aa0461fd274d6555d307ecc1ba`.
- This artifact predates the Settings UI source and Settings test commits; it is not an artifact for the current branch head.

### Actionable warning status from the inspected successful logs
- No Node 20 deprecation, setup-java v4, or `cp -n` portability warning appeared in these two logs. Current workflows use checkout v5, setup-java v6 and upload-artifact v6.
- Riverpod generator still reports locked analyzer 6.4.1 language version 3.4.0 against the Dart 3.14 SDK and recommends analyzer 14.7.0. Do not upgrade analyzer alone; coordinate Riverpod generator/lint/analyzer compatibility.
- Android build still warns that the app module, `file_picker` and `share_plus` apply Kotlin Gradle Plugin. A coordinated built-in Kotlin migration remains pending plugin-major/Dart API compatibility review.
- Drift multiple-database warnings remain unverified on the current source because Regression Tests have not been dispatched. The full-backup test's separate source/target in-memory executors and tearDown must be confirmed by a future regression log.

### Current source and next validation
- Settings implementation and its focused test are committed through source SHA `653f5699bd3ebee4361d78789c8cc64572670eb0`.
- The documentation commits that follow this entry will change the branch head; Code Check and Android APK must be checked again against the final resulting SHA.
- Regression Tests remain intentionally unrun until all routed UI work is complete. A skipped/manual workflow is not a pass.
- Settings remains **partial** until the new test is executed, every visible control has success/failure/persistence coverage, and light/dark/text-scale/device visual QA is complete.


## 2026-11-17 Settings implementation, formatting correction and validation follow-up

### Source milestone
- `d30f7f35791de9164f8a8666d4f05b15eac6cdd0`: Settings FeatureHero/NeoBrutalistPanel redesign, accessible palette swatches, category loading/error/empty states, and preserved profile/theme/category actions.
- `cff8da5057b6bdfc6baf681fa2b7c55f47d4e812` plus `653f5699bd3ebee4361d78789c8cc64572670eb0`: added the Settings widget test for 320×640 rendering, panel presence, accent preference persistence, and category create/rename/delete persistence.
- Formatter run `44041214704` formatted the two changed Dart files and committed them as `ce7bd6a8eb60d4b8fd98354b4a54eb2a794e97a6`.
- The temporary feature formatter trigger was restored to main-only in commit `3ae6198d9871702b179aca02e4e543345ff491f2`. The formatter remains pinned to Flutter 3.50.0.

### CI failure and correction
- Code Check run `44040904050` on `118469b5eaf7646794be10aa0f8e6711b1380875` failed only at `dart format --output=none --set-exit-if-changed lib test`; `settings_screen.dart` and `settings_screen_test.dart` were the two files changed by the formatter. Analyzer was skipped.
- Android APK run `44040904104` on the same SHA failed at its generated-source/formatting gate; APK packaging and upload were skipped.
- Formatter run `44041214704` passed on `49fb569e2703a6b2dc3479a10cbda9822ef9235c` and produced the formatted commit `ce7bd6a8eb60d4b8fd98354b4a54eb2a794e97a6`.
- The workflow restoration commit and this roadmap/audit update produce a newer head; fresh Code Check and APK runs must be checked against the final resulting SHA before recording success.
- Regression Tests were not dispatched because the routed UI implementation gate is still open. The new Settings test is added but not executed.

### Current warning status
- Previous successful Code Check/APK logs on `f2fae00276536124128d2ddfa4a0269507513f06` show no Node 20 deprecation, setup-java v4, or `cp -n` portability warning. Checkout v5, setup-java v6 and upload-artifact v6 are in use.
- Riverpod generator/analyzer compatibility warning remains (locked analyzer 6.4.1, language version 3.4.0 vs SDK 3.14.0); coordinated dependency upgrade required.
- Kotlin Gradle Plugin warnings remain for app module, `file_picker`, and `share_plus`; coordinated built-in Kotlin migration remains pending.
- Drift multiple-database warnings remain unverified until Regression Tests are run after UI completion.

### UI and reference review
- Re-opened `Mind Vault UI.zip`; verified the six files and the Home, Editor, Tasks and Delete Confirmation references. No emulator/physical-device screenshot comparison is available, so no pixel-identity claim is made.
- Settings remains **partial**: source redesign and focused test source exist, but test execution, complete interaction/failure acceptance, and light/dark/text-scale/device visual QA remain.
- All other route statuses remain as recorded in the routed-screen matrix; UI implementation is not complete.


## 2026-11-18 App-lock gate visual/accessibility milestone

### Source and test changes
- `58141f375dc0bddb4e8d218ba89ec4f5114cabc7`: aligned the global `AppLockGate` unlock and secure-storage failure screens with the shared `FeatureHero` and `NeoBrutalistPanel` components. Both states are scroll-safe on short screens and retain the existing fail-closed behavior.
- The PIN field now accepts digits only and limits input to six characters before verification; busy state disables the field and unlock action.
- `cc5c7127c8cad87d9ce2137b769b75a9435ad7fb`: added widget assertions for the shared panels, six-digit filtering, and secure-storage retry. The retry test confirms that access stays blocked on a storage error and only reveals the child after secure storage becomes readable.
- No database schema, migration, PIN hashing, lockout policy, or route behavior changed.

### User-action trace and acceptance
- Unlock action -> PIN TextField formatter -> `AppLockGate._unlock` -> `AppLockService.verifyPin` -> secure value store -> success unlocks child; wrong PIN retains the gate and shows the existing error/lockout state.
- Secure-storage failure -> fail-closed gate -> Retry -> `AppLockGate._load` -> secure value store -> child is revealed only after a successful settings read.
- Focused coverage: `test/app_lock_gate_test.dart` now checks valid PIN unlock, filtered six-digit input, wrong PIN, visual component presence, and recovery after a transient secure-storage read failure. Tests have not been executed because the routed-screen UI completion gate remains open.

### Exact-SHA validation snapshot
- Prior baseline SHA `c0d454adb5d281165441061b722466460afd3f51`: Code Check run `44041444711` PASS; `flutter analyze` reported `No issues found!`; Dart format reported 56 files with 0 changes.
- The same baseline SHA: Android APK Artifact run `44041444663` PASS; debug APK built, metadata generated, and artifact `14309094295` uploaded.
- Baseline artifact `MindVaultArchive-debug-232-c0d454adb5d281165441061b722466460afd3f51`, ZIP digest `b5d1b8bb0efa72235b757d2d6773a10378d7ba3fe790ff64e0b8af96af8da6ca`, 100,763,226 bytes. Downloaded ZIP contains the APK, `build-info.txt`, and `SHA256SUMS.txt`. Metadata confirms branch `feature/ultimate-all-in-one-mindvault`, commit `c0d454adb5d281165441061b722466460afd3f51`, version `1.0.0+1`, debug build and `installable=true`. APK size 182,398,909 bytes; APK SHA-256 `81a24d0dc5d5470af245716176349aa3b7fa9ceff158a197430f68b5ed8f2ab3`.
- New source/test SHA `cc5c7127c8cad87d9ce2137b769b75a9435ad7fb`: Code Check run `44262696842` and Android APK run `44262696761` were in progress at the time of this entry. They are not recorded as passes. Regression Tests were not dispatched because UI work remains incomplete.

### Warning status and remaining work
- No Node 20 deprecation, setup-java v4, or `cp -n` warning appeared in the inspected baseline logs. Workflows use checkout v5, setup-java v6 and upload-artifact v6.
- Riverpod generator/analyzer language-version mismatch remains; resolve only with a coordinated compatible generator/lint/analyzer update.
- Android KGP warning remains for the app module, `file_picker` and `share_plus`; built-in Kotlin migration needs a coordinated plugin/Gradle compatibility change.
- Drift database lifecycle warnings remain unverified until the full regression suite runs after UI completion.
- Remaining UI acceptance: finish per-screen control/state and responsive/text-scale/focus review for all 19 routes, capture emulator/physical-device screenshots for reference comparison, and complete remaining local feature success/failure/persistence coverage. No pixel-identical claim is made. External AI, cloud sync, collaboration, OCR, biometrics, PIN recovery, encryption, reminders, recurrence, calendar and habits remain not implemented/blocked pending real providers, platform support, credentials or product/privacy decisions.


## 2026-11-19 app-lock test finder and formatting correction

- The previous Code Check run **44262874153** and APK run **44262874171**, both on SHA `95a09ae7060d4f3bb0cb21a4ea10f0f2cb2fb98e`, failed at the Dart formatting gate. Analyzer and APK packaging were skipped; this was not a source compile/build failure.
- Formatting was required in `lib/features/security/presentation/app_lock_gate.dart` and `test/app_lock_gate_test.dart`. The focused secure-storage retry test also used an incorrect finder (`Could not verify secure app-lock settings`) that did not match the screen's actual `Secure storage unavailable` title. Corrected it in `72f07675fa527a2d1cb4eea2808109e020fcd52b`.
- Temporarily enabled the feature branch on the existing formatter workflow; run **44482062847** completed successfully and generated formatter commit **207ff4aa19b7c1bc109234aea21869848b47bcf6**. Only the long FeatureHero subtitle and two test finder/expect lines were reformatted. Restored automatic formatting to main-only in **a5938f579d8c3cdbe82db25795e74443f112a620** to avoid recurring bot commits/races.
- Code Check **44482169331** and Android APK Artifact **44482169347** were queued for SHA `a5938f579d8c3cdbe82db25795e74443f112a620` at this snapshot. They are not passes until completed. The regression workflow `code-quality.yml` remains manual-only and was not dispatched because the routed-screen UI completion gate is still open.
- The secure-storage failure widget test now waits for the actual screen title and asserts the child remains blocked until retry succeeds. This test has **not been executed**. No regression pass is claimed.
- UI completion remains **PARTIAL**: all 19 routes are inventoried, but per-screen interaction/visual acceptance and emulator/physical-device screenshot comparison remain. The source feature specification continues to identify cloud/AI/OCR/biometric encryption/reminders/recurrence/calendar/habits as not implemented or externally blocked.
- Current actionable warnings: Riverpod generator/analyzer SDK language-version mismatch; Kotlin Gradle Plugin usage by app, `file_picker`, and `share_plus`; Drift database lifecycle warning not re-evaluated because the regression suite has not run.


## 2026-11-20 Trash UI consistency and action-safety milestone

### Source/test commits
- `b8b734e53fd46a9cdbcd47e58ec0cecfd137b46a`: Trash note cards and empty-state content use the reusable `NeoBrutalistPanel`. Restore and permanent-delete failures now show user feedback rather than an uncaught async error.
- `d4dd53cc1576c67709964fd8734a6432cc7877d8` and `0a5e5ab8046ce770b17dc2ff86dc1563677a5f29`: new `test/trash_screen_test.dart` covers empty state, restore persistence, confirmation cancellation, and permanent deletion cleanup of attachments metadata, note-tag links and revisions while detaching linked tasks. Test source has not been executed.
- Formatter run **44697750897** PASS generated `ca0f45ff0a37679795bdede4cd9893d3dced40e3`; automatic formatter was restored to main-only in `b084489a947f0805d4fbd3bf759760a943165040`.

### Verified CI and artifact snapshot
- SHA `d7b84891e00912b3d42a4086a49c86c7f40e28cd`: Code Check **44482220777** PASS; all formatting/analyzer steps successful, `flutter analyze` reported `No issues found!`.
- Same SHA: Android APK Artifact **44482220755** PASS. Artifact **14509431335** downloaded and inspected; contains APK, `build-info.txt`, and `SHA256SUMS.txt`. Metadata branch and commit match, version `1.0.0+1`, debug, installable. APK is 182,398,933 bytes; SHA-256 `40db0a03808698e852364849aaaacbbad2cf247f2789247ef8512539696d9423`.
- Latest code commits after this verified snapshot require fresh exact-SHA Code Check and APK validation. Regression Tests remain manual-only and intentionally undispatched because UI completion is not verified.

### Remaining
- Trash: test execution and visual QA pending. Permanent deletion removes database attachment metadata; filesystem cleanup is outside this screen's current service behavior and must not be implied.
- All 19 routes remain partial for final visual/interaction acceptance; no emulator/physical screenshot comparisons have been captured.
- Riverpod generator/analyzer language-version warning and Kotlin Gradle Plugin warnings for app module, `file_picker`, `share_plus` remain. Drift lifecycle warning is not re-evaluated until regression tests are run. No Node 20 deprecation, setup-java v4, or `cp -n` portability warning was seen in inspected logs.


## 2026-11-21 Trash-test analyzer cleanup and exact-SHA artifact snapshot

- Latest previous source SHA `837c8a862d16602c917041062ea7e6f17cea6114` had Code Check **44866980325** fail at static analysis: `test/trash_screen_test.dart:1:8 unused_import` for `package:drift/drift.dart`. Formatting, dependency resolution, generated-source verification and code generation had succeeded; analyzer found this single warning/error. Removed the unnecessary import in commit **9b8e8a166ba3f76c92c9b5a3712e322b01c244b4** after fetching and verifying the file's current SHA. No test logic was changed.
- On the same pre-fix SHA `837c8a862d16602c917041062ea7e6f17cea6114`, Android APK workflow **44866980372** passed all steps, including debug APK packaging, metadata verification and artifact upload. Artifact **14692756321**, `MindVaultArchive-debug-249-837c8a862d16602c917041062ea7e6f17cea6114`, was downloaded and inspected. ZIP includes APK, `build-info.txt`, and `SHA256SUMS.txt`; metadata matches the branch and commit, version `1.0.0+1`, debug, installable. APK size **182,399,753 bytes**; SHA-256 **8aa4013682490e72c3fedd7073d5b7688079b48569ba42edec9fc976c8961625**. This artifact is for SHA 837c8a86, not the import-fix commit.
- Fresh Code Check **44879767543** and Android APK Artifact **44879767535** started for the import-fix SHA `9b8e8a166ba3f76c92c9b5a3712e322b01c244b4`; both were in progress at the latest inspection, so neither is recorded as pass.
- Regression Tests have no run on the latest SHA. The workflow is manual-only; this runtime does not expose a workflow-dispatch action. It remains intentionally not run until routed UI completion is verified. The Trash widget tests, including restore/persistence, cancel-delete and linked-record cleanup, remain source-only/unexecuted.
- Current blockers/partial status unchanged: 19 routed screens still need individual visual/control-state acceptance and screenshot comparison; physical-device QA is unavailable. Riverpod analyzer compatibility and Android KGP warnings remain; Drift lifecycle warning remains unverified without the regression suite. No external functionality is claimed.


## 2026-11-22 Quick Capture redesign and draft-restoration race guard

### Source milestone
- Temporary formatter feature trigger: `038d7ddae6a103b5e734e98b731f64124f6a5433` (main-only trigger must be restored after formatting validation).
- UI commit: `ee2b1cfa693e58370ba2d994b093ea15d1558da2` — Quick Capture title/body moved into a shared cream Neo-Brutalist writing panel with black input borders and high-contrast text; green status panel communicates local draft state.
- Focused test commit: `7cdf48ed98d544f46b67d0923980c39c676ceafe` — test source checks the shared panel count, 320×640 layout, fields enabled after restoration, empty-save feedback, and no database note inserted.
- Restore guard: inputs and both Save actions remain disabled while SharedPreferences restoration is in flight; `_capture` exits if restoration is not complete. This closes the startup overwrite race where a user could type or save before draft restoration completed.
- Existing save, save-and-open-editor, draft restoration/remount, and generation-queue clearing behavior remains. No database/provider/migration changes.

### User-action/data-flow evidence
- Title/body input -> generation-queued SharedPreferences draft writes -> save -> `databaseProvider` -> `AppDatabase.saveNoteContent` transactional insert -> local archive; success clears the draft and either shows confirmation or navigates to `/editor/:id`.
- Empty capture remains rejected with SnackBar feedback and no insert.
- Existing workflow tests cover successful persistence, editor route transition, and draft restore after remount. The new focused test is not executed yet.

### CI and artifact snapshot at the start of this milestone
- Branch head `a1411f5d6d41e1b856ad19c4356e74525c4c8e63`: Code Check run **44879870769** PASS; all steps including `flutter analyze` succeeded, which reported `No issues found!`.
- Same SHA: Android APK run **44879870704** PASS; debug build, metadata verification and artifact upload succeeded. Artifact **14697640764**, `MindVaultArchive-debug-251-a1411f5d6d41e1b856ad19c4356e74525c4c8e63`, ZIP digest `137a4ee0e3b422af7cb4f541ed36dd4824ceb8790573da2886a7a54281613d33`, size 100,762,993 bytes. Metadata: branch matches, commit matches, version `1.0.0+1`, `build_type=debug`, `installable=true`. Regression workflow was not run (manual-only; UI gate not complete).
- These PASS results apply to the pre-Quick-Capture SHA only. Fresh Code Check/APK results must be inspected after final formatting and formatter-workflow restoration; pending/cancelled runs do not count.

### Warnings
- Code Check logs show Riverpod generator warning: analyzer language version 3.4.0 vs SDK 3.14.0. Coordinated Riverpod generator/annotation/lint/analyzer upgrade required; analyzer-only override is not safe.
- APK logs warn the app module, `file_picker`, and `share_plus` apply Kotlin Gradle Plugin, which future Flutter releases will reject. Coordinated Flutter/plugin/Kotlin migration remains unresolved.
- Package-resolution output reports 64 packages with newer versions incompatible with current constraints; do not broad-upgrade without compatibility review.
- No Node 20 deprecation, setup-java v4, or `cp -n` warning appeared in these logs; workflows use checkout v5, setup-java v6 and upload-artifact v6.
- Drift test database lifecycle warnings are unverified because the Regression Tests workflow has not run.

### UI acceptance
- Quick Capture remains **partial** until focused tests execute, visual checks are completed in light/dark themes with text scaling and keyboard/focus, and screenshots are compared on emulator/device.
- All 19 routes remain under final per-screen control-state/responsive QA. No emulator/physical-device screenshot comparison is available; pixel-identical replication is not claimed.
- External AI/cloud sync/collaboration/OCR/biometrics/encryption/reminders/recurrence/calendar/habits remain blocked or not implemented unless real providers/platform capability and consent are added.


## 2026-11-22 Quick Capture source UI gate closure and regression workflow activation

- Formatter trigger temporarily enabled for the feature branch in commit `038d7ddae6a103b5e734e98b731f64124f6a5433`; formatter run **44997131979** succeeded and committed Dart formatting as `484fc2651ba4f14f6bbaa6b3e1618091e2935483` (two files, formatting-only). Restored formatter to main-only in `d5bef19ea67ef0b20a2a7a772c0a9408e361f3d1`.
- Code Check **44997131953** on pre-format SHA `8c2c7c88254918ea515c8cea7efb978cb367c6dc` failed at Dart formatting; source and test were formatted by run 44997131979. Analyzer was skipped on that SHA. The APK workflow 44997132051 on that SHA was still in progress when superseded; it is not counted as success.
- Latest pre-activation SHA `d5bef19ea67ef0b20a2a7a772c0a9408e361f3d1`: Code Check **44997234454** and APK **44997234363** were queued/in-progress at inspection; not counted as passes.
- Source-level UI review across all 19 route files found no TODO/FIXME, placeholder, inert-null callback or unlabelled disabled-control patterns. Protector biometric, PIN recovery and encryption remain explicitly unavailable. This closes the source UI implementation gate for running the regression suite; screenshot/device QA remains a separately disclosed limitation.
- Activated Regression Tests on feature-branch pushes and pull requests while retaining manual dispatch. This will run the existing full suite `flutter test --concurrency=1 --reporter expanded`; no tests were weakened or removed.
- Current warning status: Riverpod generator analyzer language version 3.4.0 vs Dart SDK 3.14.0; app module, `file_picker`, and `share_plus` Kotlin Gradle Plugin warnings; package resolution reports 64 packages newer but incompatible with current constraints. These upgrades need a coordinated compatibility review. No Node 20 deprecation, setup-java v4, or `cp -n` portability warning appeared in latest logs. Drift lifecycle warning remains to be assessed by the newly activated regression suite.


- Trigger note: the workflow/audit/roadmap bundle commit `ba4d907aa83a4d496e7aa272d624f8aebd75b0c7` was created through Git Data API; no workflow runs were visible immediately. This follow-up contents commit is intended to produce the normal push event and is the validation target. The latest SHA and run IDs will be rechecked before reporting.
