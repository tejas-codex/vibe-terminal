#!/usr/bin/env bash
# Click target for Claude notifications: bring Ghostty front and switch tmux
# to the session/pane running this chat (matched by working directory).
CWD="${1:-}"
open -a Ghostty 2>/dev/null   # focus the terminal app

[ -z "$CWD" ] && exit 0
# Prefer the pane that's actually running Claude (claude/node) in that dir.
PANE=$(tmux list-panes -a -F '#{pane_current_path}|#{session_name}:#{window_index}.#{pane_index}|#{pane_current_command}' 2>/dev/null \
  | awk -F'|' -v d="$CWD" '$1==d && ($3 ~ /claude|node/){print $2; exit}')
[ -z "$PANE" ] && PANE=$(tmux list-panes -a -F '#{pane_current_path}|#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null \
  | awk -F'|' -v d="$CWD" '$1==d{print $2; exit}')

if [ -n "$PANE" ]; then
  tmux switch-client -t "${PANE%.*}" 2>/dev/null
  tmux select-pane  -t "$PANE" 2>/dev/null
fi
exit 0
