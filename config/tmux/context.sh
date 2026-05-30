#!/usr/bin/env bash
# context.sh — project orientation pane for the dashboard.
# Shows: git branch/status + recent commits + last Claude session for this dir.
# Auto-refreshes every 30s. Replaces the yazi file browser.
# Usage: context.sh [dir]

DIR="${1:-$PWD}"
C_RESET="\033[0m"
C_CYAN="\033[38;5;80m"
C_ORANGE="\033[38;5;215m"
C_DIM="\033[38;5;59m"
C_WHITE="\033[38;5;252m"
C_GREEN="\033[38;5;114m"
C_RED="\033[38;5;203m"
C_BLUE="\033[38;5;111m"

_render() {
  clear
  # ── header ──────────────────────────────────────────────────
  printf "${C_CYAN} ◆ context${C_DIM}  %s${C_RESET}\n" "$(echo "$DIR" | sed "s|$HOME|~|")"
  printf "${C_DIM} ─────────────────────────────────────────${C_RESET}\n"

  # ── git section ─────────────────────────────────────────────
  if git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git -C "$DIR" branch --show-current 2>/dev/null)
    ahead=$(git -C "$DIR" rev-list --count "@{upstream}..HEAD" 2>/dev/null || echo "")
    behind=$(git -C "$DIR" rev-list --count "HEAD..@{upstream}" 2>/dev/null || echo "")
    aheadbehind=""
    [ -n "$ahead"  ] && [ "$ahead"  != "0" ] && aheadbehind="${aheadbehind} ⇡${ahead}"
    [ -n "$behind" ] && [ "$behind" != "0" ] && aheadbehind="${aheadbehind} ⇣${behind}"

    # count staged + unstaged + untracked
    changed=$(git -C "$DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    [ "$changed" != "0" ] && dirty=" ${C_ORANGE}· ${changed} changed${C_RESET}" || dirty=""

    printf "\n${C_GREEN}  ${C_WHITE}${branch}${C_DIM}${aheadbehind}${dirty}${C_RESET}\n\n"

    # recent commits
    printf "${C_DIM}  recent commits${C_RESET}\n"
    git -C "$DIR" log --oneline -6 --color=never 2>/dev/null | while read -r line; do
      hash=$(echo "$line" | cut -c1-7)
      msg=$(echo "$line" | cut -c9-)
      printf "  ${C_DIM}%s${C_RESET}  ${C_WHITE}%s${C_RESET}\n" "$hash" "$msg"
    done

    # changed files
    if [ "$changed" != "0" ]; then
      printf "\n${C_DIM}  uncommitted${C_RESET}\n"
      git -C "$DIR" status --porcelain 2>/dev/null | head -5 | while read -r line; do
        status="${line:0:2}"
        file="${line:3}"
        case "$status" in
          "M "*|" M") color="$C_ORANGE" ;;
          "A "*|" A") color="$C_GREEN" ;;
          "D "*|" D") color="$C_RED" ;;
          *"?"*)       color="$C_DIM" ;;
          *)           color="$C_WHITE" ;;
        esac
        printf "  ${color}%s${C_DIM}  %s${C_RESET}\n" "$status" "$file"
      done
      [ "$changed" -gt 5 ] && printf "  ${C_DIM}… and $((changed - 5)) more${C_RESET}\n"
    fi
  else
    printf "\n${C_DIM}  not a git repo${C_RESET}\n"
    # show recent files instead
    printf "\n${C_DIM}  recent files${C_RESET}\n"
    ls -lt "$DIR" 2>/dev/null | tail -n +2 | head -6 | awk '{print "  "$NF}' | while read -r f; do
      printf "${C_DIM}%s${C_RESET}\n" "$f"
    done
  fi

  # ── last Claude session for this dir ────────────────────────
  # Encode dir path the way Claude does: prepend -, replace / with -
  encoded=$(echo "$DIR" | sed 's|^/|-|; s|/|-|g')
  proj_dir="$HOME/.claude/projects/${encoded}"

  if [ -d "$proj_dir" ]; then
    printf "\n${C_DIM} ─────────────────────────────────────────${C_RESET}\n"
    printf "${C_CYAN}  last session${C_RESET}\n\n"

    SKIP='<local-command|<system-reminder|<command-|Base directory for this skill|Respond terse|[Image'
    latest=$(find "$proj_dir" -name "*.jsonl" 2>/dev/null | \
      xargs ls -t 2>/dev/null | head -1)

    if [ -n "$latest" ]; then
      mtime=$(stat -f '%Sm' -t '%Y-%m-%d' "$latest" 2>/dev/null)
      msg_count=$(grep -c '"type":"user"' "$latest" 2>/dev/null || echo 0)
      first_msg=$(python3 -c "
import json, sys, re
skip = ('<local-command', '<system-reminder', '<command-', 'Base directory',
        'Respond terse', '[Image', '[CAVEMAN]')
try:
  for line in open(sys.argv[1]):
    d = json.loads(line)
    if d.get('type') == 'user':
      c = d.get('message', {}).get('content', '')
      texts = []
      if isinstance(c, list):
        for x in c:
          if isinstance(x, dict) and x.get('type') == 'text': texts.append(x['text'])
      elif isinstance(c, str): texts.append(c)
      for t in texts:
        t = t.strip().replace('\n', ' ')
        if len(t) > 8 and not any(t.startswith(s) for s in skip):
          print(t[:60] + ('…' if len(t) > 60 else ''))
          sys.exit()
except: pass
" "$latest" 2>/dev/null)

      printf "  ${C_WHITE}\"${first_msg}\"${C_RESET}\n"
      printf "  ${C_DIM}%s  ·  %s msgs  ·  ccr to resume${C_RESET}\n\n" "$mtime" "$msg_count"
    fi
  fi

  printf "${C_DIM}  r=refresh  e=files  b=btop${C_RESET}\n"
}

# Interactive loop: refresh on 'r', open yazi on 'e', btop on 'b', quit on 'q'/Esc
while true; do
  _render
  # Read one keypress (timeout 30s → auto-refresh)
  if read -r -s -n 1 -t 30 key 2>/dev/null; then
    case "$key" in
      r|R) continue ;;
      e|E) yazi "$DIR" 2>/dev/null || ls -la "$DIR"; continue ;;
      b|B) btop 2>/dev/null; continue ;;
      q|Q) break ;;
      $'\x1b') break ;;
    esac
  fi
  # timeout → refresh
done
