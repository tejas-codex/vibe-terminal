#!/usr/bin/env bash
# Record a terminal demo → GIF → (optionally) commit to the repo.
# Run it, do your demo (dash, cc, prefix ?, ⌘D…), then press Ctrl-D / type `exit`.
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$DIR/assets"
CAST="$(mktemp -t vibedemo).cast"

command -v asciinema >/dev/null || brew install asciinema
command -v agg       >/dev/null || brew install agg

cat <<'TIP'

  🎬  RECORDING starts now.
      Do a quick tour:  dash  ·  prefix ?  ·  cc  ·  ⌘D  ·  prefix b
      Keep it ~20–40s.  Press  Ctrl-D  (or type `exit`) to STOP.

TIP
read -r "?Press Enter to start…" _ 2>/dev/null || read -r _

asciinema rec --overwrite --idle-time-limit 2 "$CAST"

echo "  Converting to GIF (TokyoNight, Nerd Font)…"
agg \
  --font-family "JetBrainsMono Nerd Font" \
  --theme "1a1b26,c0caf5,15161e,f7768e,9ece6a,e0af68,7aa2f7,bb9af7,7dcfff,a9b1d6,414868,f7768e,9ece6a,e0af68,7aa2f7,bb9af7,7dcfff,c0caf5" \
  --speed 1.4 --fps-cap 24 \
  "$CAST" "$DIR/assets/demo.gif"
rm -f "$CAST"
echo "  ✅ GIF → $DIR/assets/demo.gif  ($(du -h "$DIR/assets/demo.gif" | cut -f1))"

# Embed in README once
if ! grep -q "assets/demo.gif" "$DIR/README.md"; then
  awk '1; /!\[Vibe Terminal\]\(assets\/hero.png\)/{print "\n![Demo](assets/demo.gif)"}' \
    "$DIR/README.md" > "$DIR/README.md.tmp" && mv "$DIR/README.md.tmp" "$DIR/README.md"
fi

printf "\n  Commit + push to GitHub? (y/N): "
read -r ans
if [[ "$ans" == y* || "$ans" == Y* ]]; then
  cd "$DIR"
  git add -A && git commit -m "add demo gif" && git push
  echo "  ✅ pushed — live at https://github.com/tejas-codex/vibe-terminal"
else
  echo "  Skipped. Commit later:  cd $DIR && git add -A && git commit -m 'demo' && git push"
fi
