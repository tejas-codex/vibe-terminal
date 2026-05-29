---
description: Add or change a Vibe Terminal feature using the verify→sync workflow
---

Add this to Vibe Terminal: **$ARGUMENTS**

Follow the project workflow exactly (see CLAUDE.md). Stay in terminal scope only.

1. **Read first** — open the relevant live config (`~/.config/ghostty/config`,
   `~/.tmux.conf`, `~/.config/vibe.zsh`, `~/.config/tmux/*.sh`, etc.) before editing.
2. **Edit** the live file to implement the change.
3. **Verify** (never skip):
   - Ghostty: `ghostty +validate-config`
   - tmux: `tmux source-file ~/.tmux.conf` (no errors) + `tmux list-keys | grep <key>`
   - zsh: `zsh -ic 'echo ok'`
   - scripts: `bash -n <script>` + run in a throwaway tmux session
4. If a keybind changed → add a line to `~/.config/tmux/cheatsheet.md`.
5. **Sync to repo**: `cd ~/dotfiles-vibe && ./sync.sh`
6. Show the diff, then commit + push (ask first).

Back up before overwriting. Keep configs commented in plain language.
