---
description: Health-check the project's Claude tooling — CLIs, MCP, skills, agents, hooks. Reports a ✓/✗ table.
---

Verify everything is wired and working. Run checks, report one line each (✓/✗ + how to fix), then a summary.

## CLIs (via Bash)
- `git --version`, `node --version`, `gh --version`, `rg --version`, `fd --version` (or `fdfind`),
  `jq --version`, `bat --version` (or `batcat`), `just --version`, `uv --version`, `rtk --version`.
- If secret-scan enabled: `gitleaks version` + `git config core.hooksPath` = `.githooks`.
- `rtk gain` works (if it errors → wrong `rtk` crate; reinstall via cargo --git or release binary).

## MCP
- context7 reachable: do a tiny `resolve-library-id` / `query-docs` call (e.g. resolve "react"). ✓ if it returns.
- Any other server in `.mcp.json` responds.

## Skills
- `graphify` loads (Skill tool lists it).
- Matt Pocock + Addy Osmani skills present (Skill list shows them).

## Modes / plugins
- caveman active (session-start hook output shows it) — `/caveman` recognized.
- cavecrew available for delegated subagents.

## Agents + hooks
- `.claude/agents/*` present with correct `model:` (haiku for researcher/log-analyzer, sonnet for the rest).
- Hooks fire: session-start (git+caveman), post-edit-format, pre-deploy-guard, notify; status line shows.

## Report
Table of ✓/✗ with the exact remediation command for each ✗. End with "all green" or the fix list.
