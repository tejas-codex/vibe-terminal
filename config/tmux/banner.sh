#!/usr/bin/env bash
# Energetic dashboard banner: animated gradient title + system info.
clear
if command -v figlet >/dev/null && command -v lolcat >/dev/null; then
  figlet -f standard "LET'S CODE" 2>/dev/null | lolcat -a -d 1 -s 60 2>/dev/null
else
  printf '\n  ⚡ LET'\''S CODE ⚡\n'
fi
echo
command -v fastfetch >/dev/null && fastfetch 2>/dev/null
echo "  ⚡ ready — press ⌘T anytime for the dashboard, prefix ? for keys"
