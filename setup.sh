#!/usr/bin/env sh
# claude-template bootstrap (macOS / Linux / WSL / git-bash). Fully automatic.
# Flags:
#   --yes      skip the confirm prompt (unattended)
#   --dry-run  show what would happen; install nothing, delete nothing, don't launch Claude
# Steps: install CLIs + rtk + rtk init -> remove template git -> launch Claude /project-onboarding.
set -e

YES=0; DRY=0
for a in "$@"; do
  case "$a" in
    --yes|-y) YES=1 ;;
    --dry-run) DRY=1 ;;
    *) echo "unknown flag: $a"; exit 2 ;;
  esac
done

root="$(cd "$(dirname "$0")" && pwd)"
cd "$root"

echo "claude-template setup"
echo "Dir: $root"

if [ ! -f "$root/.claude/skills/project-onboarding/SKILL.md" ]; then
  echo "Doesn't look like claude-template (onboarding skill missing). Aborting." >&2
  exit 1
fi

if [ "$YES" -eq 0 ] && [ "$DRY" -eq 0 ]; then
  printf "Install tooling, strip template git history, and start onboarding here? (y/N) "
  read confirm
  [ "$confirm" = "y" ] || { echo "Aborted."; exit 0; }
fi

# 1) Auto-install all CLIs + rtk (idempotent).
if [ "$DRY" -eq 1 ]; then sh "$root/scripts/install-tools.sh" --dry-run
else sh "$root/scripts/install-tools.sh"; fi
export PATH="$HOME/.local/bin:$PATH"

if [ "$DRY" -eq 1 ]; then
  echo ""
  echo "[dry-run] would remove $root/.git and launch Claude /project-onboarding."
  exit 0
fi

# 2) Remove template's own git history so this becomes a fresh project.
if [ -d "$root/.git" ]; then rm -rf "$root/.git"; echo "Removed template .git"; fi

# 3) Launch Claude to drive the project-specific onboarding.
kickoff="Run the /project-onboarding skill now. CLIs and rtk are already installed by setup; verify them, then do the interview + project customization + git init + cleanup."
if command -v claude >/dev/null 2>&1; then
  echo "Starting Claude onboarding..."
  claude "$kickoff"
else
  echo "Claude CLI not found on PATH (open a new shell if just installed)."
  echo "Then open this folder in Claude Code and run: /project-onboarding"
fi
