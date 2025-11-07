# CI/CD Workflow Structure

**Updated:** November 2025

This document explains the simplified 2-workflow structure for the PlayWithMe project.

---

## 🎯 Design Philosophy

**Separation of Concerns:**
- **Quality checks** run automatically on every PR (fast feedback)
- **Platform builds** run on-demand when needed (avoid unnecessary builds)

---

## 🔄 Workflow Overview

### 1. **CI/CD Pipeline** (`.github/workflows/main.yml`)

**Purpose:** Fast quality validation

**Triggers:**
- ✅ Automatically on pull requests to main/develop

**What it does:**
- 📊 Static analysis (`flutter analyze`)
- 🎨 Code formatting check
- 🧪 Unit tests
- 🧪 Widget tests
- 🔒 Security audit
- 🔍 Secret detection

**Duration:** ~2-3 minutes ⚡

**Jobs:** 3
1. `analyze_and_test` - Core quality checks
2. `security_audit` - Security validation
3. `ci_success` - Final status

---

### 2. **Build Verification** (`.github/workflows/build-verification.yml`)

**Purpose:** Platform artifact generation

**Triggers:**
- ⚙️ Manual trigger via workflow_dispatch
- 🔧 Can be triggered from GitHub Actions UI

**What it does:**
- 🤖 Builds Android APK (with Gradle caching)
- 🌐 Builds Web app
- 📦 Uploads artifacts (7-day retention)
- 🔧 Supports custom platform/flavor selection

**Duration:** ~8-10 minutes (first run), ~5-8 minutes (cached)

**Jobs:** 4
1. `prepare_configs` - Generate Firebase configs
2. `build_android` - Build Android APK
3. `build_web` - Build web app
4. `build_success` - Final status

---

## 📊 Comparison with Old Structure

### Before:
```
PR Created
  ↓
pr-fast-check.yml (2-3 min)  ← Tests
  +
main.yml (15-20 min)         ← Tests + Builds
  ↓
TOTAL: ~20 minutes
Runs duplicate tests ❌
```

### After:
```
PR Created
  ↓
main.yml (2-3 min)           ← Tests only ✅
  ↓
Ready for review!

(Optional: Trigger build-verification.yml manually)
  ↓
build-verification.yml (8-10 min) ← Builds only
  ↓
Artifacts ready for deployment
```

---

## 🚀 How to Use

### For Developers (Every PR):

**Step 1:** Create PR
```bash
git push origin feature/my-feature
# Create PR on GitHub
```

**Step 2:** Wait for CI/CD Pipeline
- Runs automatically
- Completes in ~2-3 minutes
- Get fast feedback on code quality

**Step 3:** Review feedback
- ✅ All checks passed → Ready for review
- ❌ Checks failed → Fix issues and push again

---

### For Builds (When Needed):

**When to trigger builds:**
- 🚀 Before deployment
- 🧪 Manual testing on devices
- 📦 Creating release candidates
- 🔍 Verifying platform-specific issues

**How to trigger:**

1. Go to **Actions** tab on GitHub
2. Select **Build Verification** workflow
3. Click **Run workflow**
4. Configure inputs:
   - **Platforms:** `android,web` (or specific platform)
   - **Flavors:** `dev` or `dev,stg,prod`
5. Click **Run workflow**

**Example configurations:**

| Use Case | Platforms | Flavors |
|----------|-----------|---------|
| Quick dev test | `android` | `dev` |
| Full staging build | `android,web` | `stg` |
| Production release | `android,web` | `prod` |
| All environments | `android,web` | `dev,stg,prod` |

---

## ⚡ Performance Benefits

### PR Feedback Time:
- **Before:** ~20-25 minutes (tests + builds)
- **After:** ~2-3 minutes (tests only)
- **Improvement:** **85-90% faster** ⚡

### Build Time (when needed):
- **First run:** ~8-10 minutes
- **Cached run:** ~5-8 minutes (50% faster)
- **Only runs when you need it** ✅

### CI/CD Costs:
- **Before:** Every PR ran 6+ builds (15-20 min)
- **After:** PRs run only tests (2-3 min), builds on-demand
- **Savings:** ~80% reduction in CI minutes per PR

---

## 📦 Build Artifacts

When you trigger `build-verification.yml`, artifacts are uploaded:

**Android APK:**
- Name: `android-apk-{flavor}`
- Location: Actions → Workflow run → Artifacts
- Retention: 7 days

**Web Build:**
- Name: `web-build-{flavor}`
- Location: Actions → Workflow run → Artifacts
- Retention: 7 days

**Download artifacts:**
1. Go to the workflow run
2. Scroll to **Artifacts** section
3. Click to download ZIP

---

## 🔐 Security Notes

### Firebase Configs:
- ❌ Never committed to repository
- ✅ Generated from GitHub Secrets
- ✅ Shared via artifacts (1-day retention)
- ✅ Only in `build-verification.yml`

### Mock Configs:
- ✅ Used in `main.yml` for tests
- ✅ Safe to use (no real Firebase connection)
- ✅ Generated via `tools/generate_mock_firebase_configs.dart`

---

## 🛠️ Troubleshooting

### CI/CD Pipeline (main.yml) Failed:

**Check:**
1. Test failures → Review test logs
2. Analyzer warnings → Run `flutter analyze` locally
3. Formatting → Run `dart format .`
4. Security check → Review for committed secrets

### Build Verification Failed:

**Check:**
1. Gradle cache issues → First build after cache clear is slower
2. Firebase secrets → Verify GitHub Secrets are set
3. Platform-specific errors → Check build logs for details

---

## 📚 Related Documentation

- [IMPLEMENTATION.md](./IMPLEMENTATION.md) - Technical details of optimizations
- [USAGE_GUIDE.md](./USAGE_GUIDE.md) - Developer workflow guide
- [Security Checklist](../../security/PRE_COMMIT_SECURITY_CHECKLIST.md)

---

## 🔄 Future Improvements

**Potential enhancements:**

1. **Auto-trigger builds on labels**
   ```yaml
   on:
     pull_request:
       types: [labeled]
   # Trigger when 'needs-build' label is added
   ```

2. **Deploy on build success**
   ```yaml
   # Add deployment job after build_success
   ```

3. **Platform-specific workflows**
   ```yaml
   # Separate workflows for Android/iOS/Web
   ```

---

**Last Updated:** November 2025
**Maintained By:** Engineering Team
