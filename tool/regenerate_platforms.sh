#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.marufallammahim.mindvaultarchive"
ORG="com.marufallammahim"
PROJECT="mindvault_archive"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is required to generate native platform scaffolding." >&2
  exit 1
fi

platforms=()
[[ -d android ]] || platforms+=(android)
[[ -d ios ]] || platforms+=(ios)

if (("${#platforms[@]}" > 0)); then
  joined=$(IFS=,; echo "${platforms[*]}")
  flutter create --no-pub --platforms="$joined" --org "$ORG" --project-name "$PROJECT" .
fi

# Enforce the canonical Android application ID and namespace.
if [[ -f android/app/build.gradle ]]; then
  sed -i -E "s/applicationId .*/applicationId \"$APP_ID\"/" android/app/build.gradle
  sed -i -E "s/namespace .*/namespace \"$APP_ID\"/" android/app/build.gradle
elif [[ -f android/app/build.gradle.kts ]]; then
  sed -i -E "s/applicationId = .*/applicationId = \"$APP_ID\"/" android/app/build.gradle.kts
  sed -i -E "s/namespace = .*/namespace = \"$APP_ID\"/" android/app/build.gradle.kts
fi

# Ensure recording permission and a user-facing microphone disclosure.
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [[ -f "$MANIFEST" ]] && ! grep -q 'android.permission.RECORD_AUDIO' "$MANIFEST"; then
  sed -i 's#<manifest xmlns:android="http://schemas.android.com/apk/res/android">#<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n    <uses-permission android:name="android.permission.RECORD_AUDIO" />#' "$MANIFEST"
fi

PLIST="ios/Runner/Info.plist"
if [[ -f "$PLIST" ]] && ! grep -q 'NSMicrophoneUsageDescription' "$PLIST"; then
  /usr/libexec/PlistBuddy -c "Add :NSMicrophoneUsageDescription string MindVault Archive uses the microphone only when you record a voice note." "$PLIST"
fi

echo "Native scaffolding ready for $APP_ID"
