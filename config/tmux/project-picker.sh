#!/usr/bin/env bash
# Visual project launcher — NO cd, NO typing paths.
# Lists every project folder, fuzzy-pick one, land in its cockpit (Claude+git+files).
# Launch:  p   (shell)  |  tmux: prefix + p
set -u

ROOTS=("$HOME/Desktop" "$HOME/Projects" "$HOME/Developer" "$HOME/Code" "$HOME/repos")

# Candidate projects = git repos (depth 4) + anything you've visited (zoxide) + Desktop top dirs.
list_projects() {
  fd -t d -d 4 -H '^\.git$' "${ROOTS[@]}" 2>/dev/null | sed 's:/\.git/*$::'
  fd -t d -d 1 . "$HOME/Desktop" 2>/dev/null
  zoxide query -l 2>/dev/null
}

SEL=$(list_projects | sort -u | \
  fzf --reverse --border rounded --border-label ' 󱓞  pick a project ' \
      --prompt '  ' --height 80% \
      --preview 'eza -1 --icons --git --color=always {} 2>/dev/null | head -40' \
      --preview-window 'right,45%,border-left') || exit 0

[ -z "$SEL" ] && exit 0
NAME=$(basename "$SEL" | tr ' .' '__')
zoxide add "$SEL" 2>/dev/null     # remember it for `z`
exec ~/.config/tmux/dashboard.sh "$SEL" "$NAME"
