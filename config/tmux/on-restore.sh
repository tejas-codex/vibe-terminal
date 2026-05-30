#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────
#  Fires AFTER tmux-resurrect restores your sessions (reboot/crash).
#  Tells you recovery worked + how to bring the Claude CHATS back
#  (resurrect relaunches claude fresh — `ccr` rehydrates the convo).
# ──────────────────────────────────────────────────────────────
panes=$(tmux list-panes -a 2>/dev/null | wc -l | tr -d ' ')
sess=$(tmux list-sessions 2>/dev/null | wc -l | tr -d ' ')
if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier -title "⚡ Vibe session restored" \
    -subtitle "${sess} sessions · ${panes} panes back" \
    -message "Claude panes relaunched fresh — type ccr in one to resume that chat." \
    -sound Glass -group vibe-restore >/dev/null 2>&1
fi
exit 0
