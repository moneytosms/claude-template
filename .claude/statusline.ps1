# Status line. Claude pipes a JSON blob on stdin; print one line for the prompt.
# Shows: dir | git branch | model. Customize freely.

$ErrorActionPreference = "SilentlyContinue"
$raw = [Console]::In.ReadToEnd()
try { $j = $raw | ConvertFrom-Json } catch { $j = $null }

$dir = if ($j.workspace.current_dir) { Split-Path $j.workspace.current_dir -Leaf } else { Split-Path (Get-Location) -Leaf }
$model = $j.model.display_name
$branch = (git rev-parse --abbrev-ref HEAD 2>$null)

$parts = @($dir)
if ($branch) { $parts += "⎇ $branch" }
if ($model)  { $parts += $model }
Write-Output ($parts -join "  |  ")
