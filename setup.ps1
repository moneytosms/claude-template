#!/usr/bin/env pwsh
# claude-template bootstrap (Windows / PowerShell 7). Fully automatic.
# Flags:
#   -Yes      skip the confirm prompt (unattended)
#   -DryRun   show what would happen; install nothing, delete nothing, don't launch Claude
# Steps: install CLIs + rtk + rtk init -> remove template git -> launch Claude /project-onboarding.
param([switch]$Yes, [switch]$DryRun)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
Set-Location $root

Write-Host "claude-template setup" -ForegroundColor Cyan
Write-Host "Dir: $root"

# Idiot-proof guards.
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "Run this with PowerShell 7 (pwsh), not Windows PowerShell 5." -ForegroundColor Yellow
}
if (-not (Test-Path "$root/.claude/skills/project-onboarding/SKILL.md")) {
    Write-Error "Doesn't look like claude-template (onboarding skill missing). Aborting."
    exit 1
}

if (-not $Yes -and -not $DryRun) {
    $confirm = Read-Host "Install tooling, strip template git history, and start onboarding here? (y/N)"
    if ($confirm -ne "y") { Write-Host "Aborted."; exit 0 }
}

# 1) Auto-install all CLIs + rtk (idempotent).
if ($DryRun) { & "$root/scripts/install-tools.ps1" -DryRun }
else         { & "$root/scripts/install-tools.ps1" }

if ($DryRun) {
    Write-Host "`n[dry-run] would remove $root/.git and launch Claude /project-onboarding." -ForegroundColor Yellow
    exit 0
}

# 2) Remove template's own git history so this becomes a fresh project.
if (Test-Path "$root/.git") {
    Remove-Item -Recurse -Force "$root/.git"
    Write-Host "Removed template .git" -ForegroundColor Green
}

# 3) Launch Claude to drive the project-specific onboarding.
$kickoff = "Run the /project-onboarding skill now. CLIs and rtk are already installed by setup; verify them, then do the interview + project customization + git init + cleanup."
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "Starting Claude onboarding..." -ForegroundColor Cyan
    & claude $kickoff
} else {
    Write-Host "Claude CLI not found on PATH (open a new terminal if just installed)." -ForegroundColor Yellow
    Write-Host "Then open this folder in Claude Code and run: /project-onboarding"
}
