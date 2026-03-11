# Story 20.7 — End-to-End Pipeline Validation Guide

## Prerequisites

Before running validation, ensure all previous stories are merged to main:
- ✅ Story 20.1: GitHub Secrets configured
- ✅ Story 20.2: Android signing configured
- ✅ Story 20.3: iOS ExportOptions.plist present
- ✅ Story 20.4: Version extraction composite action
- ✅ Story 20.5: cd-beta.yml workflow
- ✅ Story 20.6: cd-production.yml workflow
- ✅ Story 20.7: validate-version-tag.yml workflow

---

## Phase 1: Validate Tag Protection (Option A)

Verify the GitHub Ruleset is active:
- [ ] Go to GitHub → Repository → Settings → Rules → Rulesets
- [ ] Confirm "Protect version tags" ruleset exists and is **Active**
- [ ] Confirm it applies to `refs/tags/v*`
- [ ] Confirm rules include: Deletion, Creation, Non-fast-forward

---

## Phase 2: Validate Version Enforcement (Option B)

### Test 1 — Invalid tag is rejected

```bash
# Assuming v0.1.0-beta already exists, try to push an older tag
git tag v0.0.1
git push origin v0.0.1
```

**Expected:** `validate-version-tag.yml` fails with:
```
❌ ERROR: v0.0.1 is not greater than the latest tag v0.1.0-beta.
```

Clean up:
```bash
git tag -d v0.0.1
git push origin --delete v0.0.1
```

### Test 2 — Duplicate tag is rejected

```bash
# Try to push a tag that already exists
git tag v0.1.0-beta
git push origin v0.1.0-beta
```

**Expected:** Git itself rejects this with "tag already exists".

---

## Phase 3: Beta Pipeline End-to-End

```bash
git tag v0.1.0-beta
git push origin v0.1.0-beta
```

**Verify in GitHub Actions:**
- [ ] `validate-version-tag.yml` triggers and passes
- [ ] `cd-beta.yml` triggers (not `cd-production.yml`)
- [ ] `test` job passes
- [ ] `deploy_android` and `deploy_ios` jobs start in parallel after tests

**Verify Android:**
- [ ] `deploy_android` job succeeds
- [ ] AAB appears in Google Play Console → Internal Testing
- [ ] Version name matches `0.1.0-beta`
- [ ] Build number matches GitHub Actions run number
- [ ] Install on Android device via internal testing link
- [ ] App opens and connects to Firebase prod project

**Verify iOS:**
- [ ] `deploy_ios` job succeeds
- [ ] Build appears in App Store Connect → TestFlight (allow ~15-30 min processing)
- [ ] Install on iPhone via TestFlight app
- [ ] App opens and connects to Firebase prod project

---

## Phase 4: Production Pipeline End-to-End

```bash
git tag v0.1.0
git push origin v0.1.0
```

**Verify in GitHub Actions:**
- [ ] `validate-version-tag.yml` triggers and passes
- [ ] `cd-production.yml` triggers (not `cd-beta.yml`)
- [ ] `test` job passes
- [ ] Both deploy jobs succeed

**Verify Android:**
- [ ] AAB appears in Google Play Console → Production track
- [ ] Version name is `0.1.0` (no beta suffix)

**Verify iOS:**
- [ ] Build appears in App Store Connect → "Pending Developer Release" or "Waiting for Review"
- [ ] Submit for Apple review from App Store Connect UI

---

## Phase 5: Failure Scenario Tests

### Test — Failing tests block deployment

Temporarily introduce a failing test, then tag:
```bash
git tag v0.1.1-beta
git push origin v0.1.1-beta
```

**Expected:** `test` job fails → `deploy_android` and `deploy_ios` never start.

Revert the failing test and delete the tag:
```bash
git tag -d v0.1.1-beta
git push origin --delete v0.1.1-beta
```

---

## Checklist — Epic 20 Complete

- [ ] Phase 1: Tag protection ruleset active
- [ ] Phase 2: Version validation workflow blocks invalid tags
- [ ] Phase 3: Beta pipeline deploys to TestFlight and Play Internal
- [ ] Phase 4: Production pipeline deploys to App Store and Play Production
- [ ] Phase 5: Failing tests block all deployment jobs
- [ ] `docs/epic-20/RELEASE_WORKFLOW.md` reviewed and accurate
