# Story 22.4: Guarantee Service Account JSON Cleanup with a Shell Trap

## Problem

Service account JSON files written to disk during CI were only cleaned up on the happy path. If a step failed mid-way, the credential file stayed on disk for the rest of the job's lifetime.

Example from the v0.5.0-beta incident: `firebase deploy` failed with a Cloud Scheduler IAM error. The `rm /tmp/sa.json` line that followed never executed. The Firebase service account key remained readable on the runner until the job ended.

While GitHub-hosted runners are ephemeral (the VM is discarded after the job), this is a defence-in-depth gap: credentials should never outlive their use regardless of exit path.

---

## Solution

### 1. Firebase Service Account (`/tmp/sa.json`) — `cd-beta.yml`

Use a shell `trap` that fires on every exit — success, failure, and signals:

```bash
trap 'rm -f /tmp/sa.json' EXIT
echo "$GOOGLE_APPLICATION_CREDENTIALS_JSON" > /tmp/sa.json
export GOOGLE_APPLICATION_CREDENTIALS=/tmp/sa.json
firebase deploy ...
rm -f /tmp/sa.json  # explicit redundant cleanup before EXIT
```

`trap ... EXIT` is guaranteed to run regardless of how the shell exits. The explicit `rm -f` at the end is kept as a redundant defence so the file is removed as early as possible (before `EXIT` fires naturally at shell end).

### 2. Google Play Service Account (`service-account.json`) — both `cd-beta.yml` and `cd-production.yml`

The Google Play SA is written in one step and consumed by a separate `uses:` action step. A shell `trap` cannot span across steps (each `run:` block is an isolated shell process). The equivalent for multi-step cleanup in GitHub Actions is `if: always()`:

```yaml
- name: 🧹 Clean up Google Play service account key
  if: always()
  run: rm -f service-account.json
```

`if: always()` runs the step regardless of whether prior steps succeeded or failed, providing the same guarantee as `trap EXIT` but across step boundaries.

---

## Files Changed

| File | Change |
|------|--------|
| `cd-beta.yml` | Added `trap 'rm -f /tmp/sa.json' EXIT` to Firebase deploy step |
| `cd-beta.yml` | Added `if: always()` cleanup step for `service-account.json` in `deploy_android` |
| `cd-production.yml` | Added `if: always()` cleanup step for `service-account.json` in `deploy_android` |

---

## Why Not Use `trap` for the Google Play SA?

`trap` is a shell built-in. In GitHub Actions, each `run:` block spawns a new shell process. When the block exits, the shell (and its trap) exits. The next `uses:` action step runs in a different context — the trap is gone.

Since the `service-account.json` file must survive between the "Decode" step and the "Upload" action step, the `trap` pattern cannot be used. `if: always()` is the correct multi-step equivalent.

---

## Relationship to Story 22.10

Story 22.10 (Workload Identity Federation) will eliminate the need to write any service account JSON to disk by replacing long-lived SA keys with short-lived OIDC tokens. This story is the interim hardening until that migration is complete.
