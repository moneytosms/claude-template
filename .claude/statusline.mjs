// Status line. Claude pipes a JSON blob on stdin; print one line for the prompt.
// Shows: dir | git branch | model | session cost | lines changed | context flag. Cross-platform (Node).
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
if (j.cost?.total_cost_usd != null) parts.push(`$${Number(j.cost.total_cost_usd).toFixed(2)}`);
if (j.cost?.total_lines_added != null || j.cost?.total_lines_removed != null) {
  parts.push(`+${j.cost.total_lines_added | 0}/-${j.cost.total_lines_removed | 0}`);
}
if (j.exceeds_200k_tokens === true) parts.push("ctx⚠");

process.stdout.write(parts.join("  |  "));
