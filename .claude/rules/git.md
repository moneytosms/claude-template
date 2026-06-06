# Git rules

## Commits
- Conventional Commits: `type(scope): subject`. Subject ≤50 chars, imperative.
- Types: feat, fix, docs, refactor, test, chore, perf, build, ci.
- Body only when the *why* isn't obvious from the subject.

## Branches
- Prefix personal branches `sms/`.
- Branch before committing on the default branch.

## Safety
- Never `git push` or force-push without explicit ask.
- Run lint + tests before committing (no enforcing hook — discipline + `/ship`).
