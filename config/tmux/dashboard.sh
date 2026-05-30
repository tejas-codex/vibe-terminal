#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
#  dash — premium WORK cockpit. Claude-first, scoped to a folder.
#   ┌──────────────────────────┬──────────────┐
#   │                          │   sessions   │  ← fzf Claude session picker
#   │   ◆ CLAUDE  (main, 68%)   ├──────────────┤
#   │     auto-starts claude    │   files      │  ← yazi
#   │                          ├──────────────┤
#   │                          │   system     │  ← live btop pulse
#   └──────────────────────────┴──────────────┘
#   Titled pane borders + solid dark = the premium read.
#   Launch:  dash  |  ⌘T  |  dash ~/Desktop/my-project
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
  # Inside tmux: jump to existing session for this folder, or create one.
  S="${2:-dash_$NAME}"
  if tmux has-session -t "$S" 2>/dev/null; then
    exec tmux switch-client -t "$S"
  fi
else
  # New Ghostty window: unique session name so each window is independent.
  BASE="dash_$NAME"
  S="$BASE"
  n=1
  while tmux has-session -t "$S" 2>/dev/null; do
    n=$((n + 1))
    S="${BASE}_${n}"
  done
fi

have() { command -v "$1" >/dev/null 2>&1; }

# Sessions pane: interactive claude session picker (fzf), auto-resumes on select.
SESSIONS="$HOME/.config/tmux/claude-sessions.sh"
FILES=$(have yazi && echo "yazi \"$DIR\"" || echo "exec \$SHELL")
# live system pulse — btop (CPU/mem) reads far more premium than a static banner.
SYS=$(have btop && echo "btop" || echo "$HOME/.config/tmux/banner.sh; exec \$SHELL")
AI=$(have claude && echo claude || echo "exec \$SHELL")

tmux new-session -d -s "$S" -n vibe -c "$DIR"

# ── premium look: titled pane borders, scoped to THIS session ──
tmux set-option -t "$S" pane-border-status top
tmux set-option -t "$S" pane-border-lines heavy
tmux set-option -t "$S" pane-border-format " #[fg=#61afef,bold]#{?pane_active,◆ ,}#{pane_title}#[default] "
tmux set-option -t "$S" pane-border-style "fg=#262540"
tmux set-option -t "$S" pane-active-border-style "fg=#61afef"

MAIN=$(tmux display -p -t "$S:vibe" '#{pane_id}')
tmux select-pane -t "$MAIN" -T "claude"

# right column (32% wide): sessions on top
RCOL=$(tmux split-window -h -l 32% -t "$MAIN" -c "$DIR" -P -F '#{pane_id}')
tmux select-pane -t "$RCOL" -T "sessions"
tmux send-keys -t "$RCOL" "clear; $SESSIONS" C-m
# files in the middle
FCOL=$(tmux split-window -v -l 64% -t "$RCOL" -c "$DIR" -P -F '#{pane_id}')
tmux select-pane -t "$FCOL" -T "files"
tmux send-keys -t "$FCOL" "$FILES" C-m
# live system at the bottom of the right column
MCOL=$(tmux split-window -v -l 44% -t "$FCOL" -c "$DIR" -P -F '#{pane_id}')
tmux select-pane -t "$MCOL" -T "system"
tmux send-keys -t "$MCOL" "$SYS" C-m

# main pane = Claude, scoped to this folder, ready to vibe
tmux select-pane -t "$MAIN"
tmux send-keys -t "$MAIN" "clear; $AI" C-m

if [ -n "${TMUX:-}" ]; then exec tmux switch-client -t "$S"; else exec tmux attach -t "$S"; fi
