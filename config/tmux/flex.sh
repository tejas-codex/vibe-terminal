#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
#  flex — the SHOWCASE rice (mirrors the premium reference layout).
#  A "look at my terminal" flex: every pane a live TUI.
#
#   ┌────────────┬───────────────┬────────────┐
#   │ fastfetch  │    ticker     │  calendar  │   top  (38%)
#   │ About Mac  │   📈 stocks   │  + clock   │
#   ├────────────┴───────┬───────┴────────────┤
#   │      btop          │     newsboat       │   mid  (37%)
#   │   system monitor   │    📰 feeds        │
#   ├────────────────────┴────────────────────┤
#   │                 yazi                     │   bot  (25%)
#   │              file manager                │
#   └──────────────────────────────────────────┘
#
#  Launch:  flex   |   prefix + F   |   flex ~/some/dir
# ──────────────────────────────────────────────────────────────
set -u
DIR="${1:-$HOME}"
[ -d "$DIR" ] || DIR="$HOME"
S="flex"

# Already open? just jump to it — never rebuild over a live session.
if tmux has-session -t "$S" 2>/dev/null; then
  if [ -n "${TMUX:-}" ]; then exec tmux switch-client -t "$S"; else exec tmux attach -t "$S"; fi
fi

have() { command -v "$1" >/dev/null 2>&1; }

# ── pane commands (graceful fallback if a tool is missing) ────
SYS=$(have fastfetch && echo "fastfetch --logo-padding-top 1; exec \$SHELL" || echo "exec \$SHELL")

if have ticker; then
  TICK="ticker --config $HOME/.config/ticker/ticker.yaml"
else
  TICK="clear; printf '\n  \033[38;5;215m no ticker \033[0m\n  brew install achannarasappa/tap/ticker\n'; exec \$SHELL"
fi

# calendar + live clock widget (BSD cal highlights today in reverse video)
CAL='while :; do
  clear
  printf "\033[38;5;111m%s\033[0m\n" "$(date "+%A")"
  printf "\033[1;38;5;215m%s\033[0m  \033[38;5;150m%s\033[0m\n\n" "$(date "+%H:%M:%S")" "$(date "+%d %b %Y")"
  cal
  sleep 1
done'

MON=$(have btop && echo "btop" || echo "top")

if have newsboat; then
  NEWS="newsboat -r"
else
  NEWS="clear; printf '\n  \033[38;5;215m no newsboat \033[0m\n  brew install newsboat\n'; exec \$SHELL"
fi

FILES=$(have yazi && echo "yazi \"$DIR\"" || echo "ls -la; exec \$SHELL")

# ── build the grid ────────────────────────────────────────────
tmux new-session -d -s "$S" -n rice -c "$DIR" -x "$(tput cols 2>/dev/null || echo 200)" -y "$(tput lines 2>/dev/null || echo 50)"
TL=$(tmux display -p -t "$S:rice" '#{pane_id}')

# carve the bottom (yazi strip)
BOT=$(tmux split-window -v -l 25% -t "$TL" -c "$DIR" -P -F '#{pane_id}')
tmux send-keys -t "$BOT" "$FILES" C-m

# split the upper region into top row (fastfetch|ticker|cal) over mid row (btop|news)
MID=$(tmux split-window -v -l 50% -t "$TL" -c "$DIR" -P -F '#{pane_id}')   # TL=top, MID=mid

# top row: fastfetch | ticker | calendar
TM=$(tmux split-window -h -l 64% -t "$TL" -c "$DIR" -P -F '#{pane_id}')
TR=$(tmux split-window -h -l 44% -t "$TM" -c "$DIR" -P -F '#{pane_id}')
tmux send-keys -t "$TL" "$SYS"  C-m
tmux send-keys -t "$TM" "$TICK" C-m
tmux send-keys -t "$TR" "$CAL"  C-m

# mid row: btop | newsboat
MR=$(tmux split-window -h -l 42% -t "$MID" -c "$DIR" -P -F '#{pane_id}')
tmux send-keys -t "$MID" "$MON"  C-m
tmux send-keys -t "$MR"  "$NEWS" C-m

# focus the system info pane, no active-pane glow stealing the eye
tmux select-pane -t "$TL"
tmux set-option -t "$S" status off          # full-bleed rice, no status bar clutter

if [ -n "${TMUX:-}" ]; then exec tmux switch-client -t "$S"; else exec tmux attach -t "$S"; fi
