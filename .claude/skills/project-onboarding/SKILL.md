---
name: project-onboarding
description: One-time setup that turns a clone of claude-template into a fully-configured project — NEW or EXISTING. Runs a detailed interview, installs tooling + workflow-chosen skills/hooks, intelligently writes or MERGES CLAUDE.md and .claude/, verifies via /doctor, suggests improvements, then deletes every trace of the template before the first commit. Triggered by setup.ps1/setup.sh or run manually with /project-onboarding.
---

# Project onboarding

Goal: leave a clean, fully-configured project — CLAUDE.md + .claude/ tailored to the user's stack AND
their workflow preferences — with **zero trace** that claude-template was ever here. Works for new and
existing projects, cross-platform. Be terse, but ASK clearly where input is required.

## Mode detection (do FIRST)
- **Staging present** (`.claude-template/` dir exists): EXISTING-project mode. Setup copied the template
  here as staging; merge from it into the real repo, never clobbering the user's files, then delete it.
- **Already onboarded** (no setup.* files AND CLAUDE.md has no `<placeholder>`/`<TBD>`): just run `/doctor`,
  fix issues, report, stop.
- **Fresh template clone** (setup.* present, little/no other code): NEW-project mode.
- Otherwise (real code/.git but template files mixed in): EXISTING-project mode — merge, keep their history.
Confirm the detected mode in one line before proceeding. In EXISTING mode: read their current
`CLAUDE.md`, `.claude/**`, `README`, and package manifests BEFORE changing anything.

## 0. Verify tools (setup already installed them)
`scripts/install-tools` installed git/node/gh/rg/fd/jq/bat/uv/rtk + ran `rtk init -g`. Verify:
`rtk --version` + `rtk gain` (failure = wrong crate). Install anything missing non-interactively.

## 1. Interview — HEAVILY DETAILED (batch via the question UI; confirm from files before asking)
Read existing manifests (package.json, pyproject.toml, go.mod, Cargo.toml, etc.) and CONFIRM rather
than ask when the answer is already on disk. Cover ALL sections; stop at ~95% confidence.

**A. Identity** — name; one-line goal; audience; the problem it solves; what "success" looks like.
**B. Platform** — dev OS + shell (Windows/macOS/Linux/WSL); target platform(s); runtime/version.
**C. Stack** — language(s); framework; package manager; build tool; database/auth; key libraries.
**D. Commands** — dev, build, test, lint, format, typecheck, deploy (read scripts; confirm).
**E. Quality bar** — testing style (TDD? coverage target); lint strictness; CI in use?; review process.
**F. Architecture** — subsystems; data flow; entry points; key files; state/config; SEO/indexing if web.
**G. Product** — monetization/pricing; feature gating (free vs pro); env vars/secrets the app needs.
**H. Workflow & preferences (drives which skills/hooks get installed)** —
  - Output style: terse vs explained; caveman level (off/lite/full/ultra).
  - Which automations to enable: pre-deploy test guard? auto-format on edit? notify-on-finish?
    secret-scan pre-commit? commit-msg conventional-commit enforcement?
  - Commit/branch conventions; who is allowed to push; default branch name.
  - Domains needing extra skills: frontend design / security / performance / docs+ADR / browser testing
    / data / API design / infra. (Map each to a skill to install in step 2b.)
  - MCP servers wanted: github, chrome-devtools, a database server, others.
  - Any personal rituals/workflows to encode as a custom `/command` or skill (capture the steps).
**I. Git/remote** — existing remote? create one (gh)? visibility? default branch (prefer `main`).

## 2. Install default skills/plugins (automatic — full set)
context7 (already in `.mcp.json`); graphify (copy `~/.claude/skills/graphify`); Matt Pocock
(`npx -y skills@latest add mattpocock/skills`); Addy Osmani (`/plugin marketplace add addyosmani/agent-skills`
+ install). Verify each.

## 2b. Workflow-chosen skills/hooks (from interview H)
Install/enable only what the user picked:
- Toggle hooks in `.claude/settings.json`: keep/remove pre-deploy-guard, post-edit-format, notify per choice.
- Set caveman level in `session-start.ps1`.
- Domain skills: install the matching skills/plugins (e.g. frontend-design, security, perf, browser-testing).
- Add chosen MCP servers to `.mcp.json` (github, chrome-devtools, db, ...).
- Turn each described personal ritual into a `.claude/commands/<name>.md` or a `.claude/skills/<name>/SKILL.md`.

## 3. Stack tooling — pick modern defaults and WIRE in
Python→ruff+pyrefly+pytest; TS/JS→eslint+prettier+vitest/jest; Go→golangci-lint+gofmt+go test;
Rust→clippy+rustfmt+cargo test. Then: fill `FORMAT_CMD` in post-edit-format.ps1; fill DEPLOY_PATTERN+TEST_CMD
in pre-deploy-guard.ps1 (only if a deploy target exists); fill the CLAUDE.md Commands table; create missing
linter/formatter configs. Respect existing configs in EXISTING mode.

## 4. CLAUDE.md — write (new) or MERGE (existing). Keep COMPACT (<200 lines, aim <120)
- NEW: fill every `<placeholder>`/`<TBD>` from the interview; one line per item; trim inapplicable sections.
- EXISTING: do NOT overwrite. Read their CLAUDE.md; merge in only what's missing (the Tooling section for
  rtk/context7/graphify/caveman, git rules, commands table) while preserving their content, ordering, and
  voice. If they have none, create one. Keep it under 200 lines; if theirs is bloated, suggest trims, don't force.
- Put target platform in CLAUDE.md; dev-machine specifics in CLAUDE.local.md.
- `.claude/rules/*`: in EXISTING mode, add new rule files only if absent; never clobber theirs.

## 5. Local config + .gitignore + license
Copy `*.example` → real files (CLAUDE.local.md, settings.local.json, .env) only if absent. Write `LICENSE`
(skip if existing or "none"). Merge-append stack entries into `.gitignore` (dedupe; don't duplicate theirs).

## 6. Recommendations (after verify-ready, before commit)
Based on stack + domain + workflow, SUGGEST high-value additions not yet installed — e.g. chrome-devtools
MCP for web, security skills for auth/payments, performance skills if perf matters, ADR/docs discipline,
github MCP, CI stub. Present as a short pick-list; install what the user accepts. Don't force.

## 7. Cleanup — leave NO trace (automatic, BEFORE the first commit)
Delete without asking (confirm only if a path is unexpectedly missing/modified):
- `.claude-template/` staging dir (EXISTING mode), `setup.ps1`, `setup.sh`, `scripts/`,
  `.claude/install-manifest.md`, `.claude/skills/example-skill/`, and this skill
  (`.claude/skills/project-onboarding/` — delete LAST), plus any `*.fromtemplate`/`*.template`/backup files.
- NEW mode: replace template `README.md` with a fresh project README. EXISTING mode: keep their README untouched.
KEEP: `.claude/` hooks/agents/rules/commands/output-styles/settings, `AGENTS.md`, `.gitattributes`,
`.editorconfig`, `docs/`, `CHANGELOG.md`, `*.example`.
Then grep and purge every leftover mention: `claude-template`, `TEMPLATE`, `<placeholder>`, `<TBD>`,
`<PROJECT_NAME>`, "scaffold from claude-template". Verify none remain. Ensure no template git remote exists.

## 8. Git
- NEW: `git init` (template `.git` already removed by setup), verify secrets gitignored, first commit
  `chore: initial project setup`.
- EXISTING: keep their `.git` and history. Stage only the added/merged config; commit
  `chore: add Claude Code config` (respect their commit conventions if known). Never force or rewrite history.
- Remote: if requested, `gh repo create <name> --<visibility> --source=. --remote=origin` (confirm). Prefer `main`.

## 8b. Verify
Run `/doctor`; every check green (CLIs, context7 real resolve, graphify, Matt Pocock + Addy Osmani,
caveman, cavecrew, agent models, hooks, status line). Fix any ✗ before reporting.

## 9. Report
Mode; platform; stack; tools verified (✓/✗); default + workflow skills installed; hooks/commands wired;
files created vs merged; files removed in cleanup; `/doctor` result; git status; recommendations accepted;
anything still needing the user (secrets in `.env`, failed install, remote).

## Rules
- EXISTING mode is non-destructive: merge/append, back up before edits, NEVER delete user code or their `.git`.
- Cleanup of the known template artifact list is automatic; confirm only outside that list.
- Never commit secrets. Cross-platform: prefer `rg`/`fd`/path-agnostic ops; don't assume bash-only.
- If an install fails, report and continue; don't block onboarding.
