#!/usr/bin/env bash
# Standalone personalizer (gum menus) — no Claude Code needed.
#   ~/dotfiles-vibe/customize.sh
set -uo pipefail
GH="$HOME/.config/ghostty/config"
THEME="$HOME/.claude/themes/vibe-dark.json"
command -v gum >/dev/null || brew install gum

gum style --border rounded --padding "1 3" --margin "1 0" --border-foreground 212 \
  "✨ Vibe Terminal — Customize" "pick what to change · space=select · enter=confirm"

PICKS=$(gum choose --no-limit --height 8 \
  "Transparency" "Ghostty theme" "Chat highlight color" "Font size" "Quit") || exit 0

setline() { sed -i '' "s|^$1 .*|$2|" "$GH"; }   # macOS sed

while IFS= read -r p; do case "$p" in
  "Transparency")
    op=$(gum choose --header "How see-through?" "0.75 glassy" "0.82" "0.90" "0.95" "1.0 solid")
    [ -n "${op:-}" ] && setline "background-opacity" "background-opacity      = ${op%% *}" && echo "→ opacity ${op%% *}" ;;
  "Ghostty theme")
    sel=$(ghostty +list-themes 2>/dev/null | sed 's/ (resources)//' | sort -u | gum filter --header "Pick a theme")
    [ -n "${sel:-}" ] && setline "theme" "theme = $sel" && echo "→ theme $sel" ;;
  "Chat highlight color")
    c=$(gum choose --header "Highlight behind YOUR messages" \
        "Blue #2d3f76" "Purple #3a2d5c" "Orange #5a3a1e" "Teal #1f3a3a" "Subtle #283457")
    hex=$(printf '%s' "${c:-}" | grep -oE '#[0-9a-fA-F]{6}')
    if [ -n "$hex" ] && [ -f "$THEME" ]; then
      jq --arg c "$hex" '.overrides.userMessageBackground=$c' "$THEME" > "$THEME.tmp" && mv "$THEME.tmp" "$THEME"
      echo "→ highlight $hex"
    fi ;;
  "Font size")
    sz=$(gum input --placeholder "14" --header "Font size (number)")
    [[ "${sz:-}" =~ ^[0-9]+$ ]] && setline "font-size" "font-size               = $sz" && echo "→ font-size $sz" ;;
  "Quit") ;;
esac; done <<< "$PICKS"

if ghostty +validate-config >/dev/null 2>&1; then
  gum style --foreground 42 "✅ config valid — reload Ghostty:  ⌘⇧,"
else
  gum style --foreground 196 "⚠️ config error — run: ghostty +validate-config"
fi

if gum confirm "Save these tweaks to your repo (sync + commit + push)?"; then
  cd "$HOME/dotfiles-vibe" && ./sync.sh && git add -A && git commit -m "customize" && git push && gum style --foreground 42 "✅ pushed"
fi
