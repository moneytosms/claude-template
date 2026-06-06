# PostToolUse hook (matcher: Edit|Write). Auto-formats the file Claude just touched.
# Reads hook payload JSON from stdin to get the file path.
# Onboarding fills FORMAT_CMD for the project's stack
# (e.g. prettier, ruff format, gofmt, rustfmt, swift-format).

$ErrorActionPreference = "SilentlyContinue"

$raw = [Console]::In.ReadToEnd()
if (-not $raw) { exit 0 }
try { $payload = $raw | ConvertFrom-Json } catch { exit 0 }
$path = $payload.tool_input.file_path
if (-not $path -or -not (Test-Path $path)) { exit 0 }

# --- Set per project at onboarding. Leave empty to no-op. ---
# Example (JS/TS): npx --no-install prettier --write "$path"
# Example (Python): ruff format "$path"
$FORMAT_CMD = ""

if ($FORMAT_CMD) {
    Invoke-Expression ($FORMAT_CMD -replace '\$path', "`"$path`"") 2>$null | Out-Null
}
exit 0
