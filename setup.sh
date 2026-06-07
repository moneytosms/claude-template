#!/usr/bin/env sh
# claude-template bootstrap (macOS / Linux / WSL / git-bash). Fully automatic. New OR existing projects.
# Flags:
#   --yes / -y       skip the confirm prompt (unattended)
#   --dry-run        show what would happen; install nothing, delete nothing, don't launch Claude
#   --into <path>    apply to an EXISTING project at <path> (merge mode): stages template there,
#                    never touches that repo's .git. Omit for a NEW project (this clone becomes it).
set -e

YES=0; DRY=0; INTO=""
while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y) YES=1 ;;
    --dry-run) DRY=1 ;;
    --into) shift; INTO="${1:-}" ;;
    *) echo "unknown flag: $1"; exit 2 ;;
  esac
  shift
done

root="$(cd "$(dirname "$0")" && pwd)"
cd "$root"
echo "claude-template setup"

if [ ! -f "$root/.claude/skills/project-onboarding/SKILL.md" ]; then
  echo "Doesn't look like claude-template (onboarding skill missing). Aborting." >&2
  exit 1
fi

if [ -n "$INTO" ]; then
  [ -d "$INTO" ] || { echo "--into path not found: $INTO" >&2; exit 1; }
  target="$(cd "$INTO" && pwd)"; EXISTING=1
  echo "Mode: EXISTING project -> $target"
else
  target="$root"; EXISTING=0
  echo "Mode: NEW project -> $target"
fi

if [ "$YES" -eq 0 ] && [ "$DRY" -eq 0 ]; then
  if [ "$EXISTING" -eq 1 ]; then
    printf "Install tooling and add Claude config into '%s' (keeps its git history)? (y/N) " "$target"
  else
    printf "Install tooling, strip template git history, and start onboarding here? (y/N) "
  fi
  read -r confirm; [ "$confirm" = "y" ] || { echo "Aborted."; exit 0; }
fi

# 1) Auto-install CLIs + rtk (idempotent).
if [ "$DRY" -eq 1 ]; then sh "$root/scripts/install-tools.sh" --dry-run; else sh "$root/scripts/install-tools.sh"; fi
export PATH="$HOME/.local/bin:$PATH"

if [ "$DRY" -eq 1 ]; then
  if [ "$EXISTING" -eq 1 ]; then echo "" && echo "[dry-run] would stage template into $target/.claude-template and launch Claude there."
  else echo "" && echo "[dry-run] would remove $root/.git and launch Claude /project-onboarding."; fi
  exit 0
fi

if [ "$EXISTING" -eq 1 ]; then
  stage="$target/.claude-template"
  rm -rf "$stage"; mkdir -p "$stage"
  # copy template contents (incl dotfiles) except its .git
  ( cd "$root" && tar --exclude='./.git' -cf - . ) | ( cd "$stage" && tar -xf - )
  rm -rf "$stage/.git"
  echo "Staged template -> $stage"
  cd "$target"
else
  [ -d "$root/.git" ] && { rm -rf "$root/.git"; echo "Removed template .git"; }
fi

if [ "$EXISTING" -eq 1 ]; then
  kickoff="Run /project-onboarding now in EXISTING-project mode. Template staged at ./.claude-template; CLIs+rtk installed. Merge config into this repo without clobbering anything, verify, then delete ./.claude-template and all template traces. Keep this repo's git history."
else
  kickoff="Run /project-onboarding now. CLIs and rtk are installed; verify them, then interview + customize + git init + cleanup."
fi
if command -v claude >/dev/null 2>&1; then
  echo "Starting Claude onboarding..."
  claude "$kickoff"
else
  echo "Claude CLI not found on PATH (open a new shell if just installed)."
  echo "Then open the project in Claude Code and run: /project-onboarding"
fi
