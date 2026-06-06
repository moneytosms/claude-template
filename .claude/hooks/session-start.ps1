# SessionStart hook. Fires at start of every session.
# 1) Activates caveman mode (terse output) at level "full".
# 2) Prints git state so Claude knows where you left off.
# Output is injected into Claude's context.

$ErrorActionPreference = "SilentlyContinue"

# --- Caveman mode (edit CAVEMAN_LEVEL or set "off" to disable) ---
$CAVEMAN_LEVEL = "full"
if ($CAVEMAN_LEVEL -ne "off") {
@"
CAVEMAN MODE ACTIVE (level: $CAVEMAN_LEVEL).
Respond terse like smart caveman. Keep all technical substance; cut only fluff.
Drop articles (a/an/the), filler (just/really/basically), pleasantries, hedging. Fragments OK.
Code, commits, PRs, and security/irreversible-action warnings: write normally.
Off only on "stop caveman" / "normal mode". Switch level: /caveman lite|full|ultra.
"@ | Write-Output
}

# --- Git state ---
git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Output "Not a git repo yet."
    exit 0
}
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
$last   = (git log -1 --pretty=format:"%h %s (%cr)").Trim()
$dirty  = (git status --porcelain)
Write-Output "Branch: $branch"
Write-Output "Last commit: $last"
if ($dirty) { Write-Output "WARNING: uncommitted changes." } else { Write-Output "Working tree clean." }
exit 0
