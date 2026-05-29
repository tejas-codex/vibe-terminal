#!/usr/bin/env bash
# One-line installer. After you push this repo PUBLIC, edit REPO below, then
# anyone can run:
#   curl -fsSL https://raw.githubusercontent.com/<you>/vibe-terminal/main/bootstrap.sh | bash
set -e
REPO="${VIBE_REPO:-https://github.com/tejas-codex/vibe-terminal.git}"
DEST="$HOME/dotfiles-vibe"

command -v git >/dev/null 2>&1 || { echo "Installing Xcode CLT (git)…"; xcode-select --install; echo "Re-run after it finishes."; exit 1; }
if [ -d "$DEST/.git" ]; then
  git -C "$DEST" pull --ff-only || true
else
  git clone "$REPO" "$DEST"
fi
cd "$DEST"
exec ./install.sh
