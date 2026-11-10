# Database Schema — current implementation

The current Drift database is schema version 5.

## Notes
- `id` (primary key)
- `title`, `documentContent`
- nullable `categoryId`
- `createdAt`, `updatedAt`
- `isFavorite`, `isArchived`, `isDeleted`
- nullable `color`, `sortOrder`

## Categories
- `id` (primary key)
- `name`
- `createdAt`, `updatedAt`

## Attachments
- `id` (primary key)
- `noteId`, `type`, `localPath`, `filename`
- nullable `duration`, nullable `metadata`
- `documentPosition`, `createdAt`

## Tasks (schema v2)
- `id` (primary key)
- `title`, `details`
- nullable `noteId` linking a task to a note
- nullable `dueAt`
- `priority`, `isCompleted`
- `createdAt`, `updatedAt`, nullable `completedAt`

## Tags and note-tag relations (schema v3)
- Tags: `id` (primary key), `name`, nullable `color`, `createdAt`.
- NoteTags: composite primary key `(noteId, tagId)`, `createdAt`.

## Note revisions (schema v4)
- `id` (primary key), `noteId`, `title`, `documentContent`, `createdAt`.
- Up to 30 previous snapshots are retained per note.
- Restoring a revision saves the current note as a new revision first.

The database is stored in the app documents directory as
`mindvault_archive.sqlite`. The current schema does not yet declare relational
foreign keys for note/category/attachment/tag/revision references. Application
operations maintain category detachment, tag-link cleanup, revision cleanup
and note attachment metadata cleanup behavior.

Schema upgrades are additive: version 1 to 2 creates tasks; version 2 to 3
creates tags and note-tag relations; version 3 to 4 creates note revisions;
version 4 to 5 adds nullable task-to-note links. When upgrading directly from
version 1, the task table is created with its current columns, so the v5
migration only adds the column for databases that already had the task table.
Schema v5 adds nullable `Tasks.noteId`. Permanent note deletion clears linked
task references before removing the note. Future additions must increment the
schema version and include tested Drift migrations. Do not add tables only to match a planned feature list.
