#!/usr/bin/env pwsh
# Auto-installs all baseline CLIs (idempotent). Windows: winget. Run by setup.ps1.
# Flags: -DryRun (print actions, change nothing).
param([switch]$DryRun)
$ErrorActionPreference = "Continue"

$bin = Join-Path $HOME ".local\bin"

function Have($n) { [bool](Get-Command $n -ErrorAction SilentlyContinue) }

function Ensure-Tool($name, $wingetId) {
    if (Have $name) { Write-Host "[ok] $name"; return }
    if ($DryRun) { Write-Host "[dry-run] would install $name ($wingetId)"; return }
    if ($wingetId -and (Have winget)) {
        Write-Host "[install] $name ($wingetId)..."
        winget install --id $wingetId -e --silent --accept-package-agreements --accept-source-agreements | Out-Null
    } else {
        Write-Host "[skip] $name - winget or package id unavailable. Install manually."
    }
}

Write-Host "== Baseline CLIs ==" -ForegroundColor Cyan
if (-not (Have winget) -and -not $DryRun) {
    Write-Host "[warn] winget not found. Install 'App Installer' from the Microsoft Store, then re-run." -ForegroundColor Yellow
}

$tools = [ordered]@{
    git  = "Git.Git"; node = "OpenJS.NodeJS.LTS"; gh = "GitHub.cli"
    rg   = "BurntSushi.ripgrep.MSVC"; fd = "sharkdp.fd"; jq = "jqlang.jq"
    bat  = "sharkdp.bat"; uv = "astral-sh.uv"
}
foreach ($t in $tools.GetEnumerator()) { Ensure-Tool $t.Key $t.Value }

# rtk: no winget pkg -> download latest Windows release binary to ~/.local/bin.
if (-not (Have rtk)) {
    if ($DryRun) {
        Write-Host "[dry-run] would download rtk release zip -> $bin"
    } else {
        Write-Host "[install] rtk (release binary)..."
        New-Item -ItemType Directory -Force $bin | Out-Null
        $zip = Join-Path $env:TEMP "rtk.zip"
        try {
            Invoke-WebRequest -UseBasicParsing -Uri "https://github.com/rtk-ai/rtk/releases/latest/download/rtk-x86_64-pc-windows-msvc.zip" -OutFile $zip
            Expand-Archive -Force $zip $bin
            $env:PATH = "$bin;$env:PATH"
            $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
            if ($userPath -notlike "*$bin*") { [Environment]::SetEnvironmentVariable("PATH", "$bin;$userPath", "User") }
            Write-Host "[ok] rtk -> $bin"
        } catch { Write-Host "[skip] rtk download failed: $($_.Exception.Message)" -ForegroundColor Yellow }
    }
} else { Write-Host "[ok] rtk" }

# Wire rtk into Claude Code globally, non-interactive.
if ((Have rtk) -and -not $DryRun) {
    Write-Host "[rtk] init -g --auto-patch"
    rtk init -g --auto-patch | Out-Null
    Write-Host "  Note: native Windows has no auto-rewrite hook (CLAUDE.md injection fallback). WSL = full."
}

# --- Verification summary ---
Write-Host "`n== Verify ==" -ForegroundColor Cyan
$all = @("git","node","gh","rg","fd","jq","bat","uv","rtk")
$missing = @()
foreach ($t in $all) {
    if (Have $t) { Write-Host "  [OK] $t" -ForegroundColor Green }
    else { Write-Host "  [MISSING] $t" -ForegroundColor Red; $missing += $t }
}
if ($missing.Count -gt 0) {
    Write-Host "`nMissing: $($missing -join ', '). Re-run setup or install manually." -ForegroundColor Yellow
}
# PATH reload note.
if ((Test-Path $bin) -and ($env:PATH -notlike "*$bin*")) {
    Write-Host "`n[PATH] $bin was added to your USER PATH but THIS shell won't see it." -ForegroundColor Yellow
    Write-Host "       Open a NEW terminal, or run: `$env:PATH = `"$bin;`$env:PATH`"" -ForegroundColor Yellow
}
