# Markdown Editing

The note editor stores Markdown source text and keeps autosave/version history
through the existing editor state provider.

## Formatting toolbar
- Bold and italic selection wrapping.
- Inline code and fenced code block insertion.
- Heading and quote line prefixes.
- Bullet and checklist line prefixes.
- Link syntax insertion.

When text is selected, wrapping actions preserve the selected text and move the
cursor after the inserted Markdown. Line actions prefix the line containing the
cursor.

## Preview
The editor can switch between Markdown source editing and a selectable rendered
preview. Preview does not modify the stored source.

## Scope
This is Markdown authoring with preview, not a WYSIWYG block editor. Advanced
block drag-and-drop, tables UI, embedded database objects and collaborative
editing remain future work.
