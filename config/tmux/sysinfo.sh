#!/usr/bin/env bash
# Compact CPU% + memory for tmux status bar (macOS, runs in ~0.7s).
# Called by tmux status-right every status-interval seconds.
out=$(top -l 1 -n 0 -s 0 2>/dev/null)
cpu=$(printf '%s' "$out" | awk '/CPU usage/{gsub(/[%,]/,"",$3); printf "%d", $3}')
mem=$(printf '%s' "$out" | awk '/PhysMem/{print $2}')
printf "󰻠 %s%%  󰍛 %s" "${cpu:--}" "${mem:--}"
