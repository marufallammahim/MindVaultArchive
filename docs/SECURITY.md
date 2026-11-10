# Security and Privacy

## Current protections and limitations

- Optional six-digit app lock stores a salted PIN hash in Android secure storage.
  The gate locks on app launch and when the app returns from the background.
- The app lock is an access screen only; it does not encrypt SQLite or files.
- Notes are stored in the app-private documents database.
- No remote account, cloud sync or analytics provider is configured.
- The application does not currently provide encrypted database storage,
  encrypted attachments or biometric vault protection.
- JSON archive transfer is plaintext. Store exported JSON in a location you
  trust and do not share it if it contains private notes.

## Required before claiming vault encryption

Use a reviewed authenticated-encryption implementation, platform-backed key
protection, key rotation/recovery design, authenticated backup metadata and
integrity verification. Never store passwords or encryption keys in plaintext.
App screen lock and data-at-rest encryption must remain separate controls. The
current app lock has no PIN recovery flow; users should only enable it if they
can safely retain their PIN.
