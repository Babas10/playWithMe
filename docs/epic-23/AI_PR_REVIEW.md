# Epic 23: AI-Assisted PR Review

## Goal

Add automated AI code review to every pull request — catching quality, security,
and architecture issues before a human reviewer sees the PR. Two complementary
layers: an off-the-shelf general reviewer (CodeRabbit) and a custom Claude-based
reviewer that knows Gatherli's specific architecture rules.

---

## Background

Code review is the primary quality gate before code reaches `main`. Human review
is valuable but has blind spots: reviewers get fatigued, context-switch frequently,
and cannot consistently check every rule on every PR. AI reviewers don't get tired,
are available immediately, and can be given the project's exact standards.

The two stories in this epic complement each other:

- **CodeRabbit** covers general code quality — bugs, security patterns, test
  coverage, style consistency, performance anti-patterns. It understands Flutter,
  Dart, TypeScript, and most common frameworks.

- **A custom Claude reviewer** covers rules that are unique to Gatherli and that no
  generic tool would know: the layered architecture dependency rules, the 5-language
  localization requirement, the mocktail-not-mockito testing policy, the Cloud
  Function security checklist. These rules live in `CLAUDE.md` and are the ones
  most likely to cause subtle long-term problems when violated.

---

## Stories

| Story | Title | Category |
|-------|-------|----------|
| 23.1 | Add CodeRabbit automated code review | General quality |
| 23.2 | Build custom Claude architecture rule reviewer | Project-specific rules |

---

## Story Detail

---

### Story 23.1 — Add CodeRabbit automated code review

**Category:** General quality — Off-the-shelf AI review

**What is CodeRabbit?**
CodeRabbit is a GitHub App that acts as an AI code reviewer on every PR. It posts
inline comments, a PR summary, and a walkthrough of changes. It understands
Flutter/Dart, TypeScript, Python, and most common frameworks and patterns.

**What it reviews:**
- Logic bugs and null safety issues in Dart
- Security patterns (missing auth checks, hardcoded values)
- TypeScript type safety in Cloud Functions
- Test coverage gaps — flags new code paths with no corresponding test
- Code style consistency with the rest of the file
- Performance anti-patterns (unnecessary rebuilds, missing `const`, etc.)
- Documentation completeness

**Why not just rely on `flutter analyze`?**
`flutter analyze` catches type errors and lint warnings. CodeRabbit understands
*intent* — it can flag a function that looks logically wrong even if it compiles
cleanly, suggest a simpler approach, or notice that a new Cloud Function is missing
the authentication check pattern used everywhere else.

**Setup:**
1. Install the CodeRabbit GitHub App on the Babas10/playWithMe repository
2. Add a `.coderabbit.yml` config file to the repository root:
   ```yaml
   language: en-US
   reviews:
     profile: chill          # informative, not blocking
     request_changes_workflow: false
     high_level_summary: true
     poem: false
     review_status: true
     collapse_walkthrough: false
   ```
3. Configure path-based instructions to give CodeRabbit context:
   ```yaml
   path_instructions:
     - path: "lib/features/games/**"
       instructions: "Games layer must never import from lib/features/friends/ or lib/core/domain/repositories/friend_repository.dart"
     - path: "functions/src/**"
       instructions: "All callable functions must validate context.auth before any Firestore operation"
     - path: "lib/l10n/**"
       instructions: "All 5 ARB files (en, fr, de, es, it) must be updated together"
   ```

**Cost:** Free for public repositories. For private repositories, the free tier
covers a generous number of reviews per month — check coderabbit.ai for current
pricing.

**Benefit:**
- Every PR gets a structured review within minutes of opening, before human
  reviewers look at it.
- Catches an entire class of common bugs (null deref, missing await, unused
  variable that should have been used) consistently.
- Frees human reviewers to focus on design and architecture decisions rather than
  routine quality checks.

**Acceptance Criteria:**
- [ ] CodeRabbit GitHub App installed on the repository
- [ ] `.coderabbit.yml` committed to `main` with path-specific instructions
- [ ] CodeRabbit posts a review summary on the next opened PR
- [ ] Path instructions correctly warn about the games/friends import rule

---

### Story 23.2 — Build custom Claude architecture rule reviewer

**Category:** Project-specific rules — Custom reviewer

**Why a custom reviewer?**
CodeRabbit is excellent for general patterns but cannot know Gatherli's specific
rules without extensive configuration. The rules that matter most for long-term
health are in `CLAUDE.md`:

- **Layered dependencies**: Games must never import from the friends/social layer
- **Localization**: Every user-facing string must be in all 5 ARB files
- **Testing stack**: `mocktail` only, never `mockito`; `fake_cloud_firestore` never
  used for Timestamp queries
- **Cloud Function security**: Every callable function must validate `context.auth`
  as the first operation
- **Exception handling**: Repositories must throw typed custom exceptions, not
  generic `Exception`

These are subtle rules that a generic AI reviewer won't flag by default.

**Architecture:**
A GitHub Actions workflow that triggers on every PR, reads the diff, constructs a
prompt with `CLAUDE.md` as system context, calls the Claude API, and posts the
result as a PR comment.

```yaml
# .github/workflows/claude-review.yml
name: Claude Architecture Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA>
        with:
          fetch-depth: 0

      - name: Get PR diff
        id: diff
        run: |
          git diff origin/${{ github.base_ref }}...HEAD > pr.diff

      - name: Run Claude architecture review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          python3 scripts/claude_review.py \
            --diff pr.diff \
            --rules CLAUDE.md \
            --output review.md

      - name: Post review comment
        uses: actions/github-script@<SHA>
        with:
          script: |
            const fs = require('fs');
            const review = fs.readFileSync('review.md', 'utf8');
            if (review.trim()) {
              github.rest.issues.createComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                issue_number: context.issue.number,
                body: review
              });
            }
```

**The review script** (`scripts/claude_review.py`) sends:
1. `CLAUDE.md` as system context
2. The PR diff as user input
3. A focused prompt asking Claude to check *only* the project-specific rules, not
   general code quality (CodeRabbit handles that)

The script outputs nothing if no violations are found, keeping the PR feed clean.
It only comments when it detects a genuine rule violation.

**Benefit:**
- Automatically enforces architecture rules that currently rely on human memory.
- The layered dependency rule (games must not import friends) is the most critical —
  a violation here creates a subtle coupling that is expensive to unwind later.
- The localization check catches missing ARB entries before QA, not after.
- Scales: as the team grows, the rules are enforced consistently for every
  contributor.

**Acceptance Criteria:**
- [ ] `scripts/claude_review.py` exists and calls the Anthropic API with CLAUDE.md as context
- [ ] `.github/workflows/claude-review.yml` triggers on every PR
- [ ] `ANTHROPIC_API_KEY` added to GitHub Secrets
- [ ] The reviewer detects a test violation of the games→friends import rule
- [ ] The reviewer detects a missing ARB entry (tested with a synthetic PR)
- [ ] The reviewer posts no comment when the PR has no violations
- [ ] Cost is bounded — diff is truncated to avoid excessive token usage on large PRs
