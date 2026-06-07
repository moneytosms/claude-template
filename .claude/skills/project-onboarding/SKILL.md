---
name: project-onboarding
description: One-time setup that turns a clone of claude-template into a fully-configured project — NEW or EXISTING. Runs a detailed interview, installs tooling + workflow-chosen skills/hooks, intelligently writes or MERGES CLAUDE.md and .claude/, verifies via /doctor, suggests improvements, then deletes every trace of the template before the first commit. Triggered by setup.ps1/setup.sh or run manually with /project-onboarding.
---

# Project onboarding

Goal: leave a clean, fully-configured project — CLAUDE.md + .claude/ tailored to the user's stack AND
their workflow preferences — with **zero trace** that claude-template was ever here. Works for new and
existing projects, cross-platform. Be terse, but ASK clearly where input is required.

## Mode detection (do FIRST)

Detect exactly one mode, confirm it in one line, then proceed.

- **Already onboarded** — no setup.* AND CLAUDE.md has no `<placeholder>`/`<TBD>` AND `.claude/hooks/`
  exists: just run `/doctor`, fix any ✗, report, stop.
- **Fresh template clone** — setup.* present AND little/no user code: NEW-project mode.
- **Staging present** — `.claude-template/` dir exists (placed here by `setup --into`): EXISTING mode.
  Merge from the staging dir into the real repo, then delete it.
- **Bootstrap needed** — `.git` exists, real user code present, NO staging dir AND NO setup.* files:
  EXISTING mode, no staging. **Auto-bootstrap**: clone the template into `.claude-template-tmp/`
  (`git clone https://github.com/moneytosms/claude-template .claude-template-tmp --depth 1`), then
  treat `.claude-template-tmp/` as the staging dir. Proceed as staging-present EXISTING mode; the
  cleanup step (§7) deletes `.claude-template-tmp/` like any staging dir. Tell the user you are
  doing this. Note: CLIs/rtk were NOT installed — after onboarding, flag missing tools via `/doctor`.
- **Template files without setup.*** — real code + `.git` + template config already copied in manually:
  EXISTING mode (merge only what's absent; skip the bootstrap clone since files already exist).

In EXISTING mode: read their current `CLAUDE.md`, `.claude/**`, `README`, and package manifests
BEFORE changing anything.

## 0. Verify tools
If setup.* was run: `scripts/install-tools` already installed git/node/gh/rg/fd/jq/bat/uv/rtk.
If Path B (Claude-only bootstrap): tools may be missing — check each with `--version`; report ✗ but
don't block onboarding. Install anything missing non-interactively where possible.
Always verify: `rtk --version` + `rtk gain` (failure = wrong crate; reinstall via cargo --git).

## 1. Interview — HEAVILY DETAILED (ask sequentially; confirm from files before asking)
Read existing manifests (package.json, pyproject.toml, go.mod, Cargo.toml, etc.) and CONFIRM rather
than ask when the answer is already on disk. Cover ALL sections; stop at ~95% confidence.

**AskUserQuestion limit: max 4 questions per call, must be multiple-choice. Split the interview into
batches of ≤4 questions each, or ask conversationally. Never batch all 9 categories in one call.**

Round 1 (identity + platform + stack): A, B, C  
Round 2 (commands + quality + architecture): D, E, F  
Round 3 (product + workflow + git): G, H, I

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
    secret-scan pre-commit (gitleaks)? commit-msg conventional-commit enforcement?
  - Task runner: use `just` (justfile) as the single dev/build/test/lint entrypoint? (else it's removed)
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
- Set caveman level in `.claude/hooks/session-start.mjs` (edit `CAVEMAN_LEVEL` constant).
- **Secret-scan**: if enabled, install `gitleaks`, then run `chmod +x .githooks/pre-commit` and
  `git config core.hooksPath .githooks` (the `.githooks/pre-commit` runs it). Verify with
  `git config core.hooksPath`. If NOT enabled, delete `.githooks/`.
- **Task runner**: if the user wants `just`, keep `justfile` and fill its recipes from the Commands
  table; else delete `justfile`.
- Domain skills: install the matching skills/plugins (e.g. frontend-design, security, perf, browser-testing).
- Add chosen MCP servers to `.mcp.json` (github → needs `GITHUB_TOKEN`; chrome-devtools; db, ...).
- Turn each described personal ritual into a `.claude/commands/<name>.md` or a `.claude/skills/<name>/SKILL.md`.

## 3. Stack tooling — pick modern defaults and WIRE in
Python→ruff+pyrefly+pytest; TS/JS→eslint+prettier+vitest/jest; Go→golangci-lint+gofmt+go test;
Rust→clippy+rustfmt+cargo test. Then: fill `FORMAT_CMD` in `.claude/hooks/post-edit-format.mjs`; fill
`DEPLOY_PATTERN`+`TEST_CMD` in `.claude/hooks/pre-deploy-guard.mjs` (only if a deploy target exists);
fill the CLAUDE.md Commands table; create missing linter/formatter configs. Respect existing configs in
EXISTING mode.

## 4. CLAUDE.md — write (new) or MERGE (existing). Keep COMPACT (<200 lines, aim <120)
- NEW: fill every `<placeholder>`/`<TBD>` from the interview; one line per item; trim inapplicable sections.
- EXISTING: do NOT overwrite. Read their CLAUDE.md; merge in only what's missing (the Tooling section for
  rtk/context7/graphify/caveman, git rules, commands table) while preserving their content, ordering, and
  voice. If they have none, create one. Keep it under 200 lines; if theirs is bloated, suggest trims, don't force.
- Put target platform in CLAUDE.md; dev-machine specifics in CLAUDE.local.md.
- `.claude/rules/*`: in EXISTING mode, add new rule files only if absent; never clobber theirs.

## 5. Local config + .gitignore + license
Copy `*.example` → real files (CLAUDE.local.md, settings.local.json, .env) only if absent.
Write `LICENSE` from `.claude/licenses/<choice>.txt` (fill `<YEAR>`/`<AUTHOR>`; for Apache-2.0 fetch the
full text from apache.org); skip if existing or "none". Merge-append stack entries into `.gitignore`
(dedupe; don't duplicate theirs).

## 6. Recommendations (after verify-ready, before commit)
Based on stack + domain + workflow, SUGGEST high-value additions not yet installed — e.g. chrome-devtools
MCP for web, github MCP for PR/issue ops, security skills for auth/payments, performance skills if perf
matters, ADR/docs discipline, a CI workflow stub + `.github/` (PR/issue templates, CODEOWNERS, dependabot).
Present as a short pick-list; scaffold/install what the user accepts. Don't force.

## 7. Cleanup — leave NO trace (automatic, BEFORE the first commit)
Delete without asking (confirm only if a path is unexpectedly missing/modified):
- `.claude-template/` and `.claude-template-tmp/` staging dirs (EXISTING mode), `setup.ps1`, `setup.sh`, `scripts/`,
  `.claude/install-manifest.md`, `.claude/licenses/` (after LICENSE written),
  `.github/workflows/template-validate.yml` (template self-CI, not for projects),
  `.claude/skills/example-skill/`, and this skill (`.claude/skills/project-onboarding/` — delete LAST),
  plus any `*.fromtemplate`/`*.template`/backup files.
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
