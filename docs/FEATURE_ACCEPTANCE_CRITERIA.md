# Feature Acceptance Criteria

A feature may be marked tested only when its criteria pass on a recorded commit.

| ID | Minimum acceptance evidence |
|---|---|
| F01 | Create/edit note; stable ID; autosave; restart persistence; draft recovery; save errors visible; formatting and attachments reopen. |
| F02 | Move note; assign/remove tags; nested folder integrity; bulk actions; trash/restore; duplicate/merge without data loss. |
| F03 | Capture offline; draft survives process interruption; convert capture to note/task; Android entry points validate payloads. |
| F04 | Consent before transmission; locked content excluded; answers cite real notes; unavailable provider leaves core app working. |
| F05 | Attach/reopen supported file; validate type/path; backup bytes; restore integrity; shared attachment reference is safe. |
| F06 | Note task appears in global list; edits synchronize both views; due date/priority/completion persist; reminders honor timezone. |
| F07 | Offline search; index updates after edit/delete; filters and exact phrase behavior; locked content not leaked. |
| F08 | Invalid PIN rejected; protected data encryption verified separately; tampered backup rejected; sensitive content absent from logs/previews. |
| F09 | Offline operations queue; replay is idempotent; conflict visible; explicit resolution preserves both versions. |
| F10 | Import preview/validation; invalid archive rejected; no overwrite by ID collision; JSON/ZIP round-trip preserves supported metadata and attachments. |
| F11 | Board positions/zoom/connections persist; linked note/task opens canonical record; large board remains responsive. |
| F12 | Template application creates persistent editable note; variables resolve; custom templates export/import. |
| F13 | Theme/preferences survive restart; dynamic text scaling; reduced motion; Bengali and English strings render correctly. |
| F14 | Local Android share works offline; remote permissions, expiry and revocation enforced by configured backend. |
| F15 | Suggestions show rationale; user approves mutations; duplicate/link analysis is deterministic and tested. |
| F16 | Code blocks preserve text/language; safe syntax rendering; copy works; arbitrary code is never executed. |
| F17 | Timeline filters correctly; analytics match database aggregates; legacy export integrity verified and restorable. |
| F18 | Android intents/widgets/shortcuts handle lifecycle and denial; no unnecessary permission; accessibility tested. |
| F19 | Integrated workflows use shared canonical records; no duplicate silo data; privacy rules remain consistent. |
| F20 | Roadmap phase gates and dependencies documented; every feature remains tracked. |
| F21 | Unit/widget/database/integration tests; migration/restore/crash tests; analyze/format/build results recorded. |
| F22 | Shared tokens/components; phone/tablet/landscape; contrast, screen reader, text scaling and empty/error/loading states verified. |

## Critical cross-feature workflows

Create note → edit/autosave → restart → attach file → create linked task → search → link another note → export → restore → lock/unlock → offline operation → (if configured) sync → simulate and resolve conflict → recover interrupted draft.

Do not mark a workflow passed unless it was executed and the result is recorded.