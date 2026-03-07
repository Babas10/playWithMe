# GitHub Repository Rename Decision

**Story:** 18.11 — Documentation: Update README, CLAUDE.md & docs/ Folder
**Date:** 2026-03-06
**Decision:** Deferred

---

## Context

The GitHub repository is currently named `playWithMe` (`https://github.com/Babas10/playWithMe`).
As part of Epic 18 (App Rename: PlayWithMe → Gatherli), the question of renaming the repository was raised.

---

## Options Considered

| Option | Impact | Verdict |
|--------|--------|---------|
| Rename repo to `gatherli` now | Immediate brand alignment | Deferred |
| Rename repo to `gatherli` at public launch | Clean break at right time | Recommended |
| Keep `playWithMe` permanently | No disruption, legacy name forever | Not recommended |

---

## Decision: Deferred to Public Launch

The repository rename is **deferred** for the following reasons:

1. **Redirects are transparent but one-way.** GitHub automatically redirects old clone URLs and issue links to the new repo name. However, this redirect will stop working if the old name is taken by another user/org.
2. **CI/CD pipeline references** — Any hardcoded `Babas10/playWithMe` references in GitHub Actions workflows, badges, or secrets would need to be updated simultaneously.
3. **Minimal user impact now.** The repository is private/small-team; the rename is most valuable when the project is preparing for public visibility.
4. **Code changes are complete.** All in-app branding, Firebase project IDs, bundle IDs, deep link URLs, and documentation have been updated to Gatherli. The repo name is the only remaining legacy reference.

---

## When to Rename

Rename the GitHub repository when:
- [ ] The app is preparing for public/store launch, OR
- [ ] A new contributor needs onboarding and the old name causes confusion

---

## How to Rename (When Ready)

1. Go to **GitHub → Repository Settings → General → Repository name**
2. Change `playWithMe` → `gatherli`
3. Click **Rename**
4. Update any hardcoded references in CI/CD workflows:
   - `.github/workflows/*.yml` files that reference `Babas10/playWithMe`
   - README badges
   - Any external integrations
5. Update local remotes for all contributors:
   ```bash
   git remote set-url origin https://github.com/Babas10/gatherli.git
   ```

---

## References Retained as-is (Intentionally)

The following references in code/docs intentionally retain `playWithMe` because they point to the **current real GitHub URL** and will be updated only after the rename:

- `CLAUDE.md` section 6 example: `git remote add origin https://github.com/Babas10/playWithMe.git`
- GitHub issue links in architecture docs (e.g., `github.com/Babas10/playWithMe/issues/417`) — these will redirect automatically after rename
