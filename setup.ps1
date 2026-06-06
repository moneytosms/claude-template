#!/usr/bin/env pwsh
# claude-template bootstrap (Windows / PowerShell 7). Fully automatic. New OR existing projects.
# Flags:
#   -Yes            skip the confirm prompt (unattended)
#   -DryRun         show what would happen; install nothing, delete nothing, don't launch Claude
#   -Into <path>    apply to an EXISTING project at <path> (merge mode): stages the template there,
#                   never touches that repo's .git. Omit for a NEW project (this clone becomes it).
# Steps: install CLIs + rtk + rtk init -> (new: drop template git) -> launch Claude /project-onboarding.
param([switch]$Yes, [switch]$DryRun, [string]$Into = "")

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
Set-Location $root

Write-Host "claude-template setup" -ForegroundColor Cyan
if (-not (Test-Path "$root/.claude/skills/project-onboarding/SKILL.md")) {
    Write-Error "Doesn't look like claude-template (onboarding skill missing). Aborting."
    exit 1
}

$existing = [bool]$Into
if ($existing) {
    if (-not (Test-Path $Into)) { Write-Error "-Into path not found: $Into"; exit 1 }
    $target = (Resolve-Path $Into).Path
    Write-Host "Mode: EXISTING project -> $target"
} else {
    $target = $root
    Write-Host "Mode: NEW project -> $target"
}

if (-not $Yes -and -not $DryRun) {
    $msg = if ($existing) { "Install tooling and add Claude config into '$target' (keeps its git history)? (y/N)" }
           else { "Install tooling, strip template git history, and start onboarding here? (y/N)" }
    if ((Read-Host $msg) -ne "y") { Write-Host "Aborted."; exit 0 }
}

# 1) Auto-install CLIs + rtk (idempotent).
if ($DryRun) { & "$root/scripts/install-tools.ps1" -DryRun } else { & "$root/scripts/install-tools.ps1" }

if ($DryRun) {
    if ($existing) { Write-Host "`n[dry-run] would stage template into $target/.claude-template and launch Claude there." -ForegroundColor Yellow }
    else { Write-Host "`n[dry-run] would remove $root/.git and launch Claude /project-onboarding." -ForegroundColor Yellow }
    exit 0
}

if ($existing) {
    # Stage the whole template (minus its .git) into the existing repo; onboarding merges then deletes it.
    $stage = Join-Path $target ".claude-template"
    if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
    New-Item -ItemType Directory -Force $stage | Out-Null
    Copy-Item -Recurse -Force -Path (Join-Path $root '*') -Destination $stage
    if (Test-Path (Join-Path $stage ".git")) { Remove-Item -Recurse -Force (Join-Path $stage ".git") }
    Write-Host "Staged template -> $stage" -ForegroundColor Green
    Set-Location $target
} else {
    # New project: drop the template's own git history.
    if (Test-Path "$root/.git") { Remove-Item -Recurse -Force "$root/.git"; Write-Host "Removed template .git" -ForegroundColor Green }
}

# 3) Launch Claude to drive onboarding.
$kickoff = if ($existing) {
    "Run /project-onboarding now in EXISTING-project mode. Template staged at ./.claude-template; CLIs+rtk installed. Merge config into this repo without clobbering anything, verify, then delete ./.claude-template and all template traces. Keep this repo's git history."
} else {
    "Run /project-onboarding now. CLIs and rtk are installed; verify them, then interview + customize + git init + cleanup."
}
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "Starting Claude onboarding..." -ForegroundColor Cyan
    & claude $kickoff
} else {
    Write-Host "Claude CLI not found on PATH (open a new terminal if just installed)." -ForegroundColor Yellow
    Write-Host "Then open the project in Claude Code and run: /project-onboarding"
}
