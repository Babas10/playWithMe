# Epic 22: DevSecOps Pipeline Hardening

## Goal

Improve the reliability, security, and maintainability of Gatherli's CI/CD pipeline.
Each story addresses a specific gap identified through analysis of the existing
`main.yml`, `cd-beta.yml`, and `cd-production.yml` workflows.

This epic is not about adding new features to the app. It is about making the
delivery infrastructure more trustworthy — so that every release is faster,
more secure, and less likely to fail for accidental or environmental reasons.

---

## Background

The current pipeline was built iteratively as part of Epic 20 (CD pipeline) and
earlier CI work. It works, but it contains a number of patterns that introduce
risk:

- Static credentials stored as long-lived GitHub Secrets
- Service account JSON written to disk during deploy with no guaranteed cleanup
- `flutter analyze` running in warning-only mode even at deploy time
- Action versions pinned to mutable tags (`@v4`) rather than immutable commit SHAs
- Secret scanning limited to two specific filenames, missing everything else
- Dependency vulnerability checks that warn but never block
- The `test` job duplicated across three workflow files
- Mobile builds unnecessarily blocked on Cloud Function deployments
- No verification that a production tag was pushed from `main`

The stories in this epic address each of these gaps in priority order.

---

## Stories

| Story | Title | Category |
|-------|-------|----------|
| 22.1 | Pin all GitHub Action versions to commit SHAs | Security |
| 22.2 | Add Gitleaks secret scanning to CI | Security |
| 22.3 | Make `npm audit` and `dart pub audit` fail the build on high CVEs | Security |
| 22.4 | Guarantee service account JSON cleanup with a shell trap | Security |
| 22.5 | Enable `--fatal-warnings` in all CD pipelines | Reliability |
| 22.6 | Decouple mobile builds from Cloud Function deployment | Reliability |
| 22.7 | Add a post-deploy Cloud Function smoke test | Reliability |
| 22.8 | Enforce that production tags are pushed from `main` | Reliability |
| 22.9 | Extract a reusable test workflow to eliminate duplication | Maintainability |
| 22.10 | Migrate Firebase deployment to Workload Identity Federation | Security |
| 22.11 | Add pipeline caching for CocoaPods, pub packages, and Firebase CLI | Performance |

---

## Story Detail

---

### Story 22.1 — Pin all GitHub Action versions to commit SHAs

**Category:** Security — Supply Chain

**Current state:**
All third-party actions are referenced by mutable version tags:
```yaml
uses: actions/checkout@v4
uses: subosito/flutter-action@v2
uses: r0adkll/upload-google-play@v1
```

**The problem:**
Version tags like `@v4` are just Git tags — any maintainer (or attacker who compromises
a maintainer account) can move the tag to point at a different, malicious commit.
Your workflow would silently start running the new code on the next push, with full
access to all your GitHub Secrets including signing keys, App Store credentials, and
the Firebase service account.

This is the attack vector described in the [tj-actions/changed-files compromise (2025)](https://github.com/tj-actions/changed-files/security/advisories)
and the [reviewdog supply chain attack (2025)](https://github.com/reviewdog/action-setup/issues/15).

**The fix:**
Pin every action to its exact commit SHA. The SHA is immutable — it cannot be moved.
```yaml
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
```

**Benefit:**
- The pipeline is now immune to tag-squatting attacks on third-party actions.
- SHA pinning is the industry standard for any pipeline that handles secrets or
  ships to production (required by SLSA Level 2+).
- The comment preserves human-readability while the SHA enforces immutability.

---

### Story 22.2 — Add Gitleaks secret scanning to CI

**Category:** Security — Secret Detection

**Current state:**
The `security_audit` job in `main.yml` checks for committed secrets by searching
for two specific filenames:
```bash
find . -name "google-services.json"
find . -name "GoogleService-Info.plist"
```

**The problem:**
This covers exactly two cases. It would miss:
- A hardcoded Firebase API key in a Dart file
- An accidentally committed `.env` file
- A private key or JWT pasted into a config file
- An AWS or GCP access key in any file

The check is essentially security theatre — it creates confidence without coverage.

**The fix:**
Replace the manual find with [Gitleaks](https://github.com/gitleaks/gitleaks-action),
an open-source tool that scans the entire git history (not just the working tree)
against a library of 150+ secret patterns:
```yaml
- uses: gitleaks/gitleaks-action@v2
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Benefit:**
- Covers API keys, tokens, private keys, connection strings, and more — not just
  two filenames.
- Scans git history, so it catches secrets that were committed and then deleted
  (they still exist in the history and are still extractable).
- Runs on every PR, blocking merges before secrets reach `main`.
- Zero configuration needed for the default ruleset.

---

### Story 22.3 — Make `npm audit` and `dart pub audit` fail the build on high CVEs

**Category:** Security — Dependency Vulnerabilities

**Current state:**
- The TypeScript functions have no vulnerability check at all in the pipeline.
- The Flutter side runs `flutter pub deps --json` and dumps output, but nothing
  evaluates it.

**The problem:**
Vulnerable dependencies are one of the most common vectors for supply chain attacks
(OWASP A06:2021). Firebase functions run in production with Admin SDK access — a
compromised transitive dependency in `functions/node_modules/` could exfiltrate
Firestore data or impersonate users.

**The fix:**
Add explicit audit steps that exit non-zero on high/critical severity findings:
```bash
# TypeScript functions
npm audit --audit-level=high

# Flutter / Dart
dart pub audit
```
Both commands exist today — the gap is that they are not part of the pipeline,
so failures are never surfaced.

**Benefit:**
- PRs introducing a high-severity dependency are blocked before merge.
- The team is alerted to CVEs in existing dependencies on the next CI run.
- `--audit-level=high` avoids alert fatigue from low-severity findings while still
  catching genuinely dangerous issues.

---

### Story 22.4 — Guarantee service account JSON cleanup with a shell trap

**Category:** Security — Credential Hygiene

**Current state:**
The `deploy_functions` job in `cd-beta.yml` and `cd-production.yml` writes the
Firebase service account JSON to disk and deletes it after:
```bash
echo "$GOOGLE_APPLICATION_CREDENTIALS_JSON" > /tmp/sa.json
export GOOGLE_APPLICATION_CREDENTIALS=/tmp/sa.json
firebase deploy ...
rm /tmp/sa.json
```

**The problem:**
If the `firebase deploy` command fails (as it did in this sprint with the Cloud
Scheduler IAM error), the script exits before reaching `rm /tmp/sa.json`. The
credential file remains on the runner's disk for the duration of the job, and
potentially longer depending on runner reuse behaviour.

While GitHub-hosted runners are ephemeral and wiped after each job, this is a
defence-in-depth concern: the file should never outlive its use regardless of
exit path.

**The fix:**
Use a shell `trap` to guarantee cleanup on any exit — success, failure, or signal:
```bash
trap 'rm -f /tmp/sa.json' EXIT
echo "$GOOGLE_APPLICATION_CREDENTIALS_JSON" > /tmp/sa.json
export GOOGLE_APPLICATION_CREDENTIALS=/tmp/sa.json
firebase deploy ...
```

**Benefit:**
- Credentials are cleaned up on every exit path, not just the happy path.
- Eliminates the class of "credentials left on disk after failed deploy" entirely.
- Low effort, high value — a one-line change per workflow.

---

### Story 22.5 — Enable `--fatal-warnings` in all CD pipelines

**Category:** Reliability — Code Quality Gate

**Current state:**
Both `cd-beta.yml` and `cd-production.yml` run:
```yaml
run: flutter analyze --no-fatal-warnings
```
`main.yml` runs analysis and writes results to a file but exits `|| true`,
meaning analysis failures never fail CI either.

**The problem:**
`flutter analyze` warnings include real bugs: null safety violations, unused
imports, deprecated API usage, and type mismatches. Allowing them in CI means
they silently accumulate. The `main.yml` file even has a `TODO` comment
acknowledging this:
> `# TODO: In future iterations, enable --fatal-warnings when code quality improves`

Shipping to production without a hard analyze gate means the analyzer is providing
information but not enforcement.

**The fix:**
1. Fix all existing warnings (likely a small number given the codebase is well-maintained).
2. Change to `flutter analyze` (no flag) — the default behaviour is fatal on errors,
   warning on infos.
3. Optionally enforce `--fatal-infos` for the strictest gate.

**Benefit:**
- Every PR to `main` must pass static analysis — no regressions.
- Catches entire categories of bugs before they reach users (null deref, missing
  await, deprecated APIs).
- Reinforces the project standard: "zero warnings, zero errors".

---

### Story 22.6 — Decouple mobile builds from Cloud Function deployment

**Category:** Reliability — Pipeline Efficiency

**Current state:**
In `cd-beta.yml`, both `deploy_android` and `deploy_ios` declare:
```yaml
needs: [test, deploy_functions]
```

**The problem:**
Mobile builds have no technical dependency on Cloud Functions being deployed first.
The Android AAB and iOS IPA do not contain any code from `functions/`. If
`deploy_functions` fails for an infrastructure reason (as happened with the Cloud
Scheduler IAM error in this sprint), the mobile builds never start — even though
they would have succeeded.

This caused the entire v0.5.0-beta pipeline to fail, blocking the beta release.

**The fix:**
Remove `deploy_functions` from the `needs` of both mobile build jobs:
```yaml
deploy_android:
  needs: [test]
deploy_ios:
  needs: [test]
```
Functions and mobile builds then run in parallel after tests pass.

**Benefit:**
- Mobile builds are no longer blocked by unrelated infrastructure failures.
- Total pipeline wall-clock time is reduced by ~10 minutes (functions and mobile
  now run concurrently instead of sequentially).
- Failures are isolated — a Cloud Scheduler IAM issue doesn't prevent a TestFlight
  upload.

---

### Story 22.7 — Add a post-deploy Cloud Function smoke test

**Category:** Reliability — Deploy Verification

**Current state:**
After `firebase deploy` completes successfully, the pipeline moves on without
verifying that the deployed functions are actually reachable or behaving correctly.
A successful deploy exit code only means the deployment API accepted the bundle —
it does not mean the function is running.

**The problem:**
Functions can fail to start for reasons that don't surface during deploy:
a runtime error on cold start, a missing environment variable, or a misconfigured
trigger. Without a smoke test, these failures are discovered by users, not the pipeline.

**The fix:**
After deploy, call a lightweight `healthCheck` callable function that returns `{status: "ok"}`:
```bash
curl -sf -X POST \
  "https://us-central1-${PROJECT_ID}.cloudfunctions.net/healthCheck" \
  -H "Content-Type: application/json" \
  -d '{"data": {}}' | grep -q '"ok"' \
  || (echo "Smoke test failed" && exit 1)
```
This requires adding a minimal `healthCheck` function to `functions/src/`.

**Benefit:**
- Pipeline fails fast if functions are deployed but broken at runtime.
- Catches cold-start errors before users do.
- Gives confidence that each deploy is actually serving traffic correctly.

---

### Story 22.8 — Enforce that production tags are pushed from `main`

**Category:** Reliability — Release Safety

**Current state:**
`cd-production.yml` triggers on any tag matching `v[0-9]+.[0-9]+.[0-9]+`,
regardless of which branch the tagged commit is on.

**The problem:**
If a developer accidentally tags a commit on a feature branch and pushes the tag,
the production pipeline fires and ships an incomplete build to the App Store and
Google Play. This is a silent, hard-to-reverse mistake — Play Store production
releases go live immediately, and App Store submissions enter the Apple review queue.

**The fix:**
Add a gate step at the start of the production pipeline that verifies the tagged
commit is an ancestor of `origin/main`:
```bash
git fetch origin main
git merge-base --is-ancestor HEAD origin/main \
  || (echo "ERROR: Tag is not on main branch. Aborting production deploy." && exit 1)
```

**Benefit:**
- Prevents accidental production releases from feature or hotfix branches.
- Makes the "tag on main = production release" contract explicit and enforced.
- Zero additional tooling required — pure git.

---

### Story 22.9 — Extract a reusable test workflow to eliminate duplication

**Category:** Maintainability — DRY Pipeline

**Current state:**
The `test` job (Flutter setup, pub get, mock config generation, analyze, test run)
is copy-pasted identically in three workflow files:
- `main.yml`
- `cd-beta.yml`
- `cd-production.yml`

**The problem:**
Any change to the test command — adding a new test directory, changing the Flutter
version, adding a new pre-test step — must be made in all three files independently.
Forgetting one means the three pipelines diverge silently. This happened previously
when `--no-fatal-warnings` was added to CD but not CI.

**The fix:**
Extract the test logic into a [reusable workflow](https://docs.github.com/en/actions/using-workflows/reusing-workflows):
```yaml
# .github/workflows/reusable-test.yml
on:
  workflow_call:
    inputs:
      flutter-version:
        required: true
        type: string

jobs:
  test:
    runs-on: ubuntu-latest
    steps: [...]
```

Then each pipeline calls it:
```yaml
test:
  uses: ./.github/workflows/reusable-test.yml
  with:
    flutter-version: '3.32.6'
```

**Benefit:**
- Single source of truth for the test job — one change propagates everywhere.
- Prevents silent divergence between CI and CD test configurations.
- Reduces each CD workflow file by ~40 lines.

---

### Story 22.10 — Migrate Firebase deployment to Workload Identity Federation

**Category:** Security — Credential Architecture

**Current state:**
The Firebase service account is stored as a long-lived JSON key in the GitHub
Secret `FIREBASE_SERVICE_ACCOUNT`. It is base64-decoded and written to disk
during every deploy job.

**The problem:**
Long-lived service account keys are a significant security risk:
- They do not expire — a leaked key remains valid until manually revoked.
- They are stored in GitHub Secrets, which are accessible to any workflow in the
  repository — including those triggered by fork PRs if misconfigured.
- Google's own security guidance recommends [avoiding service account keys](https://cloud.google.com/iam/docs/best-practices-for-managing-service-account-keys)
  wherever possible.

**The fix:**
Replace the service account JSON with [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation).
GitHub Actions can obtain a short-lived OIDC token that Google Cloud accepts directly:
```yaml
- uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: 'projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github/providers/github-actions'
    service_account: 'ci-deploy@gatherli-prod.iam.gserviceaccount.com'
```

No JSON key is stored anywhere. The token is valid for the duration of the job only.

**Benefit:**
- Eliminates long-lived credentials entirely — no static key to leak, rotate, or audit.
- The OIDC token is scoped to the specific repository and workflow, preventing
  lateral use if somehow extracted.
- Aligns with Google's recommended best practice and SLSA Level 3 requirements.
- Removes the need for the `/tmp/sa.json` pattern entirely (Story 22.4 becomes
  unnecessary once this is in place, but 22.4 is worth doing first as a quick win
  while 22.10 is set up).

---

---

### Story 22.11 — Add pipeline caching for CocoaPods, pub packages, and Firebase CLI

**Category:** Performance — Pipeline Speed

**Current state:**
Several slow steps re-download or re-install the same dependencies on every single pipeline run:

| Step | Job | Estimated time wasted |
|------|-----|-----------------------|
| CocoaPods install (`pod install`) | `deploy_ios` (macOS runner) | ~4–6 min per run |
| Flutter pub packages (`flutter pub get`) | All jobs with Flutter | ~1–2 min per run |
| Firebase CLI (`npm install -g firebase-tools`) | `deploy_functions` | ~30–60 sec per run |

Currently cached: Flutter SDK (`subosito/flutter-action cache: true`), Gradle (Android), Python pip. Everything else is downloaded from scratch on every run.

**The problem:**
The iOS build runs on a macOS runner, which GitHub bills at 10× the Linux runner rate. Wasting 4–6 minutes on CocoaPods re-installation on every run is both slow and expensive. Across dozens of beta releases, this compounds into hours of unnecessary runner time.

**The fix:**

**CocoaPods** — cache keyed on `ios/Podfile.lock` (only invalidated when a Flutter plugin changes its native iOS dependencies):
```yaml
- uses: actions/cache@<SHA>
  with:
    path: |
      ios/Pods
      ~/.cocoapods
    key: ${{ runner.os }}-pods-${{ hashFiles('ios/Podfile.lock') }}
    restore-keys: ${{ runner.os }}-pods-
```

**Flutter pub packages** — cache keyed on `pubspec.lock`:
```yaml
- uses: actions/cache@<SHA>
  with:
    path: ~/.pub-cache
    key: ${{ runner.os }}-pub-${{ hashFiles('pubspec.lock') }}
    restore-keys: ${{ runner.os }}-pub-
```
Applies to all jobs that call `flutter pub get` (test, deploy_android, deploy_ios).

**Firebase CLI** — move it into `functions/` devDependencies so it is covered by the existing `npm ci` + `node_modules` cache. No separate global install needed.

**Benefit:**
- CocoaPods cache saves ~4–6 minutes and significant macOS runner cost on every iOS build.
- Pub cache saves ~1–2 minutes per Flutter job.
- Firebase CLI from devDependencies eliminates the global install step entirely.
- Total estimated savings: 10–15 minutes per full pipeline run.

---

## Acceptance Criteria (Epic Level)

All 11 stories are implemented, tested, and the pipeline passes end-to-end on a
`v*-beta` tag push without manual intervention.

## Out of Scope

- Changing the deployment strategy (tag-based triggers remain)
- Adding new test types (integration tests in CI — separate epic)
- Migrating away from GitHub Actions
