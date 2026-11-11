# UI Design System

## Brand and tokens

MindVault Archive uses the burgundy accent `#5A0719` by default. The accent
provider persists the user's selected accent color locally. Shared Material 3
theme tokens define light and dark color schemes, card surfaces, app-bar
typography, input states, dividers, navigation indicators, button sizing and
snackbars.

Dark mode defaults to the AMOLED theme: a pure-black scaffold/canvas with
charcoal cards. Users can disable the AMOLED option to use the charcoal dark
surface instead. Light mode uses a soft neutral surface. The theme fallback
accent and the provider default are both burgundy.

## UI principles

- Keep note creation, global search and quick capture easy to reach.
- Use Material 3 controls with visible focus, readable contrast and clear labels.
- Preserve content space in the editor and expose word/character/reading-time information without obscuring the document.
- Clearly communicate save state, failures and destructive actions.
- Prefer local-first status text; never show fabricated sync or cloud status.
- Use responsive constraints for grids and content panes where implemented.
- Preserve scalable text and touch targets; verify accessibility on real devices.
- Avoid decorative blur on large scrolling surfaces to protect performance on
  mid-range Android devices.

## Delivered in the current source slice

- Centralized light, charcoal-dark and AMOLED-black Material 3 theme tokens.
- Local archive insights, duplicate-title review and missing-wikilink reporting.
- Unified note/task activity timeline.
- Developer snippet notebook using canonical note records.
- Quick Capture draft persistence using local preferences.
- User-created Markdown templates stored locally in preferences.
- Optional true-black AMOLED theme.
- Markdown note export through the Android share sheet.
- Note attachments imported into app-private storage, listed, image-previewed,
  shared with compatible apps and removed from the note.
- Editor word count, character count and estimated reading time.
- Reference-aligned compactness and visual hierarchy refinements across the
  routed screens listed in `UI_FUNCTIONALITY_AUDIT.md`.

## Remaining UI/UX work

The complete adaptive application shell, persistent bottom-navigation/rail
state, fully responsive tablet/landscape layouts, dashboard personalization,
complete Bengali localization, accessibility audit, reduced-motion review and
individual-device screenshot comparison remain outstanding. The shared theme
does not guarantee that every bespoke widget has been visually normalized.
Screens with hard-coded colors or custom layouts still need local QA.

## Verification

Theme widget tests and real-device visual QA must be run against the exact
feature-branch commit. A source-level theme change is not evidence of
pixel-identical reference matching or crash-free behavior.
