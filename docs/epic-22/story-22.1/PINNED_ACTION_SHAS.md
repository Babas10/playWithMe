# Story 22.1: Pinned GitHub Action SHAs

All third-party GitHub Actions across every workflow file are now pinned to an
immutable commit SHA instead of a mutable version tag.

## Why

Version tags (`@v4`, `@v2`) are Git pointers that can be silently moved to any
commit by the action's maintainer — or by an attacker who compromises a maintainer
account. If a tag is moved to a malicious commit, the next pipeline run would
silently execute that malicious code with full access to all GitHub Secrets
(signing keys, App Store credentials, Firebase service account).

This attack vector was exploited in the wild in 2025 (tj-actions/changed-files,
reviewdog). Pinning to a SHA makes this impossible — a SHA is immutable and
permanently tied to a specific commit.

## Pinned versions

| Action | SHA | Version |
|--------|-----|---------|
| `actions/checkout` | `11bd71901bbe5b1630ceea73d27597364c9af683` | v4.2.2 |
| `actions/cache` | `d4323d4df104b026a6aa633fdb11d772146be0bf` | v4.2.2 |
| `actions/setup-node` | `1d0ff469b7ec7b3cb9d8673fde0c81c44821de2a` | v4.2.0 |
| `actions/setup-java` | `3a4f6e1af504cf6a31855fa899c6aa5355ba6c12` | v4.7.0 |
| `actions/setup-python` | `42375524e23c412d93fb67b49958b491fce71c38` | v5.4.0 |
| `actions/upload-artifact` | `ea165f8d65b6e75b540449e92b4886f43607fa02` | v4.6.2 |
| `actions/download-artifact` | `95815c38cf2ff2164869cbab79da8d1f422bc89e` | v4.2.1 |
| `actions/github-script` | `60a0d83039c74a4aee543508d2ffcb1c3799cdea` | v7.0.1 |
| `subosito/flutter-action` | `f2c4f6686ca8e8d6e6d0f28410eeef506ed66aff` | v2.18.0 |
| `codecov/codecov-action` | `ab904c41d6ece82784817410c45d8b8c02684457` | v3.1.6 |
| `r0adkll/upload-google-play` | `935ef9c68bb393a8e6116b1575626a7f5be3a7fb` | v1.1.3 |

## Files updated

- `.github/workflows/main.yml`
- `.github/workflows/cd-beta.yml`
- `.github/workflows/cd-production.yml`
- `.github/workflows/build-verification.yml`
- `.github/workflows/validate-version-tag.yml`
- `.github/workflows/integration-tests.yml`

Total: 51 action references pinned across 6 workflow files.

## How to upgrade an action in the future

When you want to upgrade to a new version of an action:

```bash
# 1. Look up the SHA for the new version tag
gh api repos/actions/checkout/git/ref/tags/v4.3.0 --jq '.object.sha'

# If the result type is "tag" (annotated tag), dereference it:
gh api repos/actions/checkout/git/tags/<sha-from-above> --jq '.object.sha'

# 2. Update the SHA and version comment in the relevant workflow file(s)
# uses: actions/checkout@<new-sha>  # v4.3.0

# 3. Open a PR — the upgrade is now reviewed and intentional
```

The version comment on each line (`# v4.2.2`) makes it easy to see which version
is running at a glance, while the SHA ensures it cannot be changed without a
deliberate code change.
