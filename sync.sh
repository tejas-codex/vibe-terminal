#!/usr/bin/env bash
# Pull your CURRENT live configs back into this repo (run before git commit).
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"; C="$DIR/config"
mkdir -p "$C/tmux" "$C/claude/hooks" "$C/ghostty" "$C/ghostty/themes" "$C/ticker" "$C/newsboat" "$C/btop/themes" "$C/fastfetch"
cp ~/.config/ghostty/config        "$C/ghostty.config"
cp ~/.config/ghostty/toggle-appearance.sh "$C/ghostty/toggle-appearance.sh"
cp ~/.config/ghostty/themes/*      "$C/ghostty/themes/" 2>/dev/null || true
cp ~/.tmux.conf                    "$C/tmux.conf"
cp ~/.config/starship.toml         "$C/starship.toml"
cp ~/.config/sesh/sesh.toml        "$C/sesh.toml"
cp ~/.config/fastfetch/config.jsonc "$C/fastfetch/config.jsonc" 2>/dev/null || true
cp ~/.config/btop/btop.conf        "$C/btop.conf"
cp ~/.config/btop/themes/*.theme   "$C/btop/themes/" 2>/dev/null || true
cp ~/.config/tmux/*.sh ~/.config/tmux/*.md "$C/tmux/"
cp ~/.config/ticker/ticker.yaml    "$C/ticker/ticker.yaml"
cp ~/.newsboat/config              "$C/newsboat/config"
cp ~/.newsboat/urls                "$C/newsboat/urls"
cp ~/.claude/themes/vibe-dark.json "$C/claude/vibe-dark.json"
cp ~/.claude/hooks/notify-done.sh ~/.claude/hooks/focus-session.sh "$C/claude/hooks/"
if [ -f ~/.config/vibe.zsh ]; then cp ~/.config/vibe.zsh "$C/vibe.zsh"
else awk 'f{print} /export JCODE_OPENROUTER_ALLOW_NO_AUTH=0/{f=1}' ~/.zshrc > "$C/vibe.zsh"; fi
echo "synced live configs → repo. Now: git add -A && git commit && git push"
