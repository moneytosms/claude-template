# claude-template

A generic, stack-agnostic Claude Code base you clone once per project. Run one script and it
auto-installs your tooling, then Claude interviews you and customizes everything — so you never wire
up Claude Code from scratch again. After setup, all the template/scaffolding files delete themselves
and you're left with a clean, fully-configured project.

---

## Quick start

```sh
git clone <this-repo> my-project
cd my-project
pwsh ./setup.ps1          # Windows
sh   ./setup.sh           # macOS / Linux / WSL / git-bash
```

Flags: `--yes`/`-y` (skip confirm, unattended) · `--dry-run` (show what would happen, change nothing).

### What `setup` does (fully automatic)
1. **Installs all CLIs** (idempotent): `git node gh rg fd jq bat uv` + **rtk**, via winget/brew/apt/dnf.
2. Runs **`rtk init -g --auto-patch`** — wires rtk's token-saving hook into Claude Code globally.
3. Prints a **✓/✗ verification table** and a **PATH reload note** if a new shell is needed.
4. Removes the template's git history.
5. Launches Claude → runs **`/project-onboarding`**.

### What `/project-onboarding` does
- **Interviews** you (the only interactive part): name, **platform**, domain, language/stack, commands, license, remote.
- **Auto-installs** default skills: context7 (MCP), graphify, Matt Pocock skills, Addy Osmani agent-skills.
- **Picks stack tooling** (e.g. ruff+pyrefly / eslint+prettier / clippy) and wires it into hooks + the Commands table.
- **Fills `CLAUDE.md`** (compact, <200 lines), trims irrelevant rules, writes `.gitignore` + `LICENSE`.
- **Cleans up**: deletes ALL setup-phase files (see below), writes a fresh project README.
- **`git init`** + first commit; optional `gh` remote.
- **Verifies** via `/doctor` that every tool actually works.
- **Idempotent**: safe to re-run — detects an already-set-up project and just health-checks it.

---

## What's in the box & why

### Root files
| File | Why it's here |
|------|---------------|
| `CLAUDE.md` | The project brain Claude reads every session. Kept <200 lines so nothing gets ignored. |
| `AGENTS.md` | Same rules for non-Claude tools (Codex/Cursor/Gemini). Points to CLAUDE.md = one source of truth. |
| `CLAUDE.local.md.example` | Copy → `CLAUDE.local.md` (gitignored) for machine-only notes (ports, OS, secrets-free local prefs). |
| `.gitignore` | Ignores secrets, `.env`, local Claude files; extended per stack at onboarding. |
| `.gitattributes` | Forces LF line endings (kills CRLF churn on Windows), marks binaries. |
| `.editorconfig` | Baseline indent/charset every editor respects. |
| `.mcp.json` | MCP servers. **context7** by default (live, version-correct library docs — no key). |
| `.env.example` | Copy → `.env` (gitignored). Onboarding adds the keys your stack needs. |
| `CHANGELOG.md` | Keep a Changelog format, ready to fill. |
| `docs/adr/` | Architecture Decision Records + template — record *why* behind hard-to-reverse choices. |
| `docs/specs/` | Spec template, pairs with the spec/plan skills. |

### Setup-phase files (auto-deleted after onboarding)
| File | Role |
|------|------|
| `setup.ps1` / `setup.sh` | Bootstrap: install tools, then launch Claude. |
| `scripts/install-tools.ps1` / `.sh` | The actual idempotent CLI installer (winget/brew/apt) + verification. |
| `.claude/install-manifest.md` | Declares what gets installed — edit your fork to change the baseline. |
| `.claude/skills/project-onboarding/` | The onboarding brain that drives customization. |
| `.claude/skills/example-skill/` | Placeholder skill, removed if unused. |
| this `README.md` | Replaced with a fresh project README. |

### `.claude/` — the permanent config
| Path | Why |
|------|-----|
| `settings.json` | Control panel: permissions (looser baseline; denies push + `rm -rf`), hook wiring, Stop notify, status line. |
| `settings.local.json.example` | Copy → `settings.local.json` (gitignored). `bypassPermissions` on = zero prompts on your trusted machine. |
| `statusline.ps1` | Prompt status line: `dir \| ⎇ branch \| model`. |
| `hooks/session-start.ps1` | Each session: prints git branch + last commit, activates **caveman** (terse output). |
| `hooks/post-edit-format.ps1` | Auto-formats files Claude edits (formatter set per stack). |
| `hooks/pre-deploy-guard.ps1` | Blocks a deploy command if tests fail (exit 2). |
| `hooks/notify.ps1` | Beep + "✅ finished" when Claude ends a turn, so you can look away. |
| `commands/` | Slash commands: `/ship /commit /pr /test /review /doctor`. |
| `agents/` | Subagents, cost-routed: code-reviewer/debugger/planner = **sonnet**; researcher/log-analyzer = **haiku**. |
| `rules/` | Loaded on demand: `git`, `api`, `production`, `ui`, `agents` (subagent model-routing policy). |
| `skills/` | Project skills (onboarding + example; your reusable workflows go here). |
| `plugins/README.md` | Log of installed plugins (installed at setup, not vendored). |
| `output-styles/concise.md` | Straight, no-fluff response style. |

---

## The tooling, and why each earns its place

- **rtk (Rust Token Killer)** — proxies dev commands and compresses output 60-90%. `rtk init -g` installs
  a PreToolUse(Bash) hook that auto-rewrites `git status`→`rtk git status` etc. — transparent, zero effort.
  *Scope:* hook covers Bash only (Read/Grep/Glob bypass — use shell or `rtk read`/`rtk grep`).
  *Platform:* full on macOS/Linux/WSL; native Windows has no auto-rewrite (CLAUDE.md fallback) → WSL recommended.
- **context7 (MCP)** — live, version-correct docs for any library/framework. Stops Claude writing code against stale APIs.
- **graphify (skill)** — turn code/docs/papers into a clustered knowledge graph. `/graphify`. Great for mapping unfamiliar code.
- **caveman (mode)** — terse output, ~75% fewer output tokens, full technical accuracy. Default `full`. `/caveman lite\|full\|ultra`.
- **cavecrew / parallel-kernel** — delegate fan-out work to compressed subagents on cheaper models; main context lasts longer.
- **Matt Pocock skills** + **Addy Osmani agent-skills** — battle-tested engineering workflows (TDD, planning, review, shipping).
- **fd / jq / bat / uv** — faster modern replacements for find/jq/cat/pip. Policy: prefer the objectively faster tool.

---

## Customize the baseline (before forking)
Edit these so every future project inherits your defaults:
- `.claude/install-manifest.md` — which skills/plugins/MCP/CLIs get installed.
- `scripts/install-tools.*` — add/remove CLIs or change package IDs.
- `.claude/hooks/session-start.ps1` — default caveman level, or disable.
- `.claude/settings.json` — permission allow/deny.
- `.claude/agents/`, `.claude/rules/` — your standard agents and rules.

## Re-running / health checks
- Re-run `/project-onboarding` anytime — it detects a finished project and just runs `/doctor`.
- `/doctor` — ✓/✗ table for every CLI, MCP, skill, agent, and hook, with fix commands.

## Requirements
PowerShell 7 (`pwsh`) on Windows; a POSIX shell elsewhere. Claude Code CLI. Internet for first install.
