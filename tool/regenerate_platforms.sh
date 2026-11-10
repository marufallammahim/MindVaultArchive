#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.marufallammahim.mindvaultarchive"
ORG="com.marufallammahim"
PROJECT="mindvault_archive"

command -v flutter >/dev/null 2>&1 || {
  echo "Flutter SDK is required to generate native platform scaffolding." >&2
  exit 1
}

# The repository may contain partial native folders. Regenerate the platform
# scaffolding if any build-critical file is missing, not only when the folder
# itself is absent.
if [[ ! -x android/gradlew || ! -f android/settings.gradle || ! -f android/gradle/wrapper/gradle-wrapper.properties || ! -f ios/Runner.xcodeproj/project.pbxproj ]]; then
  flutter create --overwrite --no-pub --platforms=android,ios --org "$ORG" --project-name "$PROJECT" .
fi

# Enforce canonical Android application ID and namespace.
if [[ -f android/app/build.gradle ]]; then
  sed -i -E "s/applicationId .*/applicationId \"$APP_ID\"/" android/app/build.gradle
  sed -i -E "s/namespace .*/namespace \"$APP_ID\"/" android/app/build.gradle
elif [[ -f android/app/build.gradle.kts ]]; then
  sed -i -E "s/applicationId = .*/applicationId = \"$APP_ID\"/" android/app/build.gradle.kts
  sed -i -E "s/namespace = .*/namespace = \"$APP_ID\"/" android/app/build.gradle.kts
fi

MANIFEST="android/app/src/main/AndroidManifest.xml"
if [[ -f "$MANIFEST" ]] && ! grep -q 'android.permission.RECORD_AUDIO' "$MANIFEST"; then
  sed -i 's#<manifest xmlns:android="http://schemas.android.com/apk/res/android">#<manifest xmlns:android="http://schemas.android.com/apk/res/android">\n    <uses-permission android:name="android.permission.RECORD_AUDIO" />#' "$MANIFEST"
fi

PLIST="ios/Runner/Info.plist"
if [[ -f "$PLIST" ]]; then
  python3 - "$PLIST" <<'PY'
import plistlib, sys
path = sys.argv[1]
with open(path, "rb") as stream:
    data = plistlib.load(stream)
data.setdefault(
    "NSMicrophoneUsageDescription",
    "MindVault Archive uses the microphone only when you record a voice note."
)
with open(path, "wb") as stream:
    plistlib.dump(data, stream)
PY
fi

PBX="ios/Runner.xcodeproj/project.pbxproj"
if [[ -f "$PBX" ]]; then
  sed -i -E "s/PRODUCT_BUNDLE_IDENTIFIER = [^;]+;/PRODUCT_BUNDLE_IDENTIFIER = $APP_ID;/g" "$PBX"
fi

echo "Android and iOS scaffolding ready for $APP_ID"
