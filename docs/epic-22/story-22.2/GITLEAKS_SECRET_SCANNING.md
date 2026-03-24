# Story 22.2: Gitleaks Secret Scanning

Gitleaks replaces the previous manual `find`-based secret check in the
`security_audit` CI job. It scans the full git history and working tree
against 150+ built-in secret patterns.

## What changed

### `.github/workflows/main.yml` — `security_audit` job

- Added `fetch-depth: 0` to the checkout step so Gitleaks can scan
  the complete git history, not just the latest commit.
- Added `gitleaks/gitleaks-action` step (pinned SHA) that replaces the
  previous manual `find` checks for two specific filenames.
- Action is pinned to commit SHA per Story 22.1 standards.

### `.gitleaks.toml` — allowlist configuration

Added a project-level Gitleaks configuration with allowlisted paths for
files that intentionally contain fake API key patterns for testing:

| Allowlisted path | Reason |
|-----------------|--------|
| `test/ci_only/firebase_config_validator_test.dart` | Contains `AIzaSyRealApiKeyWithoutPlaceholder123456` — intentionally fake key used to test the Firebase config validator logic |
| `tools/generate_mock_firebase_configs.dart` | Contains placeholder key strings — generates fake configs for CI, never real credentials |

## Why Gitleaks is better than the old check

| | Old check | Gitleaks |
|--|-----------|----------|
| Patterns covered | 2 specific filenames | 150+ secret types |
| Covers API keys in `.dart` or `.ts` files | ❌ | ✅ |
| Covers `.env` files | ❌ | ✅ |
| Scans git history | ❌ | ✅ |
| Covers private keys / JWTs | ❌ | ✅ |
| Zero configuration required | ✅ | ✅ |

## Gitleaks action version

```
gitleaks/gitleaks-action@ff98106e4c7b2bc287b24eaf42907196329070c7  # v2.3.9
```

## Upgrading Gitleaks in future

```bash
# Find the SHA for the new version
gh api repos/gitleaks/gitleaks-action/git/ref/tags/v2.4.0 --jq '.object.sha'

# Update in main.yml security_audit step
# uses: gitleaks/gitleaks-action@<new-sha>  # v2.4.0
```

## Adding new allowlist entries

If a future test file or tool script needs to contain fake credential
patterns, add an entry to `.gitleaks.toml`:

```toml
[[allowlists]]
description = "Brief explanation of why this path is safe"
paths = [
  '''path/to/file\.dart''',
]
```
