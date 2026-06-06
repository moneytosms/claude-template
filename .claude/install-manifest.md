# Install manifest

Default tooling the `/project-onboarding` skill installs. Edit before sharing the template
to change every future project's baseline. Onboarding runs these, verifies each, and reports.

## MCP servers
| Name | How | Notes |
|------|-----|-------|
| context7 | already in `.mcp.json` (`npx -y @upstash/context7-mcp@latest`) | Live library docs. No key. Default. |
| chrome-devtools | OPT-IN — add `npx chrome-devtools-mcp@latest` to `.mcp.json` | Powers browser-testing skill (DOM/console/network/perf). Recommend for web. |
| github | OPT-IN — `npx -y @modelcontextprotocol/server-github` (needs `GITHUB_TOKEN`) | PR/issue/repo ops from chat. |

## Skills / plugins
| Name | Install command | Notes |
|------|-----------------|-------|
| graphify | copy `~/.claude/skills/graphify` → `.claude/skills/graphify` (or clone source) | Input → knowledge graph. `/graphify`. |
| Matt Pocock skills | `npx skills@latest add mattpocock/skills` | Interactive; select skills + run `/setup-matt-pocock-skills`. |
| Addy Osmani agent-skills | `/plugin marketplace add addyosmani/agent-skills` then `/plugin install agent-skills@addy-agent-skills` | 23 lifecycle skills. May already be installed globally. |
| caveman | already global; session-start hook activates `full` per project | `/caveman lite\|full\|ultra`. |

## CLIs ensured at onboarding (step 0)
| Tool | Purpose | Fallback |
|------|---------|----------|
| git, node, gh, pwsh | core | required |
| rg (ripgrep) | fast search | grep |
| fd | fast find | find |
| jq | JSON processing | — |
| bat | cat with highlighting | cat (Debian: batcat; setup aliases it) |
| just | task runner (justfile) | npm scripts / make |
| uv | fast Python pkg/venv mgr | pip + venv |
| gitleaks (opt-in) | secret-scan pre-commit (`.githooks/pre-commit`) | install only if user enables secret scanning |
| rtk (Rust Token Killer) | cuts cmd-output tokens 60-90%. github.com/rtk-ai/rtk. **Install** then **`rtk init -g`** (installs the PreToolUse Bash hook + RTK.md → auto-rewrites `git status`→`rtk git status` etc.; restart Claude after). Install per platform below. Verify: `rtk --version` + `rtk gain` (if `rtk gain` fails you got the wrong crate — use cargo --git). | run the command without rtk |

Policy: prefer objectively faster/better modern tools when available.

### rtk platform setup (one-time, machine-global)
| Platform | Install | Hook auto-rewrite |
|----------|---------|-------------------|
| macOS | `brew install rtk` | full (`rtk init -g`) |
| Linux / WSL | `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh \| sh` (adds `~/.local/bin`) | full (`rtk init -g`) |
| any (Rust) | `cargo install --git https://github.com/rtk-ai/rtk` | full |
| native Windows | download `rtk-x86_64-pc-windows-msvc.zip` from releases, put `rtk.exe` on PATH | **no auto-rewrite** — `rtk init -g` falls back to CLAUDE.md injection; call `rtk` explicitly (`rtk git status`, `rtk test ...`). WSL recommended for full hook. |

Notes: hook only intercepts **Bash** tool calls — Claude's Read/Grep/Glob bypass it, so use shell
(`cat`/`rg`) or explicit `rtk read`/`rtk grep` to get filtering there. Telemetry off by default.
CI/non-interactive: `rtk init -g --auto-patch`.

## Stack-specific (chosen during onboarding interview)
Onboarding picks linter/formatter/test tooling for the detected/declared stack and wires
them into the post-edit-format hook + the Commands table. Examples:
| Stack | Lint | Format | Test |
|-------|------|--------|------|
| Python | ruff check + pyrefly | ruff format | pytest |
| TS/JS | eslint | prettier | vitest/jest |
| Go | golangci-lint | gofmt | go test |
| Rust | clippy | rustfmt | cargo test |
