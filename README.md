# claude-template

A generic, **stack-agnostic Claude Code base** you clone once per project. Run one script: it
auto-installs your tooling, then Claude runs a detailed interview and customizes everything to your
project **and your workflow**. When it finishes, every template/setup file deletes itself — you're left
with a clean, fully-configured project and **no trace** the template was ever there.

Works for **new and existing** projects, on **Windows / macOS / Linux / WSL**.

- Repo: https://github.com/moneytosms/claude-template 

---

## Table of contents
1. [Quick start](#quick-start)
2. [Adding to an existing project](#adding-to-an-existing-project)
3. [The full flow](#the-full-flow)
4. [Setup flags](#setup-flags)
5. [Everything in the box](#everything-in-the-box)
6. [The tooling — what gets installed & why](#the-tooling)
7. [What is NOT included (by design)](#what-is-not-included)
8. [Customize the baseline](#customize-the-baseline)
9. [Re-running, health checks, troubleshooting](#re-running--health-checks)
10. [Requirements](#requirements)

---

## Quick start

**New project** (this clone becomes the project):
```sh
git clone https://github.com/moneytosms/claude-template my-project
cd my-project
pwsh ./setup.ps1          # Windows
sh   ./setup.sh           # macOS / Linux / WSL / git-bash
```

**Existing project** — see [Adding to an existing project](#adding-to-an-existing-project) below.

That's it. The only thing you do by hand is answer the interview.

---

## Adding to an existing project

Three paths — pick the one that fits your situation. All are non-destructive: your code, git
history, and existing `.claude/` customizations are never clobbered.

### Path A — setup script (recommended; also installs CLIs + rtk)
Run this from anywhere. The template is cloned to a temp location, merged into your project, then
the temp clone is deleted.

```sh
# macOS / Linux / WSL
git clone https://github.com/moneytosms/claude-template /tmp/ct
sh /tmp/ct/setup.sh --into /path/to/your-project

# Windows (PowerShell)
git clone https://github.com/moneytosms/claude-template $env:TEMP\ct
pwsh $env:TEMP\ct\setup.ps1 -Into C:\path\to\your-project
```

This installs `git node gh rg fd jq bat uv rtk`, runs `rtk init -g --auto-patch`, stages the
template into `your-project/.claude-template/`, then launches Claude to run `/project-onboarding`.

### Path B — already in Claude Code (no CLI setup, no temp clone)
If you have Claude Code open in your existing project and just want to add the config, run:

```
/project-onboarding
```

Claude detects it's an existing project (has `.git`, no staging dir), bootstraps by cloning the
template into `.claude-template-tmp/`, merges config, then cleans up. CLIs/rtk are NOT auto-installed
(Claude will flag any missing tools via `/doctor` after onboarding and give you the install commands).

### Path C — manual copy (when you prefer full control)
Copy `.claude/` from the template into your project, then kick off onboarding:

```sh
# Download just the .claude/ folder (no full clone needed)
git clone --depth 1 https://github.com/moneytosms/claude-template /tmp/ct
cp -r /tmp/ct/.claude /tmp/ct/.mcp.json /tmp/ct/.gitignore /tmp/ct/CLAUDE.md \
      /tmp/ct/AGENTS.md /tmp/ct/.gitattributes /tmp/ct/.editorconfig \
      /path/to/your-project/
rm -rf /tmp/ct
```

Then open your project in Claude Code and run `/project-onboarding`. Onboarding detects the
template files are present (no staging dir but setup.* absent), proceeds in EXISTING merge mode.

### What all three paths do the same

| Step | Result |
|------|--------|
| Mode detection | EXISTING — merge, never clobber |
| Your `.git` | **untouched** |
| Your code / README | **untouched** |
| `CLAUDE.md` | **merged** — your content kept; template tooling section added where missing |
| `.claude/rules/` | added only where absent; never overwrites yours |
| `.claude/hooks/` | added if absent; yours kept if already customized |
| Commit | `chore: add Claude Code config` to your existing history |
| Cleanup | all template staging files deleted; no trace left |

---

## The full flow

```
┌─ setup.ps1 / setup.sh ──────────────────────────────────────────────┐
│ 1. Confirm (skippable with --yes).                                   │
│ 2. scripts/install-tools.* — idempotent CLI install + ✓/✗ verify     │
│      git node gh rg fd jq bat uv  + rtk   (winget / brew / apt / dnf) │
│ 3. rtk init -g --auto-patch  → token-saving Bash hook into Claude     │
│ 4. NEW: delete template .git    EXISTING: stage template into         │
│         (becomes the project)            <repo>/.claude-template/      │
│ 5. launch `claude` → /project-onboarding                             │
└──────────────────────────────────────────────────────────────────────┘
                                  │
┌─ /project-onboarding (Claude) ──▼───────────────────────────────────┐
│ Mode detect: NEW · EXISTING (merge) · already-onboarded (just /doctor)│
│ 0  verify tools                                                       │
│ 1  DETAILED interview (9 sections, see below)                        │
│ 2  install default skills: context7, graphify, Matt Pocock, Addy O.  │
│ 2b install workflow-chosen skills/hooks/MCP + encode your rituals     │
│ 3  pick stack tooling (linter/formatter/test) and WIRE into hooks    │
│ 4  write (new) or MERGE (existing) CLAUDE.md — compact, non-destructive│
│ 5  local config (*.example→real), .gitignore, LICENSE                 │
│ 6  RECOMMENDATIONS — suggest more skills/tools for your stack+domain  │
│ 7  CLEANUP (no trace): delete all setup/template files, purge mentions│
│ 8  git: NEW → init+commit · EXISTING → commit added config to history │
│ 8b /doctor — verify every tool actually works (must be green)         │
│ 9  report                                                            │
└──────────────────────────────────────────────────────────────────────┘
```

### The interview (heavily detailed)
Claude reads your manifests first and confirms instead of asking when it already knows. Sections:
- **A. Identity** — name, goal, audience, problem, definition of success.
- **B. Platform** — dev OS + shell, target platform(s), runtime/version.
- **C. Stack** — language, framework, package manager, build tool, database/auth, key libraries.
- **D. Commands** — dev, build, test, lint, format, typecheck, deploy.
- **E. Quality bar** — testing style (TDD?), coverage, lint strictness, CI, review process.
- **F. Architecture** — subsystems, data flow, entry points, key files, state/config.
- **G. Product** — monetization, feature gating, env vars/secrets.
- **H. Workflow & preferences** — output style + caveman level; which automations/hooks to enable;
  commit/branch conventions; domains needing extra skills; MCP servers; personal rituals → `/commands`.
- **I. Git/remote** — existing remote? create one? visibility? default branch.

### New vs existing — what differs
| | NEW project | EXISTING — Path A/C | EXISTING — Path B (Claude-only) |
|---|---|---|---|
| Trigger | `setup` (no `--into`) | `setup --into` or manual copy | `/project-onboarding` in Claude |
| CLIs + rtk installed | ✅ auto | ✅ auto (Path A) / ❌ manual (Path C) | ❌ — flagged by `/doctor` after |
| Your `.git` | template's deleted; fresh `git init` | **untouched** | **untouched** |
| Your files | none to protect | **never clobbered**; merge only | **never clobbered**; merge only |
| Template staging | copied by `setup` | copied by `setup` / manual | **auto-cloned** into `.claude-template-tmp/` |
| `CLAUDE.md` | written from template | **merged** — adds only what's missing | **merged** — adds only what's missing |
| `.claude/` rules | all added | added only where absent | added only where absent |
| README | template → fresh project README | your README left alone | your README left alone |
| Commit | `chore: initial project setup` | `chore: add Claude Code config` | `chore: add Claude Code config` |

---

## Setup flags
| Flag | Effect |
|------|--------|
| `--yes` / `-y` | Skip the confirm prompt (unattended). |
| `--dry-run` | Print what would install/delete; change nothing; don't launch Claude. |
| `--into <path>` / `-Into <path>` | Apply to an existing project at `<path>` (merge mode). |

---

## Everything in the box

### Root files
| File | Purpose | Survives onboarding? |
|------|---------|:---:|
| `CLAUDE.md` | Project brain Claude reads every session. <200 lines. | ✅ (filled/merged) |
| `AGENTS.md` | Same rules for Codex/Cursor/Gemini — points to CLAUDE.md. | ✅ |
| `CLAUDE.local.md.example` | → `CLAUDE.local.md` (gitignored): machine-only notes. | ✅ |
| `.gitignore` | Ignores secrets, `.env`, local Claude files; extended per stack. | ✅ |
| `.gitattributes` | Forces LF endings, marks binaries (kills CRLF churn). | ✅ |
| `.editorconfig` | Baseline indent/charset for every editor. | ✅ |
| `.mcp.json` | MCP servers — **context7** by default (no key). | ✅ |
| `.env.example` | → `.env` (gitignored); onboarding adds your keys. | ✅ |
| `CHANGELOG.md` | Keep a Changelog format. | ✅ |
| `README.md` | This file. | ❌ replaced (new) / untouched (existing) |
| `setup.ps1` / `setup.sh` | Bootstrap: install tools, then launch Claude. | ❌ deleted |
| `scripts/install-tools.ps1` / `.sh` | Idempotent CLI installer + verify + PATH note. | ❌ deleted |

### `docs/`
| Path | Purpose |
|------|---------|
| `docs/adr/template.md`, `0001-record-architecture-decisions.md` | Architecture Decision Records. |
| `docs/specs/template.md` | Spec template (pairs with spec/plan skills). |

### Other root files
| Path | Purpose | Survives? |
|------|---------|:---:|
| `justfile` | Task runner (dev/build/test/lint), filled per stack. | ✅ if you chose `just` |
| `.githooks/pre-commit` | gitleaks secret-scan (opt-in; wired via `core.hooksPath`). | ✅ if secret-scan enabled |
| `.github/workflows/template-validate.yml` | Self-CI: validates the template's own scripts/JSON. | ❌ deleted (template-only) |

### `.claude/` — the permanent config
| Path | Purpose | Survives? |
|------|---------|:---:|
| `settings.json` | Permissions (denies push + broad `rm -rf *`; allows specific cleanup paths), hooks, statusLine. | ✅ |
| `settings.local.json.example` | → `settings.local.json` (gitignored): `bypassPermissions` on. | ✅ |
| `statusline.mjs` | Status line: `dir \| ⎇ branch \| model \| ctx% \| 5h/7d rate-limit% \| +/- lines`. | ✅ |
| `licenses/` | MIT / Apache-2.0 templates onboarding writes from. | ❌ deleted after LICENSE written |
| `install-manifest.md` | Declares what gets installed (edit to change the baseline). | ❌ deleted |
| `hooks/*.mjs` | Node hooks (cross-platform, no shell): session-start, post-edit-format, pre-deploy-guard, notify. | ✅ |
| `hooks/_stdin.mjs` | Shared stdin-reader/JSON helper for the hooks. | ✅ |
| `commands/` | `/ship /commit /pr /test /review /doctor`. | ✅ |
| `agents/` | code-reviewer, debugger, planner (sonnet); researcher, log-analyzer (haiku). | ✅ |
| `rules/` | `git`, `api`, `production`, `ui`, `agents` (model routing) — loaded on demand. | ✅ |
| `skills/project-onboarding/` | The setup brain. | ❌ deleted |
| `skills/example-skill/` | Placeholder for your own skill. | ❌ deleted if unused |
| `plugins/README.md` | Log of installed plugins. | ✅ |
| `output-styles/concise.md` | No-fluff response style. | ✅ |

### Hooks wired in `settings.json` (all Node — `node .claude/hooks/*.mjs`)
| Event | Script | What it does |
|-------|--------|--------------|
| SessionStart | session-start.mjs | git state + caveman on |
| PostToolUse (Edit\|Write) | post-edit-format.mjs | auto-format |
| PreToolUse (Bash) | pre-deploy-guard.mjs | block failing deploys |
| Stop | notify.mjs | finish ping |
| statusLine | statusline.mjs | prompt status line |

### Slash commands
`/ship` (lint→build→test→deploy) · `/commit` (Conventional Commit) · `/pr` (gh PR) ·
`/test` (run suite) · `/review` (diff review via code-reviewer) · `/doctor` (health-check all tooling) ·
`/template-update` (pull the latest baseline hooks/agents/rules into an already-onboarded project).

### Subagents (cost-routed via `model:` frontmatter)
`code-reviewer`, `debugger`, `planner` → **sonnet** (reasoning). `researcher`, `log-analyzer` → **haiku**
(recon/parse; log-analyzer triages through rtk first). Policy in `.claude/rules/agents.md`.

---

## The tooling

### Installed automatically by `setup` (CLIs)
`git`, `node`, `gh`, `rg` (ripgrep), `fd`, `jq`, `bat`, `just`, `uv`, **`rtk`** — idempotent (skips if present).
Windows uses winget (rtk via release zip); macOS brew; Linux/WSL apt or dnf (uv/rtk via their installers).
Hooks + status line are **Node** (`.mjs`) — cross-platform, no PowerShell needed (node is already installed).
On Debian/Ubuntu, `fd`/`bat` ship as `fdfind`/`batcat` — setup auto-symlinks them to `fd`/`bat`.
`gitleaks` is installed only if you enable secret-scanning.

### Installed automatically during onboarding (skills/MCP)
| Tool | Type | Why | Source |
|------|------|-----|--------|
| **context7** | MCP | Live, version-correct library docs; stops stale-API code. | `@upstash/context7-mcp` (no key) |
| **graphify** | skill | Any input → clustered knowledge graph. `/graphify`. | copied from your global skills |
| **Matt Pocock skills** | skills | TDD, planning, review, git guardrails. | `npx skills@latest add mattpocock/skills` |
| **Addy Osmani agent-skills** | plugin | 23 lifecycle skills (spec→ship). | `/plugin marketplace add addyosmani/agent-skills` |
| **rtk** | CLI + hook | Cuts command-output tokens 60-90% via auto-rewrite. | github.com/rtk-ai/rtk |

### rtk specifics
- `rtk init -g` installs a **PreToolUse(Bash) hook** that transparently rewrites commands
  (`git status` → `rtk git status`). Zero effort once installed.
- Scope: **Bash only**. Claude's Read/Grep/Glob bypass it — use shell or `rtk read`/`rtk grep` for those.
- Platform: **full** on macOS/Linux/WSL; **native Windows has no auto-rewrite** (falls back to CLAUDE.md
  injection — call `rtk` explicitly). WSL recommended for the full hook.

### Opt-in (offered in the interview / recommendations, installed only if accepted)
| Tool | Type | Why |
|------|------|-----|
| **gitleaks** | pre-commit | Block committing secrets/keys. |
| **chrome-devtools** | MCP | Real-browser testing (DOM/console/network/perf). |
| **github** | MCP | PR/issue/repo ops from chat (needs `GITHUB_TOKEN`). |
| **CI + `.github/`** | scaffold | Workflow stub, PR/issue templates, CODEOWNERS, dependabot. |

### Already global (assumed present, not installed by template)
**caveman** (terse mode, default `full`, self-activated by session-start hook) and **cavecrew /
parallel-kernel** (compressed subagent fan-out). The session-start hook makes caveman self-contained
per project even if the global plugin isn't there.

---

## What is NOT included

By design, to stay generic — onboarding adds these only if your project needs them:
- **No stack assumptions** — no React/Next/Supabase/Stripe/Vercel baked in.
- **No CI workflow** (no `.github/workflows`) — recommended during onboarding if you want it.
- **No git pre-commit hook** — quality is enforced by discipline + `/ship` (you can opt into a
  commit-msg/secret-scan hook in the interview).
- **No GitHub templates / CODEOWNERS / dependabot** — offered as recommendations.
- **No LICENSE** until onboarding asks which one.
- **No chrome-devtools or other MCP servers** beyond context7 — added per workflow choice.
- **No language toolchains/linters** until your stack is known (then ruff+pyrefly / eslint+prettier / etc.).

---

## Customize the baseline
Fork this repo and edit, so every future project inherits your defaults:
- `.claude/install-manifest.md` — which skills/plugins/MCP/CLIs install.
- `scripts/install-tools.*` — add/remove CLIs or change package IDs.
- `.claude/hooks/session-start.mjs` — default caveman level (or disable).
- `.claude/settings.json` — permission allow/deny, hooks, status line.
- `.claude/agents/`, `.claude/rules/`, `.claude/commands/` — your standard kit.

---

## Re-running / health checks
- **`/project-onboarding`** is safe to re-run — detects a finished project and just runs `/doctor`.
- **`/doctor`** — ✓/✗ for every CLI, MCP (real context7 resolve), skill, agent, hook, status line,
  each with its fix command.
- **`--dry-run`** — preview installs/deletes without touching anything.

### Troubleshooting
- *`rtk gain` errors* → wrong crate installed (name collision). Reinstall via `cargo install --git https://github.com/rtk-ai/rtk`.
- *Tools "not found" right after install* → open a new terminal (PATH update) or run the printed `export PATH`/`$env:PATH` line.
- *rtk not rewriting on Windows* → expected on native Windows; use WSL or call `rtk` explicitly.
- *`npx skills add` prompts* → that installer is interactive; pick your skills when asked.
- *Hooks not firing* → ensure `node` is on PATH (hooks run via `node`). Run `/doctor`.
- *Path B: CLIs missing after onboarding* → run `/doctor` for a ✗ list with fix commands, or run `setup --into .` from a cloned template copy to install them all at once.
- *Path B: template clone fails during bootstrap* → check internet + GitHub auth (`gh auth status`). If the repo is private and unauthenticated, use Path A or C instead.

---

## Requirements
**Bootstrap:** Windows runs `setup.ps1` (any PowerShell, incl. 5.1); macOS/Linux/WSL run `setup.sh`.
**Runtime:** `node` (runs the hooks + status line — no PowerShell needed) + the Claude Code CLI.
`gh` for remotes. Internet for first install. winget (Windows) / brew (macOS) / apt or dnf (Linux).
