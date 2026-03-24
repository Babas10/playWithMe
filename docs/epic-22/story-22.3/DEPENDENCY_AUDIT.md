# Story 22.3: Dependency Audit Gates

## Overview

This story adds automated vulnerability scanning for both npm (Cloud Functions) and Dart (Flutter) dependencies. The CI pipeline now fails on high or critical CVEs before code can be merged.

---

## What Changed

### npm Audit Gate (`cloud_functions_tests` job)

Added a hard gate after the Cloud Functions test step:

```yaml
- name: 🔒 Audit npm Production Dependencies
  working-directory: functions
  run: npm audit --audit-level=high --omit=dev
```

**Flags explained:**
- `--audit-level=high` — exits non-zero only for high or critical severity CVEs
- `--omit=dev` — scopes the audit to production dependencies only (excludes ESLint, Jest, TypeScript, etc.)

**Why `--omit=dev`?** Dev dependencies (ESLint, ts-jest, etc.) are only used during development and build time — they are never deployed to production Cloud Functions. Scoping to `--omit=dev` avoids false positives from tooling vulnerabilities that don't affect the running service.

---

### Dart Audit Gate (`security_audit` job)

Added OSV Scanner for Dart/Flutter dependency auditing:

```yaml
- name: 🔒 Audit Dart Dependencies (OSV Scanner)
  uses: google/osv-scanner-action/osv-scanner-action@e69cc6c86b31f1e7e23935bbe7031b50e51082de  # v2.0.2
  with:
    scan-args: |-
      --lockfile=pubspec.lock
      --format=table
```

**Why OSV Scanner instead of `dart pub audit`?**

`dart pub audit` does not exist in Dart 3.x. Google's [OSV Scanner](https://github.com/google/osv-scanner) is the official open-source alternative. It:
- Scans `pubspec.lock` against the [OSV vulnerability database](https://osv.dev/) (same DB used by GitHub Advisories)
- Natively supports Dart/pub packages
- Fails the job if any CVEs are found in the dependency tree

---

## Pre-existing Vulnerabilities Fixed

Before adding the audit gates, existing CVEs in `functions/` were resolved:

### Fixed (via `npm audit fix`)
| Package | Severity | CVE | Fix |
|---------|----------|-----|-----|
| `fast-xml-parser` | CRITICAL | Entity encoding bypass, DoS | Upgraded via `npm audit fix` |
| `jws` (via `jsonwebtoken`) | HIGH | HMAC signature verification bypass | Upgraded via `npm audit fix` |
| `node-forge` | HIGH | ASN.1 unbounded recursion | Upgraded via `npm audit fix` |

### Fixed (manual upgrade)
| Package | Severity | CVE | Fix |
|---------|----------|-----|-----|
| `minimatch` (via `@typescript-eslint` 6.x) | HIGH | ReDoS via wildcard patterns | Upgraded `@typescript-eslint/eslint-plugin` and `@typescript-eslint/parser` from `^6` to `^8` |

### Accepted Risk (cannot fix without breaking change)
| Package | Severity | Advisory | Reason Not Fixed |
|---------|----------|----------|-----------------|
| `@tootallnate/once` (via `firebase-admin`) | Low | GHSA-vpq2-c234-7xj6 | Fix requires downgrading `firebase-admin` from v12 to v10, a major breaking change. This is a low-severity issue (incorrect control flow scoping — not a data leak or RCE). Will be resolved when `firebase-admin` releases a patched v12.x. |

The accepted risk is documented here and does **not** trigger `--audit-level=high` because it is classified as low severity by npm.

---

## How to Respond to Future Audit Failures

If the CI pipeline fails with an audit error:

### npm audit failure

```bash
cd functions

# See the full vulnerability report
npm audit --audit-level=high --omit=dev

# Try to auto-fix
npm audit fix

# Check what remains (manual upgrade may be needed)
npm audit
```

### OSV Scanner failure

1. Open the CI logs to see which package and CVE is flagged.
2. Check https://osv.dev/ for the advisory details.
3. Update the affected package in `pubspec.yaml` and run `flutter pub upgrade`.
4. Re-run `flutter pub get` to regenerate `pubspec.lock`.
5. If no fix is available yet, add the OSV ID to an exception file (see OSV Scanner docs for `--ignore` flags).

---

## Upgrade Instructions for `@typescript-eslint`

If you encounter ESLint config issues after the v6 → v8 upgrade:

```bash
cd functions
# Check current versions
npm list @typescript-eslint/eslint-plugin @typescript-eslint/parser
```

The v8 release of `@typescript-eslint` dropped some deprecated configuration options. If ESLint fails, check `.eslintrc.js` for any deprecated rules and remove them.
