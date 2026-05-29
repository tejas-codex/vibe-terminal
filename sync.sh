#!/usr/bin/env bash
# Pull your CURRENT live configs back into this repo (run before git commit).
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"; C="$DIR/config"
mkdir -p "$C/tmux" "$C/claude/hooks"
cp ~/.config/ghostty/config        "$C/ghostty.config"
cp ~/.tmux.conf                    "$C/tmux.conf"
cp ~/.config/starship.toml         "$C/starship.toml"
cp ~/.config/sesh/sesh.toml        "$C/sesh.toml"
cp ~/.config/btop/btop.conf        "$C/btop.conf"
cp ~/.config/tmux/*.sh ~/.config/tmux/*.md "$C/tmux/"
cp ~/.claude/themes/vibe-dark.json "$C/claude/vibe-dark.json"
cp ~/.claude/hooks/notify-done.sh ~/.claude/hooks/focus-session.sh "$C/claude/hooks/"
if [ -f ~/.config/vibe.zsh ]; then cp ~/.config/vibe.zsh "$C/vibe.zsh"
else awk 'f{print} /export JCODE_OPENROUTER_ALLOW_NO_AUTH=0/{f=1}' ~/.zshrc > "$C/vibe.zsh"; fi
echo "synced live configs → repo. Now: git add -A && git commit && git push"
