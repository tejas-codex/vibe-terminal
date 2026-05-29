#!/usr/bin/env bash
# Vibe-coder cockpit — AI-first. Land in Claude, git + files + system on the side.
#   ┌──────────────────────────┬──────────────┐
#   │                          │  lazygit     │  what changed
#   │   CLAUDE   (main, big)    ├──────────────┤
#   │   auto-starts claude      │  yazi        │  files
#   │                          ├──────────────┤
#   │                          │  fastfetch   │  About This Mac
#   └──────────────────────────┴──────────────┘
#   (live system monitor btop = prefix b popup)
# Launch:  dash   |   tmux: prefix + D   |   sesh: "dashboard"
# Open in a project:  dash ~/Desktop/my-project
set -u
DIR="${1:-$HOME}"
S="${2:-dashboard}"

if tmux has-session -t "$S" 2>/dev/null; then
  if [ -n "${TMUX:-}" ]; then exec tmux switch-client -t "$S"; else exec tmux attach -t "$S"; fi
fi

have() { command -v "$1" >/dev/null 2>&1; }
GIT=$(have lazygit && echo lazygit || echo "git status -s; exec \$SHELL")
FILES=$(have yazi && echo yazi || echo "exec \$SHELL")
# animated gradient banner + fastfetch, then drops to a shell (stays on screen)
SYS="$HOME/.config/tmux/banner.sh; exec \$SHELL"
AI=$(have claude && echo claude || echo "exec \$SHELL")

tmux new-session -d -s "$S" -n vibe -c "$DIR"
MAIN=$(tmux display -p -t "$S:vibe" '#{pane_id}')

# right column (28% wide): lazygit on top
RCOL=$(tmux split-window -h -l 30% -t "$MAIN" -c "$DIR" -P -F '#{pane_id}')
tmux send-keys -t "$RCOL" "$GIT" C-m
# files in the middle
FCOL=$(tmux split-window -v -l 62% -t "$RCOL" -c "$DIR" -P -F '#{pane_id}')
tmux send-keys -t "$FCOL" "$FILES" C-m
# fastfetch "About This Mac" at the bottom of the right column
MCOL=$(tmux split-window -v -l 42% -t "$FCOL" -c "$DIR" -P -F '#{pane_id}')
tmux send-keys -t "$MCOL" "$SYS" C-m

# main pane = Claude, ready to vibe
tmux select-pane -t "$MAIN"
tmux send-keys -t "$MAIN" "clear; $AI" C-m

if [ -n "${TMUX:-}" ]; then exec tmux switch-client -t "$S"; else exec tmux attach -t "$S"; fi
