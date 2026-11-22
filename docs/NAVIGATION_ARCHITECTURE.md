# Navigation Architecture

## Current route inventory

The current GoRouter configuration defines 19 destinations: `/` (Splash), `/home`, `/trash`, `/delete/:id`, `/editor/:id`, `/drawing/:id`, `/settings`, `/about`, `/tasks` (optional `noteId` query), `/templates`, `/capture`, `/tags`, `/history/:id`, `/search`, `/app-lock`, `/archive-tools`, `/insights`, `/timeline`, and `/developer-notebook`.

## Target primary destinations

Home; Notes; Search; Tasks; Archive; Projects/Workspace as they become functional. Keep create and global search reachable. Use bottom navigation on compact devices and navigation rail/drawer on larger layouts. Do not expose unimplemented destinations as functional primary tabs.

## Routing rules

- Keep route names stable and document breaking changes.
- Validate required path IDs before querying; show not-found states for missing records.
- Locked records must pass an unlock guard before content is built.
- Preserve editor state and save pending changes before leaving.
- Back navigation closes dialogs/sheets first, then returns through router history.
- Deep links must reject malformed IDs and unauthorized content.
- Each route needs meaningful loading, empty, error and success states.
- Add route tests for critical flows before expanding route inventory.

## Current gap

The router is a flat GoRouter list with no nested shell/navigation-state preservation or route-level authentication redirect. The app lock gate is currently an app lifecycle gate rather than a route-level locked-note authorization system. Add a ShellRoute only when the corresponding adaptive navigation UI is implemented and tested. All 19 destinations require route-level loading/error/empty and back-stack acceptance; route existence alone is not completion.