
# ════════════════════════════════════════════════════════════
#  Warp-parity shell stack  (Ghostty + Claude Code)
# ════════════════════════════════════════════════════════════
BREW="$(brew --prefix 2>/dev/null || echo /opt/homebrew)"

# completion engine (needed by fzf-tab / autosuggestions)
autoload -Uz compinit && compinit -C
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive

# 1) fzf-tab — fuzzy Tab completion menu (load BEFORE autosuggest/highlight)
source ~/.config/zsh/fzf-tab/fzf-tab.plugin.zsh 2>/dev/null
zstyle ':fzf-tab:*' fzf-flags --height=40% --reverse
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath 2>/dev/null'

# 2) inline grey suggestions from history (→ or End to accept)
source "$BREW/share/zsh-autosuggestions/zsh-autosuggestions.zsh" 2>/dev/null
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#565f89"

# 3) command syntax highlighting (green=valid, red=typo) — MUST be near-last
source "$BREW/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" 2>/dev/null

# ── Tool inits ────────────────────────────────────────────────
eval "$(starship init zsh)"           # prompt
eval "$(zoxide init zsh)"             # z <dir> smart jump  (replaces cd habit)
source <(fzf --zsh)                   # Ctrl-T files, Alt-C dirs, Ctrl-R (atuin overrides)
eval "$(atuin init zsh)"              # Warp-style searchable history DB on Ctrl-R / Up

# ── fzf look + tools ──────────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS="--height 45% --layout reverse --border rounded \
  --color=bg+:#283457,fg+:#c0caf5,hl:#7aa2f7,hl+:#7dcfff,border:#3b4261,prompt:#7aa2f7,pointer:#bb9af7"
export BAT_THEME="Coldark-Dark"

# ── Aliases (modern CLI over the old ones) ────────────────────
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias lt='eza --tree --level=2 --icons'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias cd='z'
alias lg='lazygit'
alias lzd='lazydocker'
alias dash='~/.config/tmux/dashboard.sh'   # premium WORK cockpit (Claude-first)
alias flex='~/.config/tmux/flex.sh'        # SHOWCASE rice (ticker/btop/feeds/yazi)
alias theme='~/.config/ghostty/toggle-appearance.sh'  # flip dark ↔ light, live
alias cc='claude'
alias ccr='claude -c'                 # resume last Claude session in this dir
alias cs='~/.config/tmux/claude-sessions.sh'  # fzf picker: browse+resume any session
# Scrollable/searchable Claude: keeps the whole chat in real terminal scrollback
# so tmux copy-mode (prefix u) + Ghostty ⌘F can find your past inputs.
alias ccs='CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1 claude'
alias reload='source ~/.zshrc'

# ── Vibe-coder navigation (no cd, no paths) ───────────────────
# p  → visual project picker → land in the project's cockpit
alias p='~/.config/tmux/project-picker.sh'
# y  → browse files visually; quitting yazi drops your shell INTO that folder
y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXX)"
  yazi --cwd-file="$tmp" "$@"
  if cwd="$(cat -- "$tmp" 2>/dev/null)" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
# o  → open current folder in Finder (vibe-coder escape hatch)
alias o='open .'

# ── Git without fear ──────────────────────────────────────────
# save → stage everything, commit (asks for a message), push.
save() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "  not a git project here"; return 1; }
  git add -A
  local msg="$*"
  if [ -z "$msg" ]; then
    if command -v gum >/dev/null 2>&1; then
      msg=$(gum input --placeholder "what did you change? (enter = auto)")
    fi
    [ -z "$msg" ] && msg="save: $(date '+%Y-%m-%d %H:%M')"
  fi
  git commit -m "$msg" || { echo "  nothing to save"; return 0; }
  if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
    git push && echo "  saved + pushed"
  else
    echo "  saved locally (no remote set — that's fine)"
  fi
}
# undo → discard your uncommitted changes (back to last save). Asks first.
undo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "  not a git project here"; return 1; }
  echo "  This discards ALL uncommitted changes in: $(pwd)"
  read "ans?  Type yes to confirm: "
  if [ "$ans" = "yes" ]; then git restore . && echo "  reverted to last save"; else echo "  cancelled"; fi
}
# ask → one-off question to Claude, prints answer, no session. e.g. ask how do I rename a git branch
ask() { claude -p "$*"; }

# ── New terminal window → premium dashboard cockpit ──────────────
# Works in Ghostty AND Warp. Any fresh window (no $TMUX yet) lands in
# the dashboard, scoped to current folder. Crash recovery: tmux daemon
# survives app crashes; continuum auto-saves + restores all sessions.
if [[ -z "$TMUX" && $- == *i* ]] && \
   [[ "$TERM_PROGRAM" == "ghostty" || "$TERM_PROGRAM" == "WarpTerminal" ]]; then
  exec ~/.config/tmux/dashboard.sh "$PWD"
fi
