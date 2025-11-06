# CI/CD Pipeline - Developer Usage Guide

This guide explains how the optimized CI/CD pipeline works and how developers should interact with it.

---

## 🎯 Quick Start

### For Pull Requests (PRs):

1. **Create your feature branch**
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes and commit**
   ```bash
   git add .
   git commit -m "feat: implement my feature"
   ```

3. **Push to GitHub**
   ```bash
   git push origin feature/my-feature
   ```

4. **Create PR**
   - Fast check runs automatically (~2-3 minutes)
   - Get quick feedback on code quality and tests
   - Only builds `dev` flavor for speed

---

## 🔄 Workflow Types

### 1. PR Fast Check (`.github/workflows/pr-fast-check.yml`)

**Trigger:** When you create or update a pull request

**What it does:**
- ✅ Static analysis (`flutter analyze`)
- ✅ Code formatting check
- ✅ Unit tests
- ✅ Widget tests
- ✅ Build verification (dev web only)

**Duration:** ~2-3 minutes ⚡

**Purpose:** Fast feedback on code quality without waiting for full builds

---

### 2. Full Build Matrix (`.github/workflows/main.yml`)

**Trigger:**
- Push to `main` or `develop` branches
- Also runs on PRs (but with reduced matrix)

**What it does:**
- ✅ All checks from Fast Check
- ✅ Build all platforms (Android, Web)
- ✅ Build all flavors (dev, stg, prod) - *only on merge*
- ✅ Security audit
- ✅ Integration tests

**Duration:**
- PRs: ~8-10 minutes (only dev flavor)
- Main/Develop: ~8-10 minutes (all flavors, with caching)

**Purpose:** Comprehensive verification before deployment

---

## 📊 Understanding Build Matrix

### For Pull Requests:
```yaml
Platforms: [android, web]
Flavors: [dev]  # Only dev flavor
Total builds: 2
```

### For Main/Develop Branch:
```yaml
Platforms: [android, web]
Flavors: [dev, stg, prod]  # All flavors
Total builds: 6
```

---

## 🛠️ Local Development

Before pushing, you can run the same checks locally:

### Run Fast Check Locally:
```bash
# 1. Analyze code
flutter analyze

# 2. Check formatting
dart format --set-exit-if-changed .

# 3. Run tests
flutter test test/unit/ test/widget/

# 4. Verify compilation
flutter build web -t lib/main_dev.dart --release
```

**Expected time:** ~2-3 minutes locally

---

## 💾 Caching Strategy

The pipeline uses several caching layers to speed up builds:

### 1. **Flutter SDK Cache**
- Managed by `subosito/flutter-action@v2`
- Caches Flutter SDK between runs
- Automatic - no action needed

### 2. **Gradle Cache (Android)**
- Caches Gradle dependencies and build artifacts
- First build: ~8-10 min
- Cached builds: ~3-5 min (50% faster!)

### 3. **Firebase Config Artifacts**
- Generated once per pipeline run
- Shared between jobs
- Saves ~3 minutes total

---

## ⚡ Performance Tips

### For Faster CI/CD:

1. **Keep PRs Small**
   - Smaller changes = faster reviews
   - Less code to analyze and test

2. **Run Tests Locally First**
   - Catch issues before pushing
   - Save CI/CD minutes

3. **Use Conventional Commits**
   - Helps with changelog generation
   - Clear commit history

4. **Fix Linting Issues Locally**
   ```bash
   dart format .
   flutter analyze
   ```

---

## 🐛 Troubleshooting

### Fast Check Failed?

**Check the error:**
1. Go to GitHub Actions tab
2. Click on the failed "PR Fast Check" run
3. Expand the failed step

**Common issues:**

#### ❌ Static Analysis Failed
```bash
# Run locally to see errors:
flutter analyze

# Fix and commit:
git add .
git commit -m "fix: resolve analyzer warnings"
git push
```

#### ❌ Tests Failed
```bash
# Run tests locally:
flutter test test/unit/ test/widget/

# Fix failing tests and commit
```

#### ❌ Build Failed
```bash
# Try building locally:
flutter build web -t lib/main_dev.dart --release

# Check for compilation errors
```

---

### Full Build Failed?

**Same troubleshooting steps, plus:**

#### ❌ Android Build Failed
```bash
# Clean build cache:
cd android
./gradlew clean

# Try building:
flutter build apk --flavor dev -t lib/main_dev.dart --release
```

#### ❌ Gradle Cache Issues
- GitHub will automatically invalidate cache if corrupted
- First build after invalidation will be slower
- Subsequent builds will be fast again

---

## 📈 Monitoring Pipeline Performance

### Check Build Times:

1. Go to **GitHub Actions** tab
2. Click on a workflow run
3. View total duration at top
4. Expand jobs to see individual timings

### Expected Times:

| Workflow | Expected Duration | Status |
|----------|------------------|--------|
| PR Fast Check | 2-3 minutes | ✅ Normal |
| PR Full Build (dev) | 8-10 minutes | ✅ Normal |
| Main Build (all flavors) | 8-10 minutes | ✅ Normal |

### If Times Increase:

- Check for Gradle cache misses
- Look for new dependencies added
- Review recent changes to workflow files

---

## 🔐 Security Considerations

### Firebase Configs:
- ⚠️ **Never commit** Firebase config files
- Generated from GitHub Secrets in CI
- Shared via artifacts (1-day retention)
- See: `docs/security/FIREBASE_CONFIG_SECURITY.md`

### Secrets:
- All secrets managed in GitHub Settings
- Never print secrets in logs
- Rotate if exposed

---

## 📚 Additional Resources

### Related Documentation:
- [Pre-Commit Security Checklist](../../security/PRE_COMMIT_SECURITY_CHECKLIST.md)
- [Testing Guide](../../testing/LOCAL_TESTING_GUIDE.md)
- [CLAUDE.md](../../../CLAUDE.md) - Project standards

### External Links:
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [Gradle Build Cache](https://docs.gradle.org/current/userguide/build_cache.html)

---

## 🤝 Getting Help

**Pipeline Issues:**
1. Check this guide first
2. Review error logs in GitHub Actions
3. Ask in team chat
4. Create issue if needed

**Questions?**
- Review `docs/epic-0/cicd-optimization/IMPLEMENTATION.md`
- Check recent PRs for examples
- Consult with team lead

---

**Last Updated:** November 2025
**Maintained By:** Engineering Team
