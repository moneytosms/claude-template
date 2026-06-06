---
name: project-onboarding
description: One-time setup for a project freshly cloned from claude-template. Interviews the user, installs default tooling, customizes CLAUDE.md and hooks for the stack, scaffolds gitignore, inits git, and removes template-only files. Triggered by setup.ps1/setup.sh, or run manually with /project-onboarding.
---

# Project onboarding

You are setting up a brand-new project cloned from `claude-template`. Goal: leave a clean,
stack-appropriate, git-initialized project with CLAUDE.md filled in and all template scaffolding
either customized or removed. Be terse (caveman ok), but ASK before destructive/irreversible steps.

Work in this order. Do not skip the interview — everything downstream depends on it.

## Idempotency (safe to re-run)
First detect whether onboarding already ran: if `setup.ps1`/`setup.sh` are gone OR `CLAUDE.md` has no
`<placeholder>`/`<TBD>` tokens, the project is already set up. In that case DON'T redo everything —
just run `/doctor` to verify tooling, fix anything broken, report, and stop. Otherwise proceed.
Within a fresh run, skip any step already done (skill already copied, LICENSE exists, etc.).

## 0. Prerequisites (already installed by setup — verify only)
`setup.ps1`/`setup.sh` ran `scripts/install-tools` which installed all baseline CLIs
(git, node, gh, rg, fd, jq, bat, uv, rtk) and ran `rtk init -g --auto-patch`. Just verify:
- `rtk --version` + `rtk gain` (if `rtk gain` fails it's the wrong crate). Restart hint: rtk hook is
  active for new sessions. Native Windows = CLAUDE.md fallback (no auto-rewrite); WSL = full.
- If any tool is still missing (e.g. setup was skipped), install it now via the platform package
  manager, non-interactively. Stack toolchain + linters (ruff/pyrefly, golangci-lint, cargo...) are
  installed after the interview in step 3.
- Cloud/container CLIs (docker, vercel, aws): install on demand only.

## 1. Interview (collect everything first, then act)
Ask, ideally batched via the question UI. Stop when you have ~95% of what you need:
- Project name + one-line goal + who it's for.
- **Platform**: OS you develop on (Windows / macOS / Linux / WSL) + target platform(s) you ship to.
  (Drives rtk hook expectations, path/shell choices, .gitignore, build/test commands.)
- Domain: web / API / CLI / desktop / mobile / library / data / other.
- Language(s) + framework/runtime. (If a manifest like package.json/pyproject.toml exists, read it and confirm instead of asking.)
- Package manager + dev/build/test/lint commands (or "none yet").
- Does it have: an API? a UI? a database? payments? deploy target/host?
- Monetization, if any.
- License: MIT / Apache-2.0 / proprietary / none.
- Git remote: create one now (gh) or local-only?
- Anything project-specific to bake into CLAUDE.md rules.

## 2. Install default skills/plugins (automatic — install all, don't ask)
Run from `.claude/install-manifest.md`. Install the full default set, verify, report one line each:
- **context7**: already in `.mcp.json`. No key. Verify resolves.
- **graphify**: if `~/.claude/skills/graphify` exists, copy into `.claude/skills/graphify`; else clone source.
- **Matt Pocock skills**: `npx -y skills@latest add mattpocock/skills` (use non-interactive flags if available; install the full set).
- **Addy Osmani agent-skills**: if not already global, `/plugin marketplace add addyosmani/agent-skills` then install.
- Add stack-specific MCP servers to `.mcp.json` only if the user has that dependency.

## 3. Stack-specific tooling
Pick modern defaults for the declared stack and WIRE them in (don't just mention):
- Python → `ruff check` + `ruff format` + `pyrefly` (types) + `pytest`.
- TS/JS → eslint + prettier + vitest/jest; respect existing config.
- Go → golangci-lint + gofmt + `go test`.
- Rust → clippy + rustfmt + `cargo test`.
Then:
- Fill `FORMAT_CMD` in `.claude/hooks/post-edit-format.ps1`.
- Fill `DEPLOY_PATTERN` + `TEST_CMD` in `.claude/hooks/pre-deploy-guard.ps1` (only if a deploy target exists; else leave disabled).
- Fill the Commands table in CLAUDE.md (dev/build/test/lint) so `/ship`, `/test` work.
- Generate/extend config files for the chosen linters/formatters if missing.

## 4. Customize CLAUDE.md (keep it COMPACT — <200 lines, ideally <120)
Replace every `<placeholder>`/`<TBD>` from interview answers: name, goal, domain, target platform,
tech stack, commands table, architecture, key files. Be terse — one line per item, no prose padding;
the file must cover everything but stay scannable. Trim sections that don't apply (remove the API note
if no API). Keep the "Tooling available" section but drop any tool the user skipped.
- Put the **project's target platform(s)** in CLAUDE.md (committed, shared).
- Put the **dev machine specifics** (your OS/shell, local ports, WSL vs native) in CLAUDE.local.md.
- Update `.claude/rules/*.md`: keep git.md + agents.md; trim/fill api.md, production.md, ui.md to match
  reality or delete the irrelevant ones.

## 5. Local config + .gitignore
- Copy `CLAUDE.local.md.example` → `CLAUDE.local.md` (real one gitignored) and fill local notes.
- Copy `.claude/settings.local.json.example` → `.claude/settings.local.json` (gitignored). Keep
  bypassPermissions unless the user wants prompts.
- Copy `.env.example` → `.env` and add stack keys.
- Write `LICENSE` for the chosen license (fill author + year); skip if "none".
- Extend `.gitignore` with stack-appropriate entries (e.g. `__pycache__/`, `.venv/`, `target/`, `*.pyc`, build dirs).

## 6. Cleanup (automatic — remove ALL setup-phase artifacts, then verify)
Do this BEFORE the first commit so history is clean. Delete the known template/setup artifacts without
asking (they have no ongoing use); only confirm if a path is unexpectedly missing or modified:
- `setup.ps1`, `setup.sh`, `scripts/` (install-tools.*)
- `.claude/install-manifest.md`
- `.claude/skills/project-onboarding/` (this skill — delete last)
- `.claude/skills/example-skill/`
- template `README.md` → replace with a fresh minimal project README (name + one-line + how to run).
KEEP (ongoing value, do not delete): `.claude/` hooks/agents/rules/commands/output-styles/settings,
`AGENTS.md`, `.gitattributes`, `.editorconfig`, `docs/`, `CHANGELOG.md`, all `*.example` files.
Then grep the repo for leftovers and fix: `claude-template`, `TEMPLATE`, `<placeholder>`, `<TBD>`,
`<PROJECT_NAME>`, "scaffold from claude-template". Confirm none remain.

## 7. git init + first commit
- `git init` (the template's own `.git` was already removed by the setup script).
- Verify `.env`, `CLAUDE.local.md`, `.claude/settings.local.json` are gitignored (no secrets staged).
- If the user wanted a remote: `gh repo create <name> --private --source=. --remote=origin` (confirm visibility).
- Stage all, first commit: `chore: initial project setup`.

## 7b. Verify everything works
Run `/doctor` and confirm every check is green: CLIs, context7 MCP (do a real resolve), graphify loads,
Matt Pocock + Addy Osmani skills present, caveman active, cavecrew available, agents have correct
models, hooks fire + status line shows. Fix any ✗ before reporting.

## 8. Report
Summarize: platform, stack detected, tools verified (✓/✗ each), skills installed, hooks/commands wired,
files customized, files removed in cleanup, git status, and the `/doctor` result.
List anything still needing the user
(secrets in `.env`, a failed install, remote not created).

## Rules
- Cleanup of the known artifact list above is automatic — no per-file prompt. Confirm only for
  deletions outside that list, creating a remote repo, or `git init` in an unexpected non-empty dir.
- Never commit secrets. Ensure local/secret files are gitignored before the first commit.
- If an install command fails, report it and continue; don't block the whole onboarding.
