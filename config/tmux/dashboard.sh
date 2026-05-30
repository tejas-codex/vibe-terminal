#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
#  dash — premium WORK cockpit. Claude-first, scoped to a folder.
#   ┌──────────────────────────┬──────────────┐
#   │                          │  ◆ sessions  │  ← fzf Claude session picker
#   │   ◆ CLAUDE  (main, 70%)  ├──────────────┤
#   │     auto-starts claude   │  ◆ files     │  ← yazi
#   ├──────────────────────────┴──────────────┤
#   │         ◆ system  (btop, full width)    │  ← full width → no "too small"
#   └─────────────────────────────────────────┘
#   Titled pane borders + solid dark = the premium read.
#   Launch:  dash  |  ⌘N  |  dash ~/Desktop/my-project
# ──────────────────────────────────────────────────────────────
set -u
DIR="${1:-$PWD}"
[ -d "$DIR" ] || DIR="$HOME"
NAME=$(basename "$DIR" | tr ' .' '__')

# Session naming:
#  - Called FROM inside tmux (e.g. `dash` alias) → reuse/jump to existing session.
#  - Called by new Ghostty window (zshrc guard, no $TMUX) → always create a NEW
#    independent session so two windows never mirror each other.
if [ -n "${TMUX:-}" ]; then
  S="${2:-dash_$NAME}"
  if tmux has-session -t "$S" 2>/dev/null; then
    exec tmux switch-client -t "$S"
  fi
else
  BASE="dash_$NAME"
  S="$BASE"
  n=1
  while tmux has-session -t "$S" 2>/dev/null; do
    n=$((n + 1))
    S="${BASE}_${n}"
  done
fi

have() { command -v "$1" >/dev/null 2>&1; }

SESSIONS="$HOME/.config/tmux/claude-sessions.sh"
FILES=$(have yazi && echo "yazi \"$DIR\"" || echo "exec \$SHELL")
SYS=$(have btop && echo "btop" || echo "$HOME/.config/tmux/banner.sh; exec \$SHELL")
AI=$(have claude && echo claude || echo "exec \$SHELL")

tmux new-session -d -s "$S" -n vibe -c "$DIR"

# ── premium pane borders — cyan active, dim inactive, titled ──
tmux set-option -t "$S" pane-border-status top
tmux set-option -t "$S" pane-border-lines heavy
tmux set-option -t "$S" pane-border-format " #[fg=#56b6c2,bold]#{?pane_active,◆ ,  }#{pane_title}#[default] "
tmux set-option -t "$S" pane-border-style "fg=#2e2d4a"
tmux set-option -t "$S" pane-active-border-style "fg=#56b6c2"

MAIN=$(tmux display -p -t "$S:vibe" '#{pane_id}')
tmux select-pane -t "$MAIN" -T "claude"

# ── full-width bottom strip for btop (fixes "Width=23" on narrow windows) ──
BOT=$(tmux split-window -v -l 28% -t "$MAIN" -c "$DIR" -P -F '#{pane_id}')
tmux select-pane -t "$BOT" -T "system"
tmux send-keys -t "$BOT" "$SYS" C-m

# ── right column (30% wide) in the top section ──
RCOL=$(tmux split-window -h -l 30% -t "$MAIN" -c "$DIR" -P -F '#{pane_id}')
tmux select-pane -t "$RCOL" -T "sessions"
tmux send-keys -t "$RCOL" "clear; $SESSIONS" C-m

FCOL=$(tmux split-window -v -l 55% -t "$RCOL" -c "$DIR" -P -F '#{pane_id}')
tmux select-pane -t "$FCOL" -T "files"
tmux send-keys -t "$FCOL" "$FILES" C-m

# main pane = Claude
tmux select-pane -t "$MAIN"
tmux send-keys -t "$MAIN" "clear; $AI" C-m

if [ -n "${TMUX:-}" ]; then exec tmux switch-client -t "$S"; else exec tmux attach -t "$S"; fi
