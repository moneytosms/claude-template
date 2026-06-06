#!/usr/bin/env sh
# Auto-installs all baseline CLIs (idempotent). macOS: brew. Linux/WSL: apt or dnf.
# Flags: --dry-run (print actions, change nothing).
set -u

DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

have() { command -v "$1" >/dev/null 2>&1; }
run()  { if [ "$DRY" -eq 1 ]; then echo "[dry-run] $*"; else eval "$*"; fi; }
ensure() { # ensure <cmd> <install-expr>
  if have "$1"; then echo "[ok] $1"; else echo "[install] $1"; run "$2"; fi
}

echo "== Baseline CLIs =="
OS="$(uname -s)"

if [ "$OS" = "Darwin" ]; then
  if ! have brew; then
    echo "[install] Homebrew"
    run '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  fi
  ensure git  "brew install git"
  ensure node "brew install node"
  ensure gh   "brew install gh"
  ensure rg   "brew install ripgrep"
  ensure fd   "brew install fd"
  ensure jq   "brew install jq"
  ensure bat  "brew install bat"
  ensure uv   "brew install uv"
  ensure rtk  "brew install rtk"
else
  # Linux / WSL
  SUDO=""; [ "$(id -u)" -ne 0 ] && SUDO="sudo"
  if have apt-get; then
    run "$SUDO apt-get update -y"
    P="$SUDO apt-get install -y"
    ensure git  "$P git"
    ensure node "$P nodejs npm"
    ensure gh   "$P gh"
    ensure rg   "$P ripgrep"
    ensure fd   "$P fd-find"
    ensure jq   "$P jq"
    ensure bat  "$P bat"
  elif have dnf; then
    P="$SUDO dnf install -y"
    ensure git  "$P git"
    ensure node "$P nodejs"
    ensure gh   "$P gh"
    ensure rg   "$P ripgrep"
    ensure fd   "$P fd-find"
    ensure jq   "$P jq"
    ensure bat  "$P bat"
  else
    echo "[warn] no apt-get/dnf found; install git node gh rg fd jq bat manually."
  fi
  ensure uv  "curl -LsSf https://astral.sh/uv/install.sh | sh"
  ensure rtk "curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh"
  export PATH="$HOME/.local/bin:$PATH"
fi

# Wire rtk into Claude Code globally, non-interactive.
if have rtk && [ "$DRY" -eq 0 ]; then
  echo "[rtk] init -g --auto-patch"
  rtk init -g --auto-patch >/dev/null 2>&1 || true
fi

# --- Verification summary ---
echo ""
echo "== Verify =="
MISSING=""
for t in git node gh rg fd jq bat uv rtk; do
  if have "$t"; then echo "  [OK] $t"; else echo "  [MISSING] $t"; MISSING="$MISSING $t"; fi
done
[ -n "$MISSING" ] && echo "" && echo "Missing:$MISSING. Re-run setup or install manually."

# PATH reload note.
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) if [ -d "$HOME/.local/bin" ]; then
       echo ""
       echo "[PATH] add ~/.local/bin to PATH (new shell or run):"
       echo '       export PATH="$HOME/.local/bin:$PATH"'
     fi ;;
esac
