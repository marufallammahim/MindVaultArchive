# Security and Encryption Architecture

## Current security posture

The app has an optional six-digit PIN access gate backed by Android secure storage. It is a screen gate only. The current SQLite database, attachment files and JSON exports are not encrypted by that PIN. No end-to-end encrypted sync exists.

## Threat boundaries

Protect against casual access to an unlocked device, accidental data disclosure through previews/logs, malicious imported files, credential leakage and backup tampering. Rooted/compromised devices and coercive access cannot be fully prevented by an app-level lock; document these limitations.

## Required design before encryption implementation

- Use an audited authenticated-encryption implementation; do not design custom cryptography.
- Generate random data-encryption keys using a cryptographically secure source.
- Wrap keys with platform-backed key protection where available.
- Separate key-encryption material from encrypted database/files.
- Use authenticated metadata and versioned formats; plan key rotation and recovery.
- Never store plaintext passwords or log note contents, keys or tokens.
- Encrypt backup payloads and authenticate integrity before restore.
- Define migration and recovery before encrypting an existing database.

## Acceptance gates

Verify ciphertext at rest, invalid-key rejection, tamper detection, key loss/recovery behavior, lock timeout, sensitive preview/log exclusion and backup restore. A PIN gate must never be described as encryption. E2EE is not claimed until client key ownership, protocol and remote service behavior are verified.