# PreToolUse hook (matcher: Bash). Blocks deploys when tests fail.
# Inspects the Bash command about to run. If it matches DEPLOY_PATTERN, runs TEST_CMD first.
# Exit code 2 = block the tool call (Claude sees the reason and stops).
# Onboarding fills DEPLOY_PATTERN + TEST_CMD per project.

$ErrorActionPreference = "SilentlyContinue"

$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }
try { $payload = $raw | ConvertFrom-Json } catch { exit 0 }
$cmd = "$($payload.tool_input.command)"
if (-not $cmd) { exit 0 }

# --- Set per project at onboarding. Empty pattern = guard disabled. ---
$DEPLOY_PATTERN = ""   # e.g. 'deploy|--prod|npm run deploy'
$TEST_CMD       = ""   # e.g. 'npm test'

if (-not $DEPLOY_PATTERN -or $cmd -notmatch $DEPLOY_PATTERN) { exit 0 }
if (-not $TEST_CMD) { exit 0 }

Write-Error "pre-deploy-guard: deploy detected, running tests..."
Invoke-Expression $TEST_CMD 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Error "DEPLOY BLOCKED: tests failing. Fix before deploying."
    exit 2
}
Write-Error "pre-deploy-guard: tests green, deploy allowed."
exit 0
