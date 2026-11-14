# UI and Functionality Audit — 2026-11-14

Branch: `feature/ultimate-all-in-one-mindvault`

## Design direction
- Follow the uploaded Neo-Brutalist references: cream/dotted canvas, black outlines, flat yellow/cyan/green/pink/warm-cream blocks, bold typography and hard unblurred shadows.
- Keep compact, readable content hierarchy, strong contrast and thumb-reachable primary actions; dark/AMOLED mode must retain readable foreground colors.
- Keep layouts content-first; avoid decorative blur on large scrolling surfaces to preserve performance on mid-range Android devices.
- Preserve Material 3 semantics, scalable text, visible focus/pressed states, and accessible contrast.
- Use brief state transitions and provide reduced-motion-friendly behavior.

## Screen inventory reviewed
- Home/dashboard: profile, search, category filters, note cards, bottom navigation.
- Tasks: task creation/editing, due date, priority, linked note, completed filter.
- Templates: five built-in Markdown starters, custom template persistence, create note from template, custom deletion.
- Protector/App lock: six-digit PIN, salted SHA-256 hash, Android secure storage, five-attempt/30-second lockout, app lifecycle gate.
- Settings: theme mode, AMOLED toggle, accent presets/custom HEX, categories, tags, archive tools, Protector route.
- Other routed screens: editor, drawing, capture, tags, search, revision history, archive transfer, insights, timeline, developer notebook, about.

## Findings and limitations
1. Protector is currently an app-entry access gate only. It is not database/file encryption and does not selectively lock individual notes.
2. Biometric unlock and PIN recovery are not implemented. The UI must not imply they are available.
3. Templates support five built-in starters and local custom Markdown templates. Template variables, import/export, folders, and cloud sync are not implemented.
4. The feature-screen map marks AI, sync, collaboration, and workspace as not implemented; multimedia/OCR and productivity subfeatures are partial.
5. Task screen supports CRUD, completion state, priority, due date, and linked notes; no Kanban/calendar/habit planner is present in the current route inventory.

## Cross-screen visual consistency pass (2026-11-11)
- Updated the shared Material 3 theme consumed by every routed screen: pure-black AMOLED canvas, consistent charcoal cards, compact app bars, rounded dense inputs, dialog/bottom-sheet surfaces, popup menus, list tiles, navigation bar, chips, buttons, dividers, and progress indicators.
- Aligned Settings palette preset and HEX example with default Burgundy #5A0719.
- This is a global visual-system pass, not a claim that every screen has been individually pixel-matched to the reference. Screens with bespoke hard-coded Container colors or custom layouts still need per-screen visual QA and may need local adjustments.

## Validation status
- Source-level review completed for the screens and services listed above.
- Runtime Flutter analysis, widget tests, Android build, and device QA must be run in CI or a Flutter environment before calling this release-ready.
- No claim of successful APK generation is made by this audit.


## Reference-aligned screen polish pass (2026-11-11)

The following presentation files received screen-level compactness and visual hierarchy refinements while retaining their existing database queries, callbacks, navigation destinations, and save/restore operations:
- Tasks: denser task cards, reduced gaps/padding, compact card shape, clearer To-do title casing.
- Quick Capture: refined editor spacing and title hierarchy; draft/save behavior unchanged.
- Search: compact search header and result spacing; search service and debounce flow unchanged.
- Tags: denser list layout and theme-role icon treatment; create/rename/delete actions unchanged.
- Archive Transfer: compact section rhythm and consistent heading hierarchy; backup/import/export services unchanged.
- Revision History: compact revision list and consistent list spacing; restore action unchanged.
- Insights: tighter report layout and stronger heading hierarchy; metrics remain computed from local database streams.
- Timeline: compact chronology spacing and theme-based entry icon surfaces; note navigation unchanged.
- Developer Notebook: compact snippet list and theme-based icon surface; snippet creation and editor navigation unchanged.
- About: compact spacing and accent-aware brand icon.
- Note Editor: cleaner title field, spacing, and category affordance; autosave, attachments, Markdown preview/export, linked tasks, revision restore, drawing, and note-color actions retained.
- Drawing: refined canvas surface and toolbar spacing; save-to-note attachment flow retained.

## Research basis
- Flutter adaptive UI guidance recommends measuring available constraints and choosing layouts appropriate to the available space rather than stretching phone layouts across large windows.
- Material 3 guidance recommends consistent semantic color roles and explicit contrast between foreground and container colors.

## Current verification
- GitHub source changes are committed to the existing feature branch.
- The latest Android CI, Code Quality, and Dart formatting runs have been queued for commit `595786325e54293b1ab0be585fa6b122d5ab8d4e`; no successful result is available yet.
- Individual-device visual QA and screenshot comparison remain outstanding. This pass is a compactness and shared-style refinement, not a claim of pixel-identical replication.


## CI follow-up after formatter commit
- GitHub Actions formatter workflow committed the Dart formatting corrections in commit `aac57b6ea24bbf3188f47685889b4f7b3fd54a0e`.
- The earlier Code Quality and Android CI failures were caused by the formatter check detecting those pending style changes before the formatter workflow's commit landed. They did not reach analyzer, tests, APK build, or artifact upload.
- A new source commit is being used to trigger fresh validation against the formatted branch head.


## Uploaded-reference Neo-Brutalist pass — 2026-11-13

Committed on `feature/ultimate-all-in-one-mindvault`:
- Shared Material theme now uses the reference palette and 2–3px black outlines for cards, inputs, dialogs, bottom sheets, menus and buttons.
- Dark app-bar foregrounds now follow the dark ColorScheme rather than using black text on a dark surface.
- Settings accent presets and editor note-color choices use the six reference colors.
- Home note cards and bottom dock use flat color blocks, black outlines and zero-blur offset shadows.
- Editor writing area remains borderless with its dotted canvas; redundant manual Save action was removed while autosave and save-before-exit remain.

## Remaining verification and implementation boundaries

- On source SHA c3630a3b1c23bd43c9e4319061415ffb4d0472e4, Code Check run 43574945899 and Android APK run 43574945830 both stopped at the formatting gate; neither reached analyzer or APK packaging. Formatter run 43574945773 passed and committed the two required Dart formatting changes as 604b1d98fc2e32d2c1485c882ce9fa1745847ebc. That formatter-created SHA has no Code Check/APK run yet because the bot commit did not trigger downstream workflows.
- No emulator/physical-device screenshot comparison was run, so exact pixel identity is not claimed.
- This visual pass does not complete every feature in the master specification. AI, cloud sync and collaboration remain unimplemented without configured providers; notebooks/folders, OCR, reminders/recurrence, calendar/habits and advanced editor workflows remain partial or pending.
- A complete feature-by-feature source audit and runtime acceptance pass is still required before release readiness can be claimed.


## Reference archive review — 2026-11-14

The supplied `Mind Vault UI.zip` was opened and inspected. It contains six files:
- `Home Screen.jpg` (382×512): dark archive home with profile greeting, search/settings actions, category chips, bright colored note cards, add action and floating bottom dock.
- `Note Editor, Main Editor.jpg` (512×382): split editor states with title/body, metadata chips, top actions and a compact formatting toolbar.
- `to do list screen.jpg` (512×382): date selector, task list, calendar/progress view, colored task rows and bottom navigation.
- `delete screen .jpg` (382×512): dark confirmation page, app mark, large editorial heading, yellow hand/cable illustration, coral destructive action and a keep-note action.
- `app logo.jpg` (2048×2048) and `app in Animation logo.jpg` (512×512): supplied brand references.

### Source-level visual gap findings

These are code comparisons, not emulator screenshot measurements:
- **Home:** the route now uses the bright reference palette for note cards in both brightness modes, black card keylines, and a cyan hard-shadow dock. Profile, search, filters and create actions remain connected. Side-by-side emulator comparison and narrow-screen visual QA remain.
- **Tasks:** the route now includes the compact date strip, bright palette task rows, date-aware CRUD, completion filtering, note links and a local progress/calendar view. The monthly calendar and progress layout still need screenshot comparison and date-boundary interaction QA.
- **Editor:** title/body autosave, Markdown preview/formatting, attachments, linked tasks, revisions, note colors, drawing and Trash remain connected. The app bar now groups secondary actions in an overflow menu and the Markdown toolbar uses cyan/yellow palette blocks with hard outlines. Narrow-screen screenshot and menu-action tests remain.
- **Delete confirmation:** the route retains the dark background, brand mark, editorial heading, coral destructive action and keep-note action. Its custom painter now draws mirrored yellow hands around a white tangled cable. The drawing is source-level reference work; screenshot comparison remains outstanding.
- **Shared secondary-screen hero:** FeatureHero now uses a flat sunflower-yellow block, cyan outlined icon tile, 2.5px black keyline and zero-blur offset shadow. Templates and Trash now use it; Protector uses the same palette/block language. Routes with custom writing or dashboard layouts still require individual review.
- **Palette:** AppTheme now exposes the reference values: yellow #F7CB46, cyan #C0F7FE, green #99E885, pink #E9E0E8, cream canvas #FCEFE8, warm cream #FFDC8B, and black ink. Screen-specific colors remain in a few custom layouts and must be audited.
- No Android emulator or physical-device screenshots were captured during this review. Pixel-identical replication is not claimed.

### Routed-screen status inventory

All 19 GoRouter destinations in `lib/app/router.dart` were enumerated. A route existing is not proof that its full workflow or reference styling is complete.

| Screen | Current status | Evidence / remaining acceptance |
|---|---|---|
| Splash | Partial | Startup/branding route exists; first-run, contrast and screenshot QA remain |
| Home | Partial | Note stream, filters, profile, actions and dock exist; responsive widget test is pending CI verification |
| Editor | Partial | Autosave, Markdown, attachments and all note actions remain connected; overflow menu and toolbar were redesigned; narrow-screen/menu interaction tests remain |
| Tasks | Partial | Local CRUD, due date, priority, completion, linked notes and progress view exist; end-to-end widget workflow test is pending |
| Delete confirmation | Partial | Confirm/cancel route and custom two-hand/cable painter exist; emulator screenshot comparison and route test remain |
| Drawing | Partial | PNG attachment flow exists; save/error/undo/redo/clear and backup lifecycle need complete tests |
| Quick Capture | Partial | Draft restore and local save exist; save/draft race and route tests are pending |
| Search | Partial | Local FTS5 note/task search and category/tag filters exist; empty/error/open-result widget coverage remains |
| Tags | Partial | Local create/rename/delete exists; assignment/filtering and widget persistence coverage remain |
| Templates | Partial | Five built-ins and local custom templates exist; palette cards and FeatureHero added; malformed preference and full CRUD acceptance remains |
| Archive tools | Partial | JSON and ZIP transfer paths exist; rollback/collision/missing-file acceptance remains |
| Revision history | Partial | Local snapshots and restore exist; route/editor reload edge cases remain |
| Trash | Partial | Restore/permanent-delete paths remain; FeatureHero and branded empty/list states added; attachment/revision cleanup tests remain |
| Settings | Partial | Theme, AMOLED, accent, profile and organization routes exist; persistence/accessibility matrix remains |
| App lock settings | Partial | PIN gate remains; Protector panel and status rows now use reference palette; not encryption, no biometric unlock or recovery |
| Insights | Partial | Local archive metrics exist; empty/populated and date-boundary UI tests remain |
| Timeline | Partial | Local chronology and note navigation exist; boundary/empty-state tests remain |
| Developer notebook | Partial | Local snippet create/open flow exists; complete edit/delete and empty/error acceptance remains |
| About | Implemented static | Static information and links exist; shared visual/accessibility QA remains |

External AI, cloud sync, collaboration, OCR/PDF indexing, biometrics, encrypted database storage, reminders, recurrence, calendar and habits remain not implemented or blocked by provider/platform/product decisions. No mock success state should be added for these features.


## Home, Tasks and Splash reference alignment — 2026-11-14

Source-level updates on the existing feature branch:
- Home now uses the same bright yellow, soft-pink, cyan, green and cream note-card palette in dark and light modes. Note cards keep black outlines, and the bottom dock is a cyan flat block with a hard black shadow in both themes.
- Home's selected Home dock item now navigates explicitly to `/home` instead of exposing an inert tap target.
- Tasks now uses the reference palette for task rows, black keylines and compact square geometry. Date selection and task completion/edit/delete callbacks are preserved. The task dock now uses the shared cyan/yellow visual language and its Home action navigates to `/home`.
- Task progress surfaces use flat palette blocks and hard unblurred shadows; due-date labels explicitly distinguish overdue tasks.
- Splash now uses the canonical cream canvas and a flat sunflower logo frame with a dark outline and hard shadow instead of a blue blurred glow.
- The feature APK artifact name now includes the run number and SHA only; it no longer includes the slash-containing branch name that GitHub rejects. The Flutter SDK is pinned to 3.50.0 for reproducible code-check and APK jobs.
- The legacy `android-build.yml` workflow was restored to its original non-feature triggers. The dedicated `feature-branch-apk.yml` is the sole feature-branch debug APK workflow.

Verification limits:
- Source changes are not device screenshot comparisons. The Home, Tasks, Editor and Delete Confirmation reference screenshots still need side-by-side emulator/device QA.
- Regression tests remain manual-only until all routed UI work is complete. No Flutter test suite was run during this milestone.


## UI integration pass — 2026-11-14

The following source-level UI work is committed on the existing feature branch:
- d19340bc40f7e7a67dbeaec9cc133472afca6c9e: Home, Tasks and Splash reference palette alignment.
- 391f300dea5ccb946ad0be7f8a8867e1550052d9: Templates grid moved to palette blocks, black outlines and hard offset shadows; shared FeatureHero added.
- 3e807f890f7d9bdc60b9a21a6b3666a3797e355e: Protector panel and status rows restyled while PIN/security behavior was preserved.
- 8bd30621e932da821d613cc0a8e6600aec65c949: Trash empty/list states now use FeatureHero and the reference palette.
- 00074681925072483ffa4e6c695fd8b97e338395: Delete confirmation painter now draws mirrored yellow hands and a white tangled cable.
- d8ae881dd5cc347407d64b6c7bb170de0b08bfd0 and a6e7b60cbfc885bd68b9cb90caf8a9bc9f76e275: Editor actions grouped into an overflow menu; Markdown toolbar restyled with cyan/yellow blocks and hard outlines.
- 604b1d98fc2e32d2c1485c882ce9fa1745847ebc: Dart formatter commit for the editor changes.

No Flutter regression tests were run because the all-routes UI implementation gate remains open. Device screenshots and accessibility/text-scaling QA remain outstanding.
