# Development Guide

## Requirements
- Flutter stable compatible with the Dart SDK constraint in `pubspec.yaml`.
- Android SDK and Java 17 for Android CI/builds.

## Setup
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Verification
```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

The Android CI workflow runs dependency resolution, Drift code generation,
formatting, analysis, tests and a debug APK build. Check the GitHub Actions run
for the exact result for each commit.
