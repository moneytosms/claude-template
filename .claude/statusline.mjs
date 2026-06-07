// Status line. Claude pipes a JSON blob on stdin; print one line for the prompt.
// Shows: dir | git branch | model | context% | session rate-limit% | lines changed
import { execFileSync } from "node:child_process";
import { basename } from "node:path";
import { readStdin, parse } from "./hooks/_stdin.mjs";

const j = parse(await readStdin()) ?? {};
const dir = basename(j.workspace?.current_dir || process.cwd());

let branch = "";
try { branch = execFileSync("git", ["rev-parse", "--abbrev-ref", "HEAD"], { stdio: ["ignore", "pipe", "ignore"] }).toString().trim(); } catch { /* not a repo */ }

const parts = [dir];
if (branch) parts.push(`⎇ ${branch}`);
if (j.model?.display_name) parts.push(j.model.display_name);

// Context window usage
const ctxPct = j.context_window?.used_percentage;
const ctxTokens = j.context_window?.total_input_tokens;
const ctxMax = j.context_window?.context_window_size;
if (ctxPct != null) {
  const warn = ctxPct >= 75 ? "⚠" : "";
  parts.push(`ctx ${Math.round(ctxPct)}%${warn}`);
} else if (ctxTokens != null && ctxMax != null) {
  const pct = Math.round((ctxTokens / ctxMax) * 100);
  parts.push(`ctx ${pct}%`);
} else if (j.exceeds_200k_tokens === true) {
  parts.push("ctx⚠ >200k");
}

// Session rate-limit usage (Pro/Max only — absent for API key users)
const rl5h = j.rate_limits?.five_hour?.used_percentage;
const rl7d = j.rate_limits?.seven_day?.used_percentage;
if (rl5h != null) parts.push(`5h ${Math.round(rl5h)}%`);
if (rl7d != null) parts.push(`7d ${Math.round(rl7d)}%`);

// Lines changed
if (j.cost?.total_lines_added != null || j.cost?.total_lines_removed != null) {
  parts.push(`+${j.cost.total_lines_added | 0}/-${j.cost.total_lines_removed | 0}`);
}

process.stdout.write(parts.join("  |  "));
