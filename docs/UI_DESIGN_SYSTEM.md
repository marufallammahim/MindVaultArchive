# UI Design System

## Brand and tokens
MindVault Archive uses a deep burgundy brand (#5A0719) and Material 3 color schemes. The shared AppTheme defines light and dark surfaces, app-bar typography, card shape/borders, input states, dividers, navigation indicators, button sizing and floating snackbars. The dark surface is deep charcoal, not advertised as a fully black AMOLED mode.

## UI principles
- Keep note creation, global search and quick capture easy to reach.
- Use Material 3 controls with visible focus, readable contrast and clear labels.
- Preserve content space in the editor and expose word/character/reading-time information without obscuring the document.
- Clearly communicate save state, failures and destructive actions.
- Prefer local-first status text; never show fabricated sync or cloud status.
- Use responsive constraints for grids and content panes where implemented.

## Delivered in the current source slice
- Centralized light/dark Material 3 theme tokens and consistent card, input, app-bar, button, divider and snackbar styling.
- Local archive insights cards, duplicate-title review and missing-wikilink reporting.
- A unified note/task activity timeline.
- A dedicated developer snippet notebook that stores snippets as normal notes.
- Quick Capture draft persistence using local preferences.
- Editor word count, character count and estimated reading time.

## Remaining UI/UX work
The complete adaptive application shell, persistent bottom-navigation/rail state, fully responsive tablet/landscape layouts, dashboard personalization, custom accent/typography controls, AMOLED option, full Bengali localization, accessibility audit, reduced-motion controls, reusable component catalogue, and comprehensive loading/empty/error/success polish are not yet complete. A visually consistent theme does not imply every feature workflow is complete.
