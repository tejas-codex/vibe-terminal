#!/usr/bin/env bash
# Vibe terminal — one-command setup on a fresh macOS machine.
#   git clone <repo> ~/dotfiles-vibe && cd ~/dotfiles-vibe && ./install.sh
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
C="$DIR/config"
say() { printf '\n\033[1;34m▶ %s\033[0m\n' "$*"; }
backup() { [ -e "$1" ] && cp "$1" "$1.bak-$(date +%s)" && echo "  backed up $1"; return 0; }

# 1) Homebrew
if ! command -v brew >/dev/null; then
  say "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# 2) All packages + fonts + Ghostty
say "Installing packages (Brewfile)"
brew bundle --file="$DIR/Brewfile"

# 3) tmux plugin manager + fzf-tab
say "Cloning plugins"
[ -d ~/.tmux/plugins/tpm ]      || git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
[ -d ~/.config/zsh/fzf-tab ]    || git clone --depth 1 https://github.com/Aloxaf/fzf-tab ~/.config/zsh/fzf-tab

# 4) Place config files
say "Installing configs"
mkdir -p ~/.config/ghostty ~/.config/sesh ~/.config/btop ~/.config/tmux ~/.claude/themes ~/.claude/hooks
backup ~/.config/ghostty/config; cp "$C/ghostty.config"     ~/.config/ghostty/config
backup ~/.tmux.conf;             cp "$C/tmux.conf"          ~/.tmux.conf
backup ~/.config/starship.toml;  cp "$C/starship.toml"      ~/.config/starship.toml
backup ~/.config/sesh/sesh.toml; cp "$C/sesh.toml"          ~/.config/sesh/sesh.toml
backup ~/.config/btop/btop.conf; cp "$C/btop.conf"          ~/.config/btop/btop.conf
cp "$C"/tmux/*.sh "$C"/tmux/*.md ~/.config/tmux/
cp "$C/vibe.zsh"                 ~/.config/vibe.zsh
cp "$C/claude/vibe-dark.json"    ~/.claude/themes/vibe-dark.json
cp "$C"/claude/hooks/*.sh        ~/.claude/hooks/
chmod +x ~/.config/tmux/*.sh ~/.claude/hooks/*.sh

# 5) Hook vibe.zsh into .zshrc (once)
if ! grep -q 'source ~/.config/vibe.zsh' ~/.zshrc 2>/dev/null; then
  say "Wiring vibe.zsh into .zshrc"
  printf '\n# vibe terminal\nsource ~/.config/vibe.zsh\n' >> ~/.zshrc
fi

# 6) Claude settings — theme + notification hooks (best-effort, backed up)
say "Configuring Claude Code (theme + notifications)"
S=~/.claude/settings.json
N='bash ~/.claude/hooks/notify-done.sh'
if [ -f "$S" ]; then
  backup "$S"
  jq --arg n "$N" '
    .theme = "custom:vibe-dark"
    | .hooks.Stop = ((.hooks.Stop // []))
    | .hooks.Notification = ((.hooks.Notification // []))
    | if ([.hooks.Stop[].hooks[]?.command] | any(. | test("notify-done"))) then .
      else .hooks.Stop += [{"hooks":[{"type":"command","command":($n+" \"Claude finished\"")}]}] end
    | if ([.hooks.Notification[].hooks[]?.command] | any(. | test("notify-done"))) then .
      else .hooks.Notification += [{"hooks":[{"type":"command","command":($n+" \"Claude needs your input\"")}]}] end
  ' "$S" > "$S.tmp" && mv "$S.tmp" "$S" && echo "  Claude settings updated"
else
  mkdir -p ~/.claude
  jq -n --arg n "$N" '{theme:"custom:vibe-dark", hooks:{
    Stop:[{hooks:[{type:"command",command:($n+" \"Claude finished\"")}]}],
    Notification:[{hooks:[{type:"command",command:($n+" \"Claude needs your input\"")}]}]}}' > "$S"
  echo "  created $S"
fi

# 7) tmux plugins (headless)
say "Installing tmux plugins"
tmux start-server 2>/dev/null || true
tmux new-session -d -s _setup 2>/dev/null || true
tmux source-file ~/.tmux.conf 2>/dev/null || true
~/.tmux/plugins/tpm/bin/install_plugins 2>/dev/null || true
tmux kill-session -t _setup 2>/dev/null || true

say "Done!  Launching Ghostty → you'll land in the dashboard."
open -a Ghostty 2>/dev/null || true
echo "  Cheat sheet inside tmux: prefix ? (Ctrl-b then ?)"
echo ""
echo "  ✨ Personalize it (pick one):"
echo "     • no-tools:    ~/dotfiles-vibe/customize.sh        (gum menus)"
echo "     • with Claude: cd ~/dotfiles-vibe && claude → /customize"
echo "     theme · transparency · dashboard · notifications · font"
