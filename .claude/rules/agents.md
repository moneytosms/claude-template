# Subagent model routing

Route spawned subagents to the cheapest model that can do the job. Keep the main session on the
default (Opus). Override per agent via the `model:` frontmatter field, or per spawn via the Agent
tool's `model` param.

| Work type | Model | Examples |
|-----------|-------|----------|
| Recon / parse / locate / fetch | `haiku` | log-analyzer, researcher, "find all uses of X", file mapping |
| Simple mechanical edits | `haiku` | renames, comment removal, format-preserving tweaks |
| Reasoning / judgement | `sonnet` | code-reviewer, debugger, planner, architecture |
| Hard, high-stakes synthesis | `opus` (or inherit) | only when sonnet is demonstrably insufficient |

Rules:
- Default a new agent to `haiku`; promote to `sonnet` only if it must reason about correctness.
- Never run recon/search on Opus.
- The `cavecrew` / `parallel-kernel` skills already follow this; prefer them for fan-out work.
