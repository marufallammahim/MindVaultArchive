# Database Schema — current implementation

The current Drift database (schema version 1) contains:

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

The database is stored in the app documents directory as
`mindvault_archive.sqlite`. The current schema does not yet declare relational
foreign keys for note/category/attachment references. Application operations
maintain the category detachment and note attachment metadata cleanup behavior.

Schema version 1 is the actual current schema. Future additions must increment
the schema version and include tested Drift migrations. Do not add tables only
to match a planned feature list.
