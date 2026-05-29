#!/usr/bin/env bash
# Rich Claude Code notification. Reads hook JSON on stdin (cwd, session_id,
# transcript_path). Shows project + your last request. Click → focus the chat.
# Arg 1 = label ("...finished" or "...needs...").
INPUT="$(cat)"
LABEL="${1:-finished}"

CWD="$(printf '%s' "$INPUT"        | jq -r '.cwd // empty' 2>/dev/null)"
SID="$(printf '%s' "$INPUT"        | jq -r '.session_id // empty' 2>/dev/null)"
TRANSCRIPT="$(printf '%s' "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)"
[ -z "$CWD" ] && CWD="$PWD"
PROJ="$(basename "$CWD")"
BRANCH="$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null)"

# Last thing YOU asked, pulled from the transcript — "which chat" context.
LAST=""
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  LAST="$(jq -rs '
    [ .[] | select(.type=="user") | .message.content
      | if type=="array" then (map(select(.type=="text").text) | join(" ")) else . end ]
    | map(select(. != null and (. | tostring) != "" and (. | startswith("[") | not)))
    | last // ""' "$TRANSCRIPT" 2>/dev/null | tr '\n' ' ' | sed 's/  */ /g; s/^ //')"
fi
LAST="$(printf '%s' "$LAST" | cut -c1-100)"

case "$LABEL" in
  *need*) SOUND="Ping";  SUB="⏳ waiting for you" ;;
  *)      SOUND="Glass"; SUB="✅ done" ;;
esac
TITLE="🤖 ${PROJ}${BRANCH:+  $BRANCH}"
MSG="${LAST:-tap to open this chat}"
FOCUS="$HOME/.claude/hooks/focus-session.sh '$CWD'"

terminal-notifier -title "$TITLE" -subtitle "$SUB" -message "$MSG" \
  -sound "$SOUND" -execute "$FOCUS" -group "claude-${SID:-x}" >/dev/null 2>&1
exit 0
