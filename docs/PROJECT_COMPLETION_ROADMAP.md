# MindVaultArchive — Project Completion Roadmap

Repository: `marufallammahim/MindVaultArchive`  
Target branch: `feature/ultimate-all-in-one-mindvault`  
Last reviewed: 2026-11-14  
Baseline validation commit: `a89a4a18074a72ceb6a0d0404a8b370af3e69955`  
Latest source SHA reviewed: `604b1d98fc2e32d2c1485c882ce9fa1745847ebc`

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
