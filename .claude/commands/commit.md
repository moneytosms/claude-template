---
description: Stage and commit current changes with a Conventional Commit message.
---

1. `git status` + `git diff` to see what changed.
2. Group into one logical commit (or ask if it should be split).
3. Write a Conventional Commit: `type(scope): subject` (≤50 chars). Body only if the *why* isn't obvious.
4. Stage relevant files and commit. Never `git push`. Never `--no-verify`.
5. Show the resulting `git log -1`.
