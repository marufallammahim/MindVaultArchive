# Security and Privacy

## Current protections and limitations

- Notes are stored in the app-private documents database.
- No remote account, cloud sync or analytics provider is configured.
- The application does not currently provide encrypted database storage,
  encrypted attachments, app PIN/password lock or biometric vault protection.
- JSON archive transfer is plaintext. Store exported JSON in a location you
  trust and do not share it if it contains private notes.

## Required before claiming vault encryption

Use a reviewed authenticated-encryption implementation, platform-backed key
protection, key rotation/recovery design, authenticated backup metadata and
integrity verification. Never store passwords or encryption keys in plaintext.
App screen lock and data-at-rest encryption must remain separate controls.
