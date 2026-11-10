# Navigation Architecture

## Current route inventory

The current GoRouter configuration defines: `/` splash, `/home`, `/editor/:id`, `/drawing/:id`, `/settings`, `/about`, `/tasks` (optional `noteId` query), `/templates`, `/capture`, `/tags`, `/history/:id`, `/search`, `/app-lock` and `/archive-tools`.

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

The router is a flat GoRouter list with no documented nested shell/navigation-state preservation or route-level authentication redirect. Add a ShellRoute only when the corresponding adaptive navigation UI is implemented and tested.