#!/usr/bin/env bash
# Energetic dashboard banner: animated gradient title + SAFE system info.
# Uses fastfetch but scrubs machine fingerprint (hostname/build/serial/IP/uptime)
# so screenshots & recordings never leak personal machine details.
clear
if command -v figlet >/dev/null && command -v lolcat >/dev/null; then
  figlet -f standard "LET'S CODE" 2>/dev/null | lolcat -a -d 1 -s 60 2>/dev/null
else
  printf '\n  ⚡ LET'\''S CODE ⚡\n'
fi
echo
if command -v fastfetch >/dev/null; then
  # show only safe lines; drop anything that fingerprints the machine
  fastfetch 2>/dev/null | grep -viE 'Host|Kernel|Uptime|Serial|Battery|Local IP|Public IP|Display|Locale|Swap|WM|Bios|Board|@' \
    | sed -E 's/\([0-9A-Za-z]+\)//g; s/macOS [0-9.]+ ?\([0-9A-Za-z]+\)/macOS/; s/[0-9]{2}\.[0-9]+ GiB/—/g'
fi
echo
printf "  \033[1;35mtejas\033[0m \033[38;5;244m· vibe terminal\033[0m   \033[38;5;108m⚡ ⌘T dashboard · prefix ? keys\033[0m\n"
