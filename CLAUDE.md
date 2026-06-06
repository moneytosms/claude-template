# <PROJECT_NAME>

> **Goal:** <one-line: what this does + for whom>
> **Domain:** <web / CLI / desktop / mobile / library / ...>
> **Platform:** <target platform(s) shipped to; dev-machine specifics live in CLAUDE.local.md>

<!-- Keep under 200 lines. Claude ignores content past ~200. -->
<!-- Committed shared brain. Machine-specific notes go in CLAUDE.local.md. -->
<!-- This file is a TEMPLATE. The /project-onboarding skill fills the <placeholders>. -->

## Rules
Rules Claude MUST follow every session.

### Git
- Never `git push` without explicit ask.
- Branch before committing on default branch. Prefix branches `sms/`.
- Conventional Commits. Subject ≤50 chars. See [git rules](.claude/rules/git.md).
- Tests + lint green before commit.

### Code
- Production-ready, no stub/placeholder code unless asked.
- Match surrounding style. No new deps without reason.
- Comments explain *why*, not *what*.

## Tech stack
<filled at onboarding — language, framework, runtime, key libs>

## Commands
| Action | Command |
|--------|---------|
| dev    | `<TBD>` |
| build  | `<TBD>` |
| test   | `<TBD>` |
| lint   | `<TBD>` |

## Architecture
<filled at onboarding — subsystems, data flow>

## Key files
<filled at onboarding — entry points, config, core modules>

## Tooling available

### context7 (MCP)
Live, version-correct docs for any library/framework/API. **Use it before answering
library questions or writing integration code** — training data may be stale. Configured
in `.mcp.json`; no key needed.

### rtk (Rust Token Killer)
Cuts command-output tokens 60-90%. `rtk init -g` installs a PreToolUse Bash hook that auto-rewrites
Bash commands (`git status`→`rtk git status`, etc.) — no action needed for Bash. The hook does NOT
cover Read/Grep/Glob, so for those use shell (`cat`/`rg`) or explicit `rtk read`/`rtk grep`. For
logs/tests/errors prefer `rtk log <f>`, `rtk test <cmd>`, `rtk err <cmd>`; if clean, trust it and move
on, re-run without rtk only when full output is needed. Native Windows: no auto-rewrite (call rtk
explicitly); WSL gives full support.

### graphify (skill)
Turn any input (code, docs, papers, images) into a clustered knowledge graph
(HTML + JSON + audit). Trigger: `/graphify`. Use for: mapping an unfamiliar codebase,
synthesizing research, visualizing relationships.

### caveman (mode)
Terse output mode (active `full` via session-start hook). Toggle: `/caveman lite|full|ultra`,
disable with "stop caveman". Code/commits/security always written normally.

### Skills & agents
Engineering skills (Matt Pocock + Addy Osmani sets) and subagents installed at setup.
List skills with the Skill tool; agents live in `.claude/agents/`.
Route spawned subagents to the cheapest viable model (haiku for recon/edits, sonnet for reasoning) —
see [agent rules](.claude/rules/agents.md).

## Detailed docs
Loaded on demand to keep this file small:
- [Git rules](.claude/rules/git.md)
- [Subagent model routing](.claude/rules/agents.md)
- [API rules](.claude/rules/api.md)
- [Production / deploy](.claude/rules/production.md)
- [UI conventions](.claude/rules/ui.md)
- [Architecture decisions](docs/adr/)
