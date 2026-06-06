// PostToolUse hook (matcher: Edit|Write). Auto-formats the file Claude just touched.
// Reads hook payload JSON from stdin to get the file path.
// Onboarding sets FORMAT_CMD as an ARGV ARRAY for the project's stack. The path is appended as a
// separate argument and run with NO shell (execFileSync) — shell metacharacters in paths are inert.
import { execFileSync } from "node:child_process";
import { existsSync } from "node:fs";
import { readStdin, parse } from "./_stdin.mjs";

// --- Set per project at onboarding. Empty = no-op. Examples: ---
//   ["npx","--no-install","prettier","--write"]   (JS/TS)
//   ["ruff","format"]                              (Python)
const FORMAT_CMD = [];

const payload = parse(await readStdin());
const path = payload?.tool_input?.file_path;
if (FORMAT_CMD.length && path && existsSync(path)) {
  try {
    execFileSync(FORMAT_CMD[0], [...FORMAT_CMD.slice(1), path], { stdio: "ignore" });
  } catch { /* never block on format failure */ }
}
process.exit(0);
