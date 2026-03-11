# Story 20.2 — Android Signing & Release Build Configuration

## Overview

The Android release build is configured to sign the AAB using credentials injected
from environment variables. Locally (without env vars set), the build falls back to
debug signing so `flutter run --release` continues to work during development.

---

## Signing Configuration

File: `android/app/build.gradle.kts`

The signing config reads four environment variables at build time:

| Environment Variable | GitHub Secret | Description |
|---------------------|---------------|-------------|
| `ANDROID_KEYSTORE_PATH` | — | Path to decoded `.jks` file (set by CI step) |
| `ANDROID_STORE_PASSWORD` | `ANDROID_STORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | `ANDROID_KEY_ALIAS` | Key alias |
| `ANDROID_KEY_PASSWORD` | `ANDROID_KEY_PASSWORD` | Key password |

The keystore file itself is stored as `ANDROID_KEYSTORE_BASE64` in GitHub Secrets
and decoded to `android/app/release.jks` by the CI pipeline before the build runs.

---

## ProGuard

File: `android/app/proguard-rules.pro`

Rules configured to preserve:
- Flutter engine classes
- Firebase SDK classes
- Kotlin coroutines
- Firestore serialization annotations

`isMinifyEnabled = true` and `isShrinkResources = true` are enabled for release
builds to reduce APK/AAB size.

---

## Build Command

Used in CI pipeline (Stories 20.5 and 20.6):

```bash
flutter build appbundle --release --flavor prod \
  -t lib/main_prod.dart \
  --build-name=$VERSION_NAME \
  --build-number=$BUILD_NUMBER
```

Output: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`

---

## Local Release Build (without CI secrets)

Falls back to debug signing automatically — no configuration needed locally:

```bash
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

---

## CI Decode Step

The pipeline decodes the base64 keystore before building:

```yaml
- name: Decode keystore
  run: |
    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode \
      > android/app/release.jks
```

`android/app/release.jks` is in `.gitignore` and never committed.
