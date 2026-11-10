# Feature and Screen Mapping

This map is a workflow inventory. Shared screens are allowed; no route should exist solely as an empty placeholder. Current availability is noted separately from target design.

| Area | Screen / interaction group | Entry point | Feature IDs | Baseline |
|---|---|---|---|---|
| Shell | Splash, onboarding, dashboard, global search, create menu, settings | App launch / shell | F13,F18,F22 | Partial |
| Notes | All notes, list/grid, editor, Markdown preview, block/format toolbar | Home / Notes | F01,F16 | Partial |
| Note metadata | Details, properties, revisions, compare/restore, lock, share | Note menu | F01,F02,F08,F14 | Partial |
| Organization | Notebooks, folders, tags, smart folders, saved searches | Notes navigation | F02,F07 | Partial |
| Lifecycle | Favorites, pinned, recent, archive, trash, bulk actions | Notes navigation | F02 | Partial |
| Knowledge | Backlinks, linked/unlinked mentions, related/orphan notes, graph, timeline and local archive health | Note details / Archive / Settings | F02,F15,F17 | Partial (timeline and deterministic health checks available) |
| Capture | Quick capture, thought inbox, voice/camera/share capture | Create action | F03,F17,F18 | Partial |
| AI | AI home, conversation, Ask Notes, source references, provider and consent settings | AI navigation | F04 | Not implemented |
| Multimedia | Attachment library, image/PDF viewer, scanner, OCR, audio, video, drawing | Attachments / Create | F05 | Partial |
| Productivity | Task dashboard/list/editor/details, subtasks, Kanban, calendar, planner, habits, goals, focus | Tasks navigation | F06 | Partial |
| Workspace | Canvas, mind map, flowchart, research/project boards, element properties | Workspace navigation | F11 | Not implemented |
| Templates | Five built-in templates plus locally persisted custom Markdown templates | Create / Templates | F12 | Partial (custom templates available; variables/import/export pending) |
| Transfer | JSON/ZIP archive import/export, Markdown note share/export, validation and backup/restore | Settings / Archive / Editor | F10,F17 | Partial |
| Sync | Provider setup, sync dashboard/history, conflicts, device management | Settings / Sync | F09 | Not implemented |
| Collaboration | Shared notes/notebooks, permissions, comments, public links | Share action | F14 | Not implemented |
| Security | App lock, PIN, biometric, encryption, locked notes, privacy dashboard | Settings / Security | F08 | Partial |
| Customization | System/light/dark themes, optional AMOLED black, editor, notes, search, language, storage, notifications | Settings | F13,F22 | Partial |
| Developer | Local code-snippet notebook, code blocks, JSON/regex/SQL, Mermaid/LaTeX | Settings / Editor / Templates | F16 | Partial (basic snippet notebook available) |
| Analytics | Local archive counts, duplicate-title and broken-link checks; advanced writing/productivity trends | Settings / Archive / Projects | F06,F17,F21 | Partial (basic local insights available) |

| Insights | Archive counts, word totals, pending/completed tasks, duplicate titles and broken wikilinks | Settings / Archive | F15,F17,F21 | Partial |
| Timeline | Chronological note and task activity | Settings / Archive | F17 | Partial |

## Navigation contract

- Compact phones: bottom navigation for the highest-frequency destinations; secondary destinations in a drawer or navigation sheet.
- Large screens: navigation rail/drawer with adaptive content panes.
- Global search and create action remain reachable from primary destinations.
- Preserve tab/navigation state when switching primary destinations.
- Android back closes transient UI first, then follows router history; do not unexpectedly discard an editor draft.
- Deep links must validate IDs and route guards; locked content requires unlock before rendering.
- Every route must have loading, empty, error and success behavior appropriate to its data.
- Keep route names in `NAVIGATION_ARCHITECTURE.md`; update this map when adding/removing routes.
