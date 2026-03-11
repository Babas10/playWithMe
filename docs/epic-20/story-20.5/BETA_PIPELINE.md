# Story 20.5 — Beta CD Pipeline

## Overview

File: `.github/workflows/cd-beta.yml`

Triggers on beta tags (`v*-beta`, `v*-beta2`, etc.) and deploys to:
- **Google Play Internal Testing track** (Android)
- **TestFlight** via App Store Connect (iOS)

---

## Trigger

```bash
git tag v1.0.0-beta
git push origin v1.0.0-beta
```

Supported tag patterns:
- `v1.0.0-beta`
- `v1.0.0-beta2`
- `v1.0.0-beta99`

---

## Job Structure

```
test (ubuntu)
├── flutter analyze
└── flutter test test/unit/ test/widget/
    │
    ├── deploy_android (ubuntu) — runs in parallel after test passes
    │   ├── Extract version from tag
    │   ├── Generate Firebase prod config
    │   ├── Decode Android keystore
    │   ├── flutter build appbundle --flavor prod
    │   ├── Decode Google Play service account
    │   └── Upload AAB to Play Internal Track
    │
    └── deploy_ios (macos-latest) — runs in parallel after test passes
        ├── Extract version from tag
        ├── Generate Firebase prod config
        ├── Install App Store Connect API key
        └── flutter build ipa --flavor prod (uploads to TestFlight via ExportOptions.plist)
```

Android and iOS deploy jobs run **in parallel** after tests pass.

---

## Secrets Used

| Secret | Job |
|--------|-----|
| `FIREBASE_PROD_*` (8 secrets) | Both |
| `ANDROID_KEYSTORE_BASE64` | Android |
| `ANDROID_KEY_ALIAS` | Android |
| `ANDROID_KEY_PASSWORD` | Android |
| `ANDROID_STORE_PASSWORD` | Android |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Android |
| `APP_STORE_CONNECT_API_KEY_BASE64` | iOS |
| `APP_STORE_CONNECT_API_KEY_ID` | iOS |

---

## What Happens After Upload

**Android:** Build is immediately available in the Google Play Console under
Internal Testing. Invite testers via the Play Console to get the install link.

**iOS:** Build enters "Processing" in App Store Connect (~5-15 min), then appears
in TestFlight. Internal testers can install it via the TestFlight app.

---

## If the Beta Has Issues

Fix on main, then tag again with an incremented beta number:

```bash
git tag v1.0.0-beta2
git push origin v1.0.0-beta2
```
