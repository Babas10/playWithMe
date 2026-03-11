# Story 20.6 — Production CD Pipeline

## Overview

File: `.github/workflows/cd-production.yml`

Triggers on production tags (`v1.0.0`, `v1.2.3`, etc. — no pre-release suffix) and
deploys to:
- **Google Play Production track** (Android) — goes live immediately
- **App Store Connect** (iOS) — enters Apple review (~1-2 days), then goes live

---

## Trigger

```bash
git tag v1.0.0
git push origin v1.0.0
```

The tag pattern `v[0-9]+.[0-9]+.[0-9]+` explicitly matches only clean semantic
version tags and does **not** match `-beta` or any other pre-release suffix.

---

## Job Structure

Identical structure to cd-beta.yml, with two differences:

| | Beta | Production |
|--|------|------------|
| Android track | `internal` | `production` |
| iOS destination | TestFlight | App Store review |
| Trigger | `v*-beta*` | `v[0-9]+.[0-9]+.[0-9]+` |

```
test (ubuntu)
├── flutter analyze
└── flutter test test/unit/ test/widget/
    │
    ├── deploy_android (ubuntu)
    │   └── Upload AAB to Play Production track
    │
    └── deploy_ios (macos-latest)
        └── flutter build ipa → uploads to App Store Connect
```

---

## Secrets Used

Same as the beta pipeline. See `docs/epic-20/story-20.5/BETA_PIPELINE.md`.

---

## What Happens After Upload

**Android:** The release goes live on the Play Store Production track immediately
after processing (usually within a few minutes).

**iOS:** The build appears in App Store Connect under the app version. You must:
1. Go to App Store Connect → your app → the version
2. Select the uploaded build
3. Click "Submit for Review"

Apple review typically takes 1-2 days. Once approved, the update goes live.

---

## Pre-requisites Before Tagging Production

1. A beta build (`v*-beta`) has been validated on TestFlight and Play Internal
2. The app version in App Store Connect has been prepared (screenshots, description,
   release notes) if this is a new version
3. CI is green on main

---

## Rollback

**Android:** Google Play Console → Release → Production → the release → "Halt rollout"
Then re-submit the previous AAB or fix and tag a new patch version.

**iOS:** App Store Connect → remove the version from sale, or contact Apple support.
Then fix on main and tag a new patch version.
