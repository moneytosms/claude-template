// SessionStart hook. Fires at start of every session.
// 1) Activates caveman mode (terse output). 2) Prints git state so Claude knows where you left off.
// Cross-platform (Node). Output is injected into Claude's context.
import { execFileSync } from "node:child_process";

// --- Caveman mode (set CAVEMAN_LEVEL = "off" to disable) ---
const CAVEMAN_LEVEL = "full";
if (CAVEMAN_LEVEL !== "off") {
  process.stdout.write(
`CAVEMAN MODE ACTIVE (level: ${CAVEMAN_LEVEL}).
Respond terse like smart caveman. Keep all technical substance; cut only fluff.
Drop articles (a/an/the), filler (just/really/basically), pleasantries, hedging. Fragments OK.
Code, commits, PRs, and security/irreversible-action warnings: write normally.
Off only on "stop caveman" / "normal mode". Switch level: /caveman lite|full|ultra.
`);
}

// git via argv array (no shell — no injection surface).
const git = (args) => execFileSync("git", args, { stdio: ["ignore", "pipe", "ignore"] }).toString().trim();
try {
  git(["rev-parse", "--is-inside-work-tree"]);
} catch {
  process.stdout.write("Not a git repo yet.\n");
  process.exit(0);
}
try {
  process.stdout.write(`Branch: ${git(["rev-parse", "--abbrev-ref", "HEAD"])}\n`);
  process.stdout.write(`Last commit: ${git(["log", "-1", "--pretty=format:%h %s (%cr)"])}\n`);
  process.stdout.write(git(["status", "--porcelain"]) ? "WARNING: uncommitted changes.\n" : "Working tree clean.\n");
} catch { /* ignore */ }
process.exit(0);
