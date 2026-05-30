#!/usr/bin/env bash
# Dashboard banner: gradient title + clean system info.
# Drops only truly sensitive lines (serial / IP) — no number-mangling, so
# memory/disk read correctly instead of the old garbled "— / —".
clear
if command -v figlet >/dev/null && command -v lolcat >/dev/null; then
  figlet -f standard "LET'S CODE" 2>/dev/null | lolcat -a -d 1 -s 60 2>/dev/null
else
  printf '\n  \033[1;35m⚡ LET'\''S CODE ⚡\033[0m\n'
fi
echo
if command -v fastfetch >/dev/null; then
  fastfetch 2>/dev/null | grep -viE 'Serial|Local IP|Public IP'
fi
echo
printf "  \033[1;35mtejas\033[0m \033[38;5;244m· vibe terminal\033[0m   \033[38;5;108m⚡ ⌘T cockpit · prefix ? keys\033[0m\n"
