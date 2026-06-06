---
description: Run lint, build, test (then deploy if configured) in one go. Stop at first failure.
---

Run the ship pipeline using the commands in CLAUDE.md's Commands table. Stop and report at the first failure.

1. lint
2. build
3. test
4. deploy (only if a deploy command is configured and all above are green)

Report each step's result. Never deploy on a failed step.
