#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.marufallammahim.mindvaultarchive"
ORG="com.marufallammahim"
PROJECT="mindvaultarchive"

command -v flutter >/dev/null 2>&1 || {
  echo "Flutter SDK is required to generate native platform scaffolding." >&2
  exit 1
}
command -v python3 >/dev/null 2>&1 || {
  echo "Python 3 is required to patch the iOS property list." >&2
  exit 1
}

# Never run "flutter create --overwrite" in the application repository.
# That command replaces pubspec.yaml and lib/main.dart with Flutter's demo
# template. Generate native scaffolding in an isolated temporary project and
# copy only missing native files into this checkout.
needs_native_scaffold=false
if [[ ! -x android/gradlew ||
      ! -f android/gradle/wrapper/gradle-wrapper.jar ||
      ! -f android/gradle/wrapper/gradle-wrapper.properties ||
      ( ! -f android/settings.gradle && ! -f android/settings.gradle.kts ) ||
      ( ! -f android/app/build.gradle && ! -f android/app/build.gradle.kts ) ||
      ! -f ios/Runner.xcodeproj/project.pbxproj ]]; then
  needs_native_scaffold=true
fi

if [[ "$needs_native_scaffold" == "true" ]]; then
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT
  flutter create \
    --no-pub \
    --platforms=android,ios \
    --org "$ORG" \
    --project-name "$PROJECT" \
    "$tmp_dir/scaffold"

  mkdir -p android ios
  # -n preserves every existing app-specific native file and only adds files
  # that are absent (Gradle wrapper, settings, Xcode project, etc.).
  cp -Rn "$tmp_dir/scaffold/android/." android/
  cp -Rn "$tmp_dir/scaffold/ios/." ios/
fi

# Ensure the Gradle wrapper can be executed on Linux runners.
if [[ -f android/gradlew ]]; then
  chmod +x android/gradlew
fi

# Enforce canonical Android application ID and namespace, supporting both
# Groovy and Kotlin Gradle DSLs.
if [[ -f android/app/build.gradle ]]; then
  python3 - "$APP_ID" android/app/build.gradle <<'PY'
import re, sys
app_id, path = sys.argv[1:]
text = open(path, encoding="utf-8").read()
text, n1 = re.subn(r'(?m)^\s*namespace\s+["\'][^"\']+["\']', f'    namespace "{app_id}"', text, count=1)
text, n2 = re.subn(r'(?m)^\s*applicationId\s+["\'][^"\']+["\']', f'        applicationId "{app_id}"', text, count=1)
if n1 != 1 or n2 != 1:
    raise SystemExit("Could not enforce Android namespace/applicationId in build.gradle")
open(path, "w", encoding="utf-8").write(text)
PY
elif [[ -f android/app/build.gradle.kts ]]; then
  python3 - "$APP_ID" android/app/build.gradle.kts <<'PY'
import re, sys
app_id, path = sys.argv[1:]
text = open(path, encoding="utf-8").read()
text, n1 = re.subn(r'(?m)^\s*namespace\s*=\s*["\'][^"\']+["\']', f'    namespace = "{app_id}"', text, count=1)
text, n2 = re.subn(r'(?m)^\s*applicationId\s*=\s*["\'][^"\']+["\']', f'        applicationId = "{app_id}"', text, count=1)
if n1 != 1 or n2 != 1:
    raise SystemExit("Could not enforce Android namespace/applicationId in build.gradle.kts")
open(path, "w", encoding="utf-8").write(text)
PY
else
  echo "Android app Gradle build file is missing after scaffolding." >&2
  exit 1
fi

MANIFEST="android/app/src/main/AndroidManifest.xml"
if [[ -f "$MANIFEST" ]] && ! grep -q 'android.permission.RECORD_AUDIO' "$MANIFEST"; then
  python3 - "$MANIFEST" <<'PY'
import sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
needle = '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
if needle not in text:
    raise SystemExit("Could not locate Android manifest root element")
text = text.replace(needle, needle + '\n    <uses-permission android:name="android.permission.RECORD_AUDIO" />', 1)
open(path, "w", encoding="utf-8").write(text)
PY
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

# Guard against the original regression: the app manifest and entry point must
# remain present and the application package must not be replaced by a demo.
test -f pubspec.yaml
test -f lib/main.dart
grep -q '^name: mindvault_archive$' pubspec.yaml
grep -q 'MindVaultArchiveApp' lib/main.dart || {
  echo "lib/main.dart no longer contains the MindVault Archive app entry point." >&2
  exit 1
}

echo "Native scaffolding ready; application source and pubspec.yaml preserved."
