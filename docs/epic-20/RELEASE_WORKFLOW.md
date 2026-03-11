# Gatherli Release Workflow

This document is the single source of truth for releasing new versions of Gatherli
to the Apple App Store and Google Play Store.

---

## Release Flow

```
Features merged to main (CI must be green)
        │
        ▼
git tag v1.0.0-beta → cd-beta.yml
        │               ├── Tests
        │               ├── Android → Play Internal Track
        │               └── iOS → TestFlight
        │
   Validate on real devices
   (TestFlight app + Play Internal link)
        │
        ├── Issues found? → fix on main → tag v1.0.0-beta2 → repeat
        │
        ▼
git tag v1.0.0 → cd-production.yml
                  ├── Tests
                  ├── Android → Play Production (live immediately)
                  └── iOS → App Store Connect (Apple review ~1-2 days)
```

---

## Step-by-Step

### 1. Beta Release

```bash
# Make sure main is up to date and CI is green
git checkout main && git pull

# Tag the beta
git tag v1.0.0-beta
git push origin v1.0.0-beta
```

**What happens automatically:**
- `validate-version-tag.yml` checks the new tag is greater than the previous one
- `cd-beta.yml` runs tests, then builds and uploads to both stores in parallel
- Android build appears in Google Play Console → Internal Testing within minutes
- iOS build appears in App Store Connect → TestFlight within ~15-30 minutes

**Validate on devices:**
- Install via TestFlight app on iPhone/iPad
- Install via Play Store internal testing link on Android
- Test all critical flows on real devices

### 2. Fix a Bad Beta

If the beta has issues:

```bash
# Fix on main, then tag a new beta
git tag v1.0.0-beta2
git push origin v1.0.0-beta2
```

Repeat until the beta is stable.

### 3. Production Release

```bash
# Beta must be validated first
git tag v1.0.0
git push origin v1.0.0
```

**What happens automatically:**
- `validate-version-tag.yml` checks the new tag is greater than the previous one
- `cd-production.yml` runs tests, then builds and uploads to both stores
- Android: live on Play Store Production within minutes
- iOS: enters Apple review (typically 1-2 days), then goes live automatically

---

## Hotfix (Emergency Fix for Production)

If a critical bug is found in production and main has moved on:

```bash
# 1. Branch from the last good production tag
git checkout -b hotfix/v1.0.1 v1.0.0

# 2. Apply the fix
git commit -m "fix: critical bug description"

# 3. Tag directly from the hotfix branch
git tag v1.0.1
git push origin v1.0.1
# Pipeline builds from this commit, not from main

# 4. Merge the fix back to main
git checkout main
git merge hotfix/v1.0.1
git push origin main
```

---

## Rollback

### Android
Google Play Console → Production → the current release → **"Rollback release"**
Takes effect within minutes. No re-upload needed.

### iOS
Apple does not support rollback. Options:
1. **Remove from sale** in App Store Connect (existing users keep the app)
2. **Expedited review**: submit a hotfix and request fast-track review from Apple
   - Available at: appstoreconnect.apple.com → Contact Us → Expedite a Review

---

## Version Enforcement

Two mechanisms prevent accidental or out-of-order releases:

### 1. GitHub Tag Protection Ruleset (Option A)
The ruleset **"Protect version tags"** (ID: 13791276) is active on all `v*` tags:
- **Deletion blocked**: no one can delete a published version tag
- **Creation restricted**: only repository admins can create `v*` tags
- Prevents accidental or unauthorized releases

### 2. Version Validation Workflow (Option B)
`.github/workflows/validate-version-tag.yml` runs on every `v*` tag push:
- Compares the new tag against all existing tags using version-aware sort
- Fails immediately if the new tag is not strictly greater than the latest
- Blocks the CD pipelines from running on an invalid tag
- Clear error message explains how to fix the issue

---

## Tagging Convention

| Tag | Description | Destination |
|-----|-------------|-------------|
| `v1.0.0-beta` | First beta for 1.0.0 | TestFlight + Play Internal |
| `v1.0.0-beta2` | Second beta iteration | TestFlight + Play Internal |
| `v1.0.0` | Production release | App Store + Play Production |
| `v1.0.1` | Patch / hotfix | App Store + Play Production |
| `v1.1.0` | Minor release | App Store + Play Production |
| `v2.0.0` | Major release | App Store + Play Production |

---

## Pipeline Overview

| Workflow file | Trigger | Purpose |
|--------------|---------|---------|
| `main.yml` | PR to main | CI: tests, lint, security audit |
| `validate-version-tag.yml` | Any `v*` tag | Verify tag is incremental |
| `cd-beta.yml` | `v*-beta*` tags | Deploy to TestFlight + Play Internal |
| `cd-production.yml` | `v[0-9]+.[0-9]+.[0-9]+` tags | Deploy to App Store + Play Production |

---

## Required GitHub Secrets

See `docs/epic-20/story-20.1/SECRETS_SETUP.md` for the full list and setup instructions.
