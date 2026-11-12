# UI Design System

## Brand and tokens

MindVault Archive follows the uploaded Neo-Brutalist references. The canonical palette is sunflower `#F7CB46`, sky cyan `#C0F7FE`, pixel green `#99E885`, bubblegum pink `#FE90E8`, warm cream `#FFDC8B`, cream canvas `#FFFDF2`, and black `#000000`. The accent provider persists a user-selected accent locally; the reference palette remains available in Settings and the editor.

Shared Material 3 tokens define light, charcoal-dark and AMOLED themes. Major cards and controls use clear black outlines, compact geometry and flat fills. Home note cards and the bottom dock use hard, unblurred offset shadows. The editor retains a borderless writing surface and dotted canvas. Dark mode keeps readable foreground roles; pure-black AMOLED is optional.

## UI principles

- Keep note creation, global search and quick capture easy to reach.
- Use Material 3 controls with visible focus, readable contrast and clear labels.
- Preserve content space in the editor and expose word/character/reading-time information without obscuring the document.
- Clearly communicate save state, failures and destructive actions.
- Prefer local-first status text; never show fabricated sync or cloud status.
- Neo-Brutalist components use 2–3px black outlines, flat palette fills, bold hierarchy and hard shadows without blur. Use physical press states where the component supports them.
- Preserve readable foreground/background pairings, visible focus, minimum touch targets and reduced-motion alternatives; visual style must not replace usability.
- Use responsive constraints for grids and content panes where implemented.
- Preserve scalable text and touch targets; verify accessibility on real devices.
- Avoid decorative blur on large scrolling surfaces to protect performance on
  mid-range Android devices.

## Delivered in the current source slice

- Centralized light, charcoal-dark and AMOLED-black Material 3 theme tokens aligned to the uploaded Neo-Brutalist palette.
- Shared card, input, dialog, bottom-sheet, popup-menu and button outlines updated to bold black strokes.
- Home note cards and bottom navigation restyled with flat color blocks and hard, zero-blur shadows.
- Editor note-color choices aligned to the six-color reference palette; redundant manual Save action removed in favor of the existing autosave and save-before-exit flow.
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
