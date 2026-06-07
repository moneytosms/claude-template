---
description: Refresh the Claude baseline (hooks, agents, rules, commands, output-styles, status line) from the latest claude-template, without touching project content.
---

Pull the latest reusable config from claude-template into this project. Non-destructive to the user's
work: never edit project code, never overwrite CLAUDE.md content, never touch git history.

1. Clone the template to `.claude-template-tmp/`: `git clone https://github.com/moneytosms/claude-template .claude-template-tmp --depth 1`.
2. Diff the temp `.claude/` baseline against this project's, focusing on:
   - `.claude/hooks/`, `.claude/agents/`, `.claude/rules/`, `.claude/commands/`, `.claude/output-styles/`,
     `.claude/statusline.mjs`, and the non-permission parts of `.claude/settings.json`.
3. Show the user a concise summary of what changed upstream (added/modified files).
4. Apply ONLY accepted changes:
   - New files → copy in.
   - Modified files the user hasn't customized → update.
   - Files the user has customized → show a diff, ask before overwriting; offer to merge.
   - NEVER overwrite: `CLAUDE.md`, `CLAUDE.local.md`, `.env`, `settings.local.json`, project source.
5. Delete the temp clone: `rm -rf .claude-template-tmp`. Report what was updated and what was skipped.

Note: this updates the *baseline*; project-specific customizations stay intact.
