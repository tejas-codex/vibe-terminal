#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
#  theme — flip macOS between Dark and Light.
#  Ghostty (theme = light:..,dark:..) follows the system appearance
#  LIVE, so the terminal recolors instantly — no reload needed.
#  Bound to: `theme` alias  +  tmux prefix + i
# ──────────────────────────────────────────────────────────────
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode' 2>/dev/null
now=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
[ "$now" = "Dark" ] && mode="dark · TokyoNight Night" || mode="light · Catppuccin Latte"
printf '  \033[38;5;111m●\033[0m now: %s\n' "$mode"
