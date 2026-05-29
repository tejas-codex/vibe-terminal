<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&height=220&color=0:7aa2f7,40:bb9af7,75:7dcfff,100:9ece6a&text=Vibe%20Terminal&fontColor=ffffff&fontSize=64&fontAlignY=38&desc=Ghostty%20%2B%20tmux%20%2B%20Warp-parity%20zsh%20%C2%B7%20tuned%20for%20Claude%20Code&descSize=17&descAlignY=60&animation=fadeIn" width="100%" alt="Vibe Terminal"/>

### A beautiful, crash-proof macOS terminal. **One line installs everything.** ⚡

<p>
<a href="https://tejas-codex.github.io/vibe-terminal/"><img src="https://img.shields.io/badge/🌐_Website-7aa2f7?style=for-the-badge&logoColor=white&labelColor=1a1b26" alt="Website"/></a>
<a href="#-install"><img src="https://img.shields.io/badge/⚡_Install-bb9af7?style=for-the-badge&labelColor=1a1b26" alt="Install"/></a>
<a href="https://github.com/tejas-codex/vibe-terminal/stargazers"><img src="https://img.shields.io/github/stars/tejas-codex/vibe-terminal?style=for-the-badge&color=e0af68&labelColor=1a1b26&logo=github" alt="Stars"/></a>
<a href="https://github.com/tejas-codex"><img src="https://img.shields.io/badge/made_by-Tejas-9ece6a?style=for-the-badge&labelColor=1a1b26" alt="made by Tejas"/></a>
</p>

<p>
<img src="https://img.shields.io/badge/macOS-Apple_Silicon-9ece6a?style=flat-square&logo=apple&logoColor=white&labelColor=1a1b26"/>
<img src="https://img.shields.io/badge/Ghostty-terminal-7aa2f7?style=flat-square&labelColor=1a1b26"/>
<img src="https://img.shields.io/badge/tmux-persistent-7dcfff?style=flat-square&labelColor=1a1b26"/>
<img src="https://img.shields.io/badge/Claude_Code-tuned-bb9af7?style=flat-square&labelColor=1a1b26"/>
<img src="https://img.shields.io/badge/license-MIT-f7768e?style=flat-square&labelColor=1a1b26"/>
</p>

<br/>

<img src="assets/hero.png" width="80%" alt="Vibe Terminal preview"/>

</div>

## ⚡ Install

<div align="center">

**Paste this one line. It installs Homebrew + the Ghostty app + every tool + all configs, then opens the dashboard.**

</div>

```bash
curl -fsSL https://raw.githubusercontent.com/tejas-codex/vibe-terminal/main/bootstrap.sh | bash
```

<details>
<summary>Prefer to clone first?</summary>

```bash
git clone https://github.com/tejas-codex/vibe-terminal.git ~/dotfiles-vibe
cd ~/dotfiles-vibe && ./install.sh
```
</details>

> Only requirement: a **Mac** (Apple Silicon). Existing files are backed up (`.bak-*`). The installer is idempotent — re-run anytime.

## 🤖 …or just tell your AI agent

Don't want to touch the terminal? Paste this into **Claude Code, Cursor, or any AI CLI** — it does the whole install for you:

```text
Set up the Vibe Terminal from https://github.com/tejas-codex/vibe-terminal —
run its installer:  curl -fsSL https://raw.githubusercontent.com/tejas-codex/vibe-terminal/main/bootstrap.sh | bash
Then read CLAUDE.md and offer to run /customize.
```

## 🧩 What you're installing

| | Tool | What it does |
|---|---|---|
| 🖥️ | **[Ghostty](https://ghostty.org/)** | the terminal app — fast, GPU-accelerated, native (the installer grabs it for you) |
| 🛟 | **tmux** | keeps your work + Claude alive through crashes, restarts, reboots |
| ⌨️ | **zsh + starship** | smart, good-looking shell — suggestions, fuzzy history, smart jump |
| 🤖 | **Claude Code** | Anthropic's AI coding CLI — this setup is tuned around it |

## ✨ Why it feels great

<table>
<tr>
<td width="33%" valign="top"><h3>🚀 One-line install</h3>Homebrew, Ghostty, every CLI tool & all configs — done in minutes.</td>
<td width="33%" valign="top"><h3>🛟 Crash-proof</h3>tmux keeps your sessions (and Claude) alive through anything.</td>
<td width="33%" valign="top"><h3>🎛️ Pilot dashboard</h3>⌘T → Claude + lazygit + files + system, auto-laid-out.</td>
</tr>
<tr>
<td valign="top"><h3>⌨️ Warp-parity shell</h3>Inline suggestions, fuzzy history (atuin), zoxide, starship.</td>
<td valign="top"><h3>🤖 Tuned for Claude</h3>Highlighted messages, desktop pings, resume, ⌘V fix, word-jump.</td>
<td valign="top"><h3>🎨 Yours in seconds</h3><code>customize.sh</code> or <code>/customize</code> — theme, transparency, font.</td>
</tr>
</table>

## 🖼️ Looks

<div align="center">

<b>The dashboard — <code>⌘T</code></b>
<img src="assets/dashboard.png" width="82%" alt="Vibe dashboard"/>

<br/><br/>

<b>Make it your style — <code>customize.sh</code></b>
<img src="assets/themes.png" width="82%" alt="Theme options"/>

</div>

## ⌨️ Key bindings

<div align="center">

| Key | Action | | Key | Action |
|---|---|---|---|---|
| `⌘T` | open the dashboard | | `prefix g` | lazygit (visual git) |
| `⌘D` / `⌘⇧D` | split — **same folder** | | `prefix e` | yazi file browser |
| `⌥ ← / →` | jump by word | | `prefix b` | CPU monitor |
| `prefix p` | project picker | | `save` / `undo` | git without fear |
| `prefix T` | switch sessions | | `cc` / `ccr` | claude / resume chat |

*prefix = `Ctrl-b` · forgot one? press `Ctrl-b ?` for the live cheat sheet*

<img src="assets/cheatsheet.png" width="70%" alt="cheat sheet"/>

</div>

## 🎨 Make it yours

```bash
~/dotfiles-vibe/customize.sh          # gum menu: theme · transparency · highlight · font
```
Or, with Claude Code: `cd ~/dotfiles-vibe && claude` → `/customize`.

## 🔁 Get started in 3 steps

<table>
<tr>
<td width="33%" valign="top"><h3>1️⃣ Paste the line</h3>Run the install command in any terminal.</td>
<td width="33%" valign="top"><h3>2️⃣ Ghostty opens</h3>You land in the dashboard — Claude, git, files, system.</td>
<td width="33%" valign="top"><h3>3️⃣ Make it yours</h3>Run <code>customize.sh</code> to tune the look.</td>
</tr>
</table>

## 🔄 Sync across machines

After tweaking on any machine:
```bash
cd ~/dotfiles-vibe && ./sync.sh && git add -A && git commit -m "update" && git push
```
Other machines: `git pull && ./install.sh`.

## 📁 Repo layout
`install.sh` `bootstrap.sh` `sync.sh` `customize.sh` `record-demo.sh` · `Brewfile` · `CLAUDE.md` (agent context) · `.claude/commands/` (slash commands) · `config/` (all dotfiles) · `docs/` (the website).

<div align="center">

<br/>

[![Star](https://img.shields.io/badge/⭐_Star_this_repo-e0af68?style=for-the-badge&labelColor=1a1b26)](https://github.com/tejas-codex/vibe-terminal)
[![Website](https://img.shields.io/badge/🌐_Visit_the_site-7aa2f7?style=for-the-badge&labelColor=1a1b26)](https://tejas-codex.github.io/vibe-terminal/)

Built with [Ghostty](https://ghostty.org/) · [tmux](https://github.com/tmux/tmux) · [Claude Code](https://www.anthropic.com/claude-code) — open source, MIT.

<img src="https://capsule-render.vercel.app/api?type=waving&reverse=true&height=120&color=0:9ece6a,40:7dcfff,75:bb9af7,100:7aa2f7" width="100%"/>

</div>
