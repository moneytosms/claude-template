// PreToolUse hook (matcher: Bash). Blocks deploys when tests fail.
// Inspects the Bash command about to run (regex only — never executes it). If it matches
// DEPLOY_PATTERN, runs TEST_CMD (argv array, no shell). Exit 2 = block the tool call.
import { execFileSync } from "node:child_process";
import { readStdin, parse } from "./_stdin.mjs";

// --- Set per project at onboarding. Empty pattern = guard disabled. ---
const DEPLOY_PATTERN = "";        // e.g. "deploy|--prod|npm run deploy"
const TEST_CMD = [];              // e.g. ["npm","test"]

const payload = parse(await readStdin());
const cmd = payload?.tool_input?.command ?? "";

if (!DEPLOY_PATTERN || !TEST_CMD.length || !new RegExp(DEPLOY_PATTERN).test(cmd)) {
  process.exit(0);
}

process.stderr.write("pre-deploy-guard: deploy detected, running tests...\n");
try {
  execFileSync(TEST_CMD[0], TEST_CMD.slice(1), { stdio: "ignore" });
} catch {
  process.stderr.write("DEPLOY BLOCKED: tests failing. Fix before deploying.\n");
  process.exit(2);
}
process.stderr.write("pre-deploy-guard: tests green, deploy allowed.\n");
process.exit(0);
