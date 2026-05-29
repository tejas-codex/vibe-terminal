---
description: Personalize the Vibe Terminal — theme, transparency, dashboard, tools, notifications
---

Help me personalize my Vibe Terminal. I just installed it and want it tuned to
my taste. Use **AskUserQuestion** to present the menu (multi-select), then APPLY
each chosen change to the live config, VERIFY it, and confirm. Stay in terminal
scope only (Ghostty / tmux / zsh / dashboard / Claude theme).

Ask me which of these I want to change:

1. **Color theme** — Ghostty theme (run `ghostty +list-themes` to browse) and the
   Claude user-message highlight color (`~/.claude/themes/vibe-dark.json` →
   `userMessageBackground`). File: `~/.config/ghostty/config` (`theme =`).
2. **Transparency** — `background-opacity` (0.70 glassy … 1.0 solid) + `background-blur-radius`.
3. **Dashboard panes** — which tools show and the layout. Edit `~/.config/tmux/dashboard.sh`.
   Options: lazygit, yazi, fastfetch, btop, a dev-server/log pane, plain shell.
4. **Auto-start Claude** in the dashboard's main pane: yes (lands in Claude) / no (plain shell, type `cc`).
5. **Landing** — open Ghostty straight into the dashboard, or a plain shell. File: `~/.config/vibe.zsh`.
6. **Notifications** — Claude-done desktop pings on/off, and the sound. Files: `~/.claude/settings.json`, `~/.claude/hooks/notify-done.sh`.
7. **Font + size** — `~/.config/ghostty/config` (`font-family`, `font-size`).

For each change I pick:
- Read the file → edit → verify (`ghostty +validate-config`, `tmux source-file`,
  `zsh -ic 'echo ok'`, `bash -n`) → tell me to reload (⌘⇧, for Ghostty, `prefix r` for tmux).
At the end, offer to `cd ~/dotfiles-vibe && ./sync.sh` and commit so my tweaks are saved to my fork.
