# Vibe Terminal — project context for Claude Code

You are working on **Vibe Terminal**: a portable macOS terminal environment.
Stack: **Ghostty** (terminal) + **tmux** (multiplexer/persistence) + **zsh**
(Warp-parity) + **Claude Code** tuning. One-command install, shareable.

## Scope — stay in this lane
✅ Work ONLY on the terminal experience: Ghostty config, tmux config + scripts,
   zsh (starship/plugins/aliases/functions), CLI tools, the dashboard, Claude
   Code theme/hooks, the install/sync/demo scripts.
🚫 Do NOT touch unrelated system settings, other apps, user projects, secrets,
   git/ssh keys, or anything outside this terminal setup.

## File map
```
config/ghostty.config     → ~/.config/ghostty/config   (font, theme, opacity, keybinds)
config/tmux.conf          → ~/.tmux.conf               (status bar, popups, resurrect)
config/vibe.zsh           → ~/.config/vibe.zsh         (starship, fzf, atuin, aliases, fns)
config/starship.toml      → ~/.config/starship.toml
config/sesh.toml          → ~/.config/sesh/sesh.toml
config/btop.conf          → ~/.config/btop/btop.conf   (CPU-only preset)
config/tmux/dashboard.sh  → the pilot cockpit (Claude + lazygit + yazi + fastfetch)
config/tmux/project-picker.sh, banner.sh, battery.sh, cheatsheet.md
config/claude/vibe-dark.json → ~/.claude/themes/        (highlighted user messages)
config/claude/hooks/*.sh     → ~/.claude/hooks/         (notify-done, focus-session)
install.sh / sync.sh / bootstrap.sh / record-demo.sh / Brewfile
```

## How to add or change a feature (the workflow)
1. Read the relevant live config first (`~/.config/...`), then edit it.
2. **Always verify** before claiming done:
   - Ghostty: `ghostty +validate-config`
   - tmux: `tmux source-file ~/.tmux.conf` (no errors) + `tmux list-keys | grep ...`
   - zsh: `zsh -ic 'echo ok'` loads clean
   - scripts: `bash -n script.sh` + run it in a throwaway tmux session
3. Pull the change back into the repo: `./sync.sh`
4. Commit + push. Keep `install.sh` idempotent and always backing up (`.bak-*`).

## Conventions
- Comment configs in plain language (the owner is a vibe coder, not a sysadmin).
- New keybinds → also add a line to `config/tmux/cheatsheet.md`.
- Keep it friend-safe: no personal paths, IPs, emails, or secrets in committed files.
- macOS only (Apple Silicon, Homebrew at /opt/homebrew).

## Owner's key bindings (so you don't break them)
⌘T dashboard · ⌘⇧T new tab · ⌘D / ⌘⇧D split same-folder · Option+←/→ word jump
prefix(Ctrl-b) ? cheatsheet · p projects · T sessions · g lazygit · e yazi · b cpu · M matrix

## 👋 First-run onboarding (IMPORTANT — do this proactively)
If this looks like a fresh install (the user just cloned/ran install.sh, or asks
"what is this" / "how do I customize"), GREET them briefly, summarize what's
installed in one line, and OFFER to personalize it:

> "This sets up your Ghostty terminal — dashboard, Warp-style shell, crash
>  recovery, Claude theme. Want to customize it to your taste? Run **/customize**
>  (theme, transparency, dashboard panes, notifications, font)."

Then if they say yes, run the `/customize` flow. Don't change anything without asking.

## Customizable preferences (the knobs + where they live)
| Preference | File | Setting |
|---|---|---|
| Ghostty color theme | `~/.config/ghostty/config` | `theme =` |
| Highlight color of user msgs | `~/.claude/themes/vibe-dark.json` | `userMessageBackground` |
| Transparency / blur | `~/.config/ghostty/config` | `background-opacity`, `background-blur-radius` |
| Font + size | `~/.config/ghostty/config` | `font-family`, `font-size` |
| Dashboard panes/layout | `~/.config/tmux/dashboard.sh` | which tools, split sizes |
| Auto-start Claude in dashboard | `~/.config/tmux/dashboard.sh` | `$AI` send-keys line |
| Land on dashboard vs shell | `~/.config/vibe.zsh` | Ghostty auto-attach block |
| Claude-done notifications | `~/.claude/settings.json` + `notify-done.sh` | Stop/Notification hooks |

Slash commands available here: **/customize** (personalize) · **/add-feature** (extend).
