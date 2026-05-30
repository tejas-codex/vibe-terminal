#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
#  dash — premium WORK cockpit. Claude-first, scoped to a folder.
#   ┌──────────────────────────┬──────────────┐
#   │                          │   git        │  ← lazygit (repo) / hint
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
S="${2:-dash_$NAME}"          # one cockpit per folder → real folder scoping

# Already open for this folder? jump to it, don't rebuild.
if tmux has-session -t "$S" 2>/dev/null; then
  if [ -n "${TMUX:-}" ]; then exec tmux switch-client -t "$S"; else exec tmux attach -t "$S"; fi
fi

have() { command -v "$1" >/dev/null 2>&1; }

# Git pane is git-aware: lazygit ONLY in a real repo (no ugly error).
if git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 && have lazygit; then
  GIT="lazygit"
else
  GIT="clear; printf '\n   \033[38;5;111mnot a git project yet\033[0m\n   run  \033[38;5;150mgit init\033[0m  to track it, or  \033[38;5;215mp\033[0m  to pick another folder\n\n'; exec \$SHELL"
fi
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

# right column (32% wide): git on top
RCOL=$(tmux split-window -h -l 32% -t "$MAIN" -c "$DIR" -P -F '#{pane_id}')
tmux select-pane -t "$RCOL" -T "git"
tmux send-keys -t "$RCOL" "$GIT" C-m
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
