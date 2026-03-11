# Story 20.4 — Version & Build Number Automation

## Strategy

App versions are derived entirely from Git tags. No manual version bumping in
`pubspec.yaml` is needed — the CI pipeline injects the correct values at build time
via `flutter build --build-name` and `--build-number`.

---

## Tagging Convention

| Tag | `VERSION_NAME` | Use |
|-----|----------------|-----|
| `v1.0.0-beta` | `1.0.0-beta` | Beta release → TestFlight + Play Internal Track |
| `v1.0.0-beta2` | `1.0.0-beta2` | Second beta iteration if issues found |
| `v1.0.0` | `1.0.0` | Production release → App Store + Google Play |
| `v1.2.3` | `1.2.3` | Patch release |

**Format:** `v{major}.{minor}.{patch}` or `v{major}.{minor}.{patch}-beta{N}`

---

## Version Name (`VERSION_NAME`)

Extracted from the Git tag by stripping the leading `v`:

```
refs/tags/v1.0.0-beta  →  1.0.0-beta
refs/tags/v1.0.0       →  1.0.0
```

Maps to:
- Android: `versionName` in `build.gradle.kts`
- iOS: `CFBundleShortVersionString` in `Info.plist` (via `$(FLUTTER_BUILD_NAME)`)

---

## Build Number (`BUILD_NUMBER`)

Set to the **GitHub Actions run number** — a monotonically incrementing integer
tied to the repository. It increases with every workflow run, regardless of branch or tag.

Maps to:
- Android: `versionCode` in `build.gradle.kts`
- iOS: `CFBundleVersion` in `Info.plist` (via `$(FLUTTER_BUILD_NUMBER)`)

**Why run number instead of tag patch number?**
Both the App Store and Google Play require the build number to be strictly greater
than the previous upload. Using the run number guarantees this without any manual
tracking — even if you re-tag or upload a beta and production build from the same tag.

---

## Reusable Composite Action

File: `.github/actions/extract-version/action.yml`

Used in both CD pipelines to avoid duplicating the extraction logic:

```yaml
- name: Extract version from tag
  uses: ./.github/actions/extract-version

# After this step, both $VERSION_NAME and $BUILD_NUMBER are available
# as environment variables in all subsequent steps of the job.
```

### Outputs

| Output | Description | Example |
|--------|-------------|---------|
| `version_name` | Tag without leading `v` | `1.0.0-beta` |
| `build_number` | GitHub Actions run number | `142` |

---

## Flutter Build Commands

Both CD pipelines pass version values to Flutter at build time:

```bash
# Android
flutter build appbundle --release --flavor prod \
  -t lib/main_prod.dart \
  --build-name=$VERSION_NAME \
  --build-number=$BUILD_NUMBER

# iOS
flutter build ipa --release --flavor prod \
  -t lib/main_prod.dart \
  --build-name=$VERSION_NAME \
  --build-number=$BUILD_NUMBER \
  --export-options-plist=ios/ExportOptions.plist
```

The `--build-name` and `--build-number` flags override whatever is in `pubspec.yaml`
at build time — no file modification required.

---

## How to Release a New Version

```bash
# Beta release
git tag v1.0.0-beta
git push origin v1.0.0-beta
# → triggers cd-beta.yml → TestFlight + Play Internal Track

# If beta has issues, fix on main and tag again
git tag v1.0.0-beta2
git push origin v1.0.0-beta2

# Production release (after beta is validated)
git tag v1.0.0
git push origin v1.0.0
# → triggers cd-production.yml → App Store + Google Play Production
```

---

## pubspec.yaml

`pubspec.yaml` keeps a placeholder version used only for local development:

```yaml
version: 1.0.0+1
```

This value is **never used in CI builds** — it is always overridden by
`--build-name` and `--build-number` at build time.
