#!/usr/bin/env bash
# claude-sessions.sh — interactive Claude Code session picker for dashboard
# Usage: claude-sessions.sh          → fzf picker, resume on select
#        claude-sessions.sh --watch  → live list display (non-interactive)
#
# Resume mechanics: claude -r <session-id> resumes any session by ID.
# Session IDs = UUID filenames in ~/.claude/projects/<encoded-path>/*.jsonl

PROJECTS="$HOME/.claude/projects"

# Build TSV: session_id \t date \t proj_short \t msg_count \t first_msg
_list_sessions() {
  find "$PROJECTS" -name "*.jsonl" 2>/dev/null |
  while read -r f; do
    grep -q '"type":"user"' "$f" 2>/dev/null || continue
    session_id=$(basename "$f" .jsonl)
    proj_encoded=$(basename "$(dirname "$f")")
    mtime=$(stat -f '%Sm' -t '%Y-%m-%d' "$f" 2>/dev/null)
    msg_count=$(grep -c '"type":"user"' "$f" 2>/dev/null || echo 0)

    # Decode last 2 path segments for display (e.g. AxtreoHQ/axtreo-app)
    proj_short=$(echo "$proj_encoded" | python3 -c "
import sys, re
raw = sys.stdin.read().strip()
# Claude encodes path: leading / → leading -, each / → -
# We decode last 2 real path components for a short readable name
decoded = '/' + raw.lstrip('-').replace('-', '/')
# Walk backwards to find an existing parent dir
parts = decoded.split('/')
for i in range(len(parts), 0, -1):
    candidate = '/'.join(parts[:i])
    import os
    if os.path.isdir(candidate):
        remaining = parts[i:]
        if remaining:
            print('/'.join(parts[max(1, i-1):]))
        else:
            print('/'.join(parts[-2:]))
        break
else:
    print('/'.join(parts[-2:]) if len(parts) >= 2 else raw)
" 2>/dev/null || echo "${proj_encoded##*-}")

    # Extract first real human-typed user message (skip injected system text)
    first_msg=$(python3 -c "
import json, sys
SKIP = ('<local-command', '<system-reminder', '<command-', '[mode:', '[CAVEMAN]',
        'Base directory for this skill', 'Respond terse like smart caveman',
        '[Image', 'Caveat:', '❯ [Pasted')
try:
  found = []
  for line in open(sys.argv[1]):
    d = json.loads(line)
    if d.get('type') == 'user':
      c = d.get('message', {}).get('content', '')
      texts = []
      if isinstance(c, list):
        for x in c:
          if isinstance(x, dict) and x.get('type') == 'text':
            texts.append(x['text'])
      elif isinstance(c, str):
        texts.append(c)
      for t in texts:
        t = t.strip().replace('\n', ' ')
        if len(t) > 8 and not any(t.startswith(s) for s in SKIP):
          found.append(t)
          if len(found) >= 3:
            break
    if len(found) >= 3:
      break
  if found:
    t = found[0]
    print(t[:55] + ('…' if len(t) > 55 else ''))
except:
  pass
" "$f" 2>/dev/null)

    printf '%s\t%s\t%s\t%s\t%s\n' \
      "$session_id" "$mtime" "$proj_short" "$msg_count" "${first_msg:-…}"
  done | sort -t$'\t' -k2 -r | head -20
}

# ── --watch mode: pretty live list for dashboard pane ────────────────────────
if [[ "${1:-}" == "--watch" ]]; then
  while true; do
    clear
    printf "\033[38;5;111m ◆ claude sessions\033[0m\n"
    printf "\033[38;5;245m ─────────────────────────────────────────\033[0m\n"
    _list_sessions | head -8 | while IFS=$'\t' read -r sid date proj count msg; do
      printf " \033[38;5;215m%-20s\033[0m \033[38;5;245m%s  %2s msgs\033[0m\n" \
        "$proj" "$date" "$count"
      printf "   \033[38;5;59m%s\033[0m\n" "$msg"
    done
    printf "\n \033[38;5;245m cs  to pick & resume a session\033[0m\n"
    sleep 30
  done
fi

# ── interactive fzf picker (default) ────────────────────────────────────────
have_fzf() { command -v fzf >/dev/null 2>&1; }

if ! have_fzf; then
  echo "fzf not found. Install: brew install fzf"
  echo ""
  _list_sessions | while IFS=$'\t' read -r sid date proj count msg; do
    printf "  [%s]  %s  %s msgs\n  %s\n\n" "$date" "$proj" "$count" "$msg"
  done
  echo "Resume: claude -r <session-id>"
  exec "$SHELL"
fi

SELECTED=$(_list_sessions | while IFS=$'\t' read -r sid date proj count msg; do
  printf '%s\t\033[38;5;111m%-22s\033[0m \033[38;5;245m%s\033[0m \033[38;5;59m%3s msgs\033[0m  %s\n' \
    "$sid" "$proj" "$date" "$count" "$msg"
done | fzf \
  --ansi \
  --no-sort \
  --reverse \
  --delimiter=$'\t' \
  --with-nth=2 \
  --prompt=' resume › ' \
  --header=' Enter=resume  Esc=cancel' \
  --height=100% \
  --border=none \
  --color='bg:#1b1a2e,bg+:#2e2d4a,fg:#c2c2dc,fg+:#ffffff,hl:#56b6c2,hl+:#56b6c2,prompt:#e0a44a,header:#4b5066,pointer:#56b6c2')

if [[ -n "$SELECTED" ]]; then
  SESSION_ID=$(printf '%s' "$SELECTED" | cut -f1)
  echo ""
  echo " resuming session $SESSION_ID …"
  exec claude -r "$SESSION_ID"
fi
