# AI Integration

**Status:** Architecture only; no provider is configured.

## Interfaces

- `AIProvider`: generate text, summarize, answer with supplied context and report model/capabilities.
- `EmbeddingProvider`: create embeddings for explicitly selected content.
- `ContextRetriever`: retrieve authorized local notes and return source IDs/snippets.
- `AIConsentPolicy`: verify user consent for the provider and scope before any external transmission.

## Workflow

User request → consent and privacy checks → retrieve permitted note context → provider request → validate response/source references → show answer with citations → user may open original notes. AI output must be visually distinguishable from source text.

## Rules

- AI is optional; local notes/search continue if unavailable.
- Locked notes and unauthorized records are excluded.
- Never transmit archive-wide content by default.
- Never fabricate source references; each citation must resolve to a note.
- API keys use secure storage and are never logged.
- Provide provider selection, local-only mode, history deletion and consent revocation.
- Local AI requires model/runtime resources and device capability verification; do not promise compatibility without testing.