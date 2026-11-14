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

  # Copy only missing files without relying on non-portable "cp -n".
  # The generated Flutter scaffold must never overwrite app-specific files.
  copy_missing_tree() {
    local source_root="${1%/}"
    local destination_root="${2%/}"
    local source_path relative destination_path

    mkdir -p "$destination_root"
    while IFS= read -r -d '' source_path; do
      relative="${source_path#"$source_root"/}"
      destination_path="$destination_root/$relative"
      if [[ -d "$source_path" && ! -L "$source_path" ]]; then
        mkdir -p "$destination_path"
      elif [[ ! -e "$destination_path" && ! -L "$destination_path" ]]; then
        mkdir -p "$(dirname "$destination_path")"
        cp -pP "$source_path" "$destination_path"
      fi
    done < <(find "$source_root" -mindepth 1 -print0)
  }

  copy_missing_tree "$tmp_dir/scaffold/android" android
  copy_missing_tree "$tmp_dir/scaffold/ios" ios

  # Never leave two competing Gradle DSL files in the same project directory.
  if [[ -f android/app/build.gradle && -f android/app/build.gradle.kts ]]; then
    rm android/app/build.gradle.kts
  fi
  if [[ -f android/settings.gradle && -f android/settings.gradle.kts ]]; then
    rm android/settings.gradle.kts
  fi
  if [[ -f android/build.gradle && -f android/build.gradle.kts ]]; then
    rm android/build.gradle.kts
  fi
fi

# Ensure Gradle plugin transitive dependencies can be resolved from the
# official Google Maven and Maven Central repositories. Flutter's generated
# settings file may otherwise leave Kotlin DSL/plugin artifacts restricted to
# the Gradle Plugin Portal on some SDK/Gradle combinations.
python3 - <<'PY'
from pathlib import Path

candidates = [Path("android/settings.gradle"), Path("android/settings.gradle.kts")]
settings = next((p for p in candidates if p.is_file()), None)
if settings is None:
    raise SystemExit("Android settings.gradle(.kts) is missing after scaffolding")

lines = settings.read_text(encoding="utf-8").splitlines()
pm = next((i for i, line in enumerate(lines) if line.strip() == "pluginManagement {"), None)
if pm is None:
    raise SystemExit("Could not find pluginManagement block in Android settings")
repo = next((i for i in range(pm + 1, len(lines)) if lines[i].strip() == "repositories {"), None)
if repo is None:
    raise SystemExit("Could not find pluginManagement.repositories block")
close = next((i for i in range(repo + 1, len(lines)) if lines[i].strip() == "}"), None)
if close is None:
    raise SystemExit("Could not find end of pluginManagement.repositories block")
existing = {line.strip() for line in lines[repo + 1:close]}
additions = [f"        {name}" for name in ("google()", "mavenCentral()") if name not in existing]
if additions:
    lines[close:close] = additions
    settings.write_text("\n".join(lines) + "\n", encoding="utf-8")
print("Gradle plugin repositories verified: Google Maven + Maven Central")
PY

# Keep root project dependency repositories explicit as well; the pluginManagement block above handles plugin classpaths.
if [[ -f android/build.gradle ]]; then
  grep -q 'google()' android/build.gradle || sed -i '/allprojects[[:space:]]*{/a\\    repositories { google(); mavenCentral() }' android/build.gradle
fi

# The app module's compileSdk is pinned to API 36 in
# android/app/build.gradle. Do not mutate third-party plugin build files here:
# Flutter resolves plugin packages only after "flutter pub get".

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
text, n3 = re.subn(r'(?m)^\s*compileSdkVersion\s+[^\n]+', '    compileSdkVersion 36', text, count=1)
if n1 != 1 or n2 != 1 or n3 != 1:
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
text, n3 = re.subn(r'(?m)^\s*compileSdk\s*=\s*[^\n]+', '    compileSdk = 36', text, count=1)
if n1 != 1 or n2 != 1 or n3 != 1:
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
grep -q 'MindVaultArchiveApp' lib/main.dart
grep -q 'class MindVaultArchiveApp' lib/app/app.dart || {
  echo "MindVault Archive app widget is missing from lib/app/app.dart." >&2
  exit 1
}

echo "Native scaffolding ready; application source and pubspec.yaml preserved."
