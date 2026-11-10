# Offline / Online Feature Matrix

**Contract:** The local database and app-private files are the source of truth. Remote failure must never block local writing. A configuration screen does not mean a provider is active.

| Capability | Mode | Backend | Current baseline |
|---|---|---|---|
| Notes CRUD, autosave, drafts | LOCAL | None | Partial/implemented |
| Markdown authoring and preview | LOCAL | None | Partial |
| Notebooks, folders, tags | LOCAL | None | Categories/tags partial |
| Backlinks and knowledge graph | LOCAL | None | Title backlinks partial |
| Daily/weekly/monthly notes | LOCAL | None | Partial/not implemented |
| Quick capture | LOCAL | None | In-app partial |
| Search and FTS | LOCAL | None | Token/prefix search implemented |
| Semantic search | HYBRID | Optional embeddings | Not implemented |
| Tasks and projects | LOCAL | None | Tasks partial |
| Reminders and notifications | LOCAL + DEVICE SERVICE | None | Not implemented |
| Habits/goals/calendar | LOCAL | None | Not implemented |
| Templates | LOCAL | None | Starter templates partial |
| Attachments and drawing | LOCAL | None | Partial |
| PDF/OCR/transcription | DEVICE SERVICE / HYBRID | Optional engine | Not implemented |
| Audio recording/playback | DEVICE SERVICE | None | Partial |
| Canvas/mind maps | LOCAL | None | Not implemented |
| Import/export | LOCAL | None for local files | JSON/ZIP partial |
| Local backup/restore | LOCAL | None | ZIP backup partial |
| Local encryption/app lock | LOCAL + DEVICE SERVICE | None | PIN gate only |
| Local AI | HYBRID | No remote backend | Not implemented |
| Cloud AI | BACKEND REQUIRED | Provider/API | Not configured |
| Multi-device sync | BACKEND REQUIRED | Sync provider | Not configured |
| WebDAV/Nextcloud | BACKEND REQUIRED | User server | Not configured |
| Cloud backup | BACKEND REQUIRED | Authorized storage | Not configured |
| Public sharing/collaboration | BACKEND REQUIRED | Sharing service | Not configured |
| Local analytics | LOCAL | None | Partial |
| Cross-device analytics | BACKEND REQUIRED | Sync service | Not configured |

## Offline guarantee

Without internet, users must still be able to open the app, create/edit/delete notes, search indexed local content, organize supported records, manage local tasks, apply templates, access downloaded attachments, draw, create local backups, export data, lock/unlock and read existing records.

## Provider truthfulness

Show a provider as active only after credentials/configuration validation and a successful test operation. Keep provider errors, pending changes and last-success timestamps visible. Never fabricate online status. External transmission of note content requires explicit consent.
