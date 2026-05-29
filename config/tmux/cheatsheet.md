# 🚀 Your terminal — cheat sheet   (prefix = Ctrl-b)

## Get into a project (NO cd!)
  p                 visual project picker → opens its cockpit
  prefix p          same, as a popup over anything
  z axtreo          jump to a folder by name (after you've visited once)
  prefix e          yazi file browser (arrows to move, q to quit)
  y                 browse files visually; quitting drops you in that folder

## Claude Code
  cc                start claude
  ccr               resume last claude chat in this folder
  ccs               claude in scrollable mode (search your past inputs)
  ask <question>    one-off question to Claude (prints answer, no session)
  prefix a          quick-ask Claude in a popup (side question)
  (notify)          you get a macOS ping + sound when Claude finishes / needs you

## Git without fear
  save              stage everything → commit (asks message) → push
  undo              throw away changes since last save (asks to confirm)
  lg / prefix g     lazygit — visual git (history, diff, push)
  ↑                 (in chat) recall your last input
  Ctrl+O then { }   jump message-to-message in transcript
  prefix u          jump to your previous input (then n = keep going up)

## Dashboard
  dash              vibe cockpit: Claude + lazygit + files + fastfetch
  prefix D          launch / jump to the dashboard
  prefix b          CPU monitor toggle (popup; p=cycle view, q=close)

## See & switch work
  prefix T          session picker (all your open work)
  prefix g          lazygit popup (commit, push, history — visual)
  prefix C-g        lazydocker popup
  prefix Space      scratch terminal popup

## Panes (split screen)
  ⌘D                split in the SAME folder (then `cc` for a new chat there)
  ⌘⇧D               split downward, same folder
  prefix |          split right        prefix -    split down
  prefix h/j/k/l    move between panes
  prefix z          zoom a pane fullscreen (toggle)
  prefix d          detach (work keeps running in background)

## Switch projects / tabs
  prefix p          pick a project → its own cockpit   ← easiest way
  prefix T          jump between open projects/sessions
  ⌘1 ⌘2 ⌘3…         switch Ghostty TABS (each tab = separate window)
  ⌘T                dashboard    ⌘⇧T   new tab    prefix b  CPU
  prefix M          matrix rain (break)

## Save / recover
  Your work survives crashes automatically (tmux).
  After a reboot: open terminal → it restores. Then `ccr` to resume Claude.

## This menu
  prefix ?          show this cheat sheet
