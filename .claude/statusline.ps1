# Status line. Claude pipes a JSON blob on stdin; print one line for the prompt.
# Shows: dir | git branch | model | session cost | lines changed. Customize freely.

$ErrorActionPreference = "SilentlyContinue"
$raw = [Console]::In.ReadToEnd()
try { $j = $raw | ConvertFrom-Json } catch { $j = $null }

$dir = if ($j.workspace.current_dir) { Split-Path $j.workspace.current_dir -Leaf } else { Split-Path (Get-Location) -Leaf }
$model = $j.model.display_name
$branch = (git rev-parse --abbrev-ref HEAD 2>$null)

$parts = @($dir)
if ($branch) { $parts += "⎇ $branch" }
if ($model)  { $parts += $model }

# Session cost (if provided by the harness).
if ($null -ne $j.cost.total_cost_usd) {
    $parts += ('${0:N2}' -f [double]$j.cost.total_cost_usd)
}
# Lines changed this session.
$add = $j.cost.total_lines_added; $del = $j.cost.total_lines_removed
if ($null -ne $add -or $null -ne $del) {
    $parts += ("+{0}/-{1}" -f ([int]$add), ([int]$del))
}
# Context pressure flag if the harness signals it.
if ($j.exceeds_200k_tokens -eq $true) { $parts += "ctx⚠" }

Write-Output ($parts -join "  |  ")
