# Stop hook. Fires when Claude finishes a turn. Pings so you can look away and come back.
# Cross-platform: beep where supported, always print a marker.

$ErrorActionPreference = "SilentlyContinue"
try { [Console]::Beep(880, 150) } catch { }
Write-Output "✅ Claude finished."
exit 0
