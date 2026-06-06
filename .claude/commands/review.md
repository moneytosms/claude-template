---
description: Review the current diff for correctness, readability, security, performance.
---

Review the uncommitted diff (or the diff vs the base branch if clean). Use the `code-reviewer` agent for a focused pass. Output one line per finding: `path:line: <severity>: <problem>. <fix>.` Severities: blocker, major, minor. No praise, no scope creep. End with a go/no-go.
