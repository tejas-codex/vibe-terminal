#!/usr/bin/env bash
# Battery % + state icon for the tmux status bar.
batt="$(pmset -g batt 2>/dev/null)"
pct="$(printf '%s' "$batt" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
[ -z "$pct" ] && exit 0
state="$(printf '%s' "$batt" | grep -Eo 'charging|charged|discharging|finishing charge' | head -1)"
case "$state" in
  charging|finishing*) icon="" ;;
  charged)             icon="" ;;
  *) if   [ "$pct" -ge 80 ]; then icon=""
     elif [ "$pct" -ge 50 ]; then icon=""
     elif [ "$pct" -ge 20 ]; then icon=""
     else icon=""; fi ;;
esac
printf '%s %s%%' "$icon" "$pct"
