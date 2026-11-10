# Flutter Dependency Plan

## Current declared dependency baseline

Read from the current feature-branch `pubspec.yaml` (declared constraints, not resolved versions):

| Purpose | Package | Declared constraint |
|---|---|---|
| State | flutter_riverpod | ^2.4.9 |
| Navigation | go_router | ^12.1.1 |
| Database | drift | ^2.14.0 |
| SQLite native runtime | sqlite3_flutter_libs | ^0.5.18 |
| Filesystem | path_provider, path | ^2.1.1, ^1.8.3 |
| Audio playback | just_audio | ^0.9.36 |
| SVG | flutter_svg | ^2.0.9 |
| Markdown | flutter_markdown_plus | ^1.0.12 |
| File selection | file_picker | ^10.3.8 |
| Sharing | share_plus | ^10.1.4 |
| Archive | archive | ^3.6.1 |
| Hashing | crypto | ^3.0.6 |
| Secure storage | flutter_secure_storage | ^9.2.4 |
| Fonts | google_fonts | ^6.1.0 |
| Localization/time | intl | ^0.20.3 |
| IDs | uuid | ^4.2.2 |
| Permissions | permission_handler | ^11.1.1 |
| Preferences | shared_preferences | ^2.2.2 |
| Drawing | signature | ^5.4.0 |
| Code generation | build_runner, drift_dev | ^2.4.7, ^2.14.0 |
| Lints | flutter_lints | ^3.0.1 |

Flutter SDK dependency is declared as >=3.4.0 <4.0.0. Android config currently uses compile SDK 36, min SDK 23 and Java/Kotlin 17.

## Decisions

- Retain Riverpod, GoRouter and Drift; avoid a competing state-management or database package.
- Keep SQLite local-first; add schema only with a migration and fixture tests.
- Add packages only for a concrete feature slice after checking current maintenance, license, Android SDK compatibility, transitive dependencies, permissions and offline behavior.
- Prefer platform services for biometric, notification and intent integrations where practical.
- Secure storage is not equivalent to database encryption.
- `pubspec.lock` could not be fetched from the inspected branch path; verify whether it is tracked and commit a generated lockfile for this application.

## Verification gap

The declared constraints above are not exact resolved package versions. Do not report exact resolved versions until `pubspec.lock` is present and inspected with `flutter pub get`.