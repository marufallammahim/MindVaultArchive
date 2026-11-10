# Android release signing

A release APK must be signed with a private key that you control. Never commit the keystore or passwords to Git.

## 1. Generate your own upload/release keystore

Run this on your own trusted computer (not in a public repository). Keep a secure offline backup of the resulting `upload-keystore.jks`. If you lose this key, you may not be able to update an app distributed with it.

Linux/macOS:
```bash
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 4096 -validity 10000 -alias mindvault-release
base64 -w 0 upload-keystore.jks
```

Windows PowerShell:
```powershell
keytool -genkeypair -v -keystore upload-keystore.jks -keyalg RSA -keysize 4096 -validity 10000 -alias mindvault-release
[Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks"))
```

Choose strong unique passwords when keytool asks. Save the keystore and passwords in a secure password manager and offline backup. Do not send them in chat or commit them.

## 2. Add GitHub Actions secrets

Open repository **Settings → Secrets and variables → Actions → New repository secret** and create:

| Secret name | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Entire base64 output from the command above |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | `mindvault-release` |
| `ANDROID_KEY_PASSWORD` | Key password |

Do not add these values to workflow YAML, README, issue comments, or source files.

## 3. Run a signed build

Open **Actions → Signed Android Release → Run workflow**. The workflow will:
1. Restore the private keystore from Actions secrets.
2. Run Flutter dependency resolution and Drift generation.
3. Enforce formatting, analyze Dart code, and run tests.
4. Build release APK and AAB.
5. Verify the APK certificate using Android `apksigner` and verify the AAB JAR signature.
6. Upload the signed APK, AAB, and SHA-256 checksums as a 90-day artifact.

The workflow deliberately fails if signing secrets are missing or either signature verification fails. It never falls back to the debug signing key.

## 4. Local release build

Place the keystore at `android/app/upload-keystore.jks` and create the ignored file `android/key.properties`:

```properties
storeFile=upload-keystore.jks
storePassword=YOUR_KEYSTORE_PASSWORD
keyAlias=mindvault-release
keyPassword=YOUR_KEY_PASSWORD
```

Then run:
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

The `android/key.properties` and `*.jks` files are ignored by Git. The release Gradle configuration refuses release tasks without a configured keystore; debug builds remain available without one.

## Important

The previously generated APK was confirmed **unsigned** by `jarsigner`. A build artifact existing is not proof of a valid Android release signature. Only treat a release as ready after this workflow completes and the APK signature check passes.
