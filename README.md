# dotfiles

**⚙️ macOS configuration for Apple Silicon, managed with [GNU Stow](https://www.gnu.org/software/stow/)**

[![check](https://github.com/itsdanieldk/dotfiles/actions/workflows/check.yml/badge.svg)](https://github.com/itsdanieldk/dotfiles/actions/workflows/check.yml)
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](LICENSE.md)
![macOS arm64](https://img.shields.io/badge/macOS-arm64-000000.svg?logo=apple)
![zsh](https://img.shields.io/badge/shell-zsh-4EAA25.svg)

Every non-hidden top-level directory is a stow package that mirrors `$HOME`: `zsh/.zshrc` becomes `~/.zshrc`. One
interactive `./install` sets up the rest.

- **Leaf-only symlinks** — `--no-folding` keeps `~/.ssh` and `~/.claude` real directories, so secrets stay out of git
- **One installer** — asks before each step and each package, and skips what is already there
- **Catppuccin Frappé everywhere** — Ghostty, Neovim, Starship, bat, btop, delta, fzf, k9s, lazygit
- **Private by default** — telemetry off, allowlist `.gitignore`s for credentials
- **Checked** — a pre-commit hook and CI run gitleaks, zsh syntax, shellcheck, config parsing and Brewfile lint

> **Apple Silicon only.** Every Homebrew path assumes `/opt/homebrew`, and `install` exits on an Intel Mac.

## Install

```zsh
git clone https://github.com/itsdanieldk/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install
```

`install` asks before each step: Xcode Command Line Tools, Homebrew, the Brewfile packages, stow, then macOS defaults.
It asks for this Mac's profile once and remembers it. To sync later, `dotup` pulls, refuses a tip not signed by
`allowed_signers`, and runs `install`.

| Flag | Effect |
|------|--------|
| `--profile=NAME` | Add `Brewfile.NAME` to the shared `Brewfile`; remembered in `~/.config/dotfiles/profile` |
| `--yes`, `-y` | Yes to every prompt except the security-weakening one. Prime sudo first with `sudo -v` |
| `--adopt` | Resolve stow conflicts by moving `$HOME` files into the repo. **Destructive** — review `git diff` after |
| `--allow-insecure` | With `--yes`, also accept the security-weakening prompt |

## Packages

| Package | Contents |
|---------|----------|
| `bat` | Theme and style |
| `btop` | Catppuccin theme; `install` seeds `btop.conf`, which btop rewrites on exit |
| `claude` | Claude Code settings that deny reads of keys, credentials and `.env` files; a vendored statusline |
| `gh` | GitHub CLI config; the token in `hosts.yml` stays untracked |
| `ghostty` | Fira Code Nerd Font; left Option as Alt, so right Option still types Danish characters |
| `git` | delta, LFS, SSH-signed commits and tags, global ignore |
| `hushlogin` | Silences "Last login" |
| `k9s` | Transparent Catppuccin skin; `.zprofile` points `K9S_CONFIG_DIR` at `~/.config/k9s` |
| `lazygit` | Catppuccin theme, delta diffs |
| `nvim` | Quick-edit Neovim: file tree, treesitter, git signs, fzf; six `vim.pack` plugins, no LSP |
| `ssh` | Keychain agent, hardened algorithms |
| `starship` | Catppuccin Powerline prompt with git, language, Docker and exit-status segments |
| `zsh` | zimfw with completions, fzf-tab, syntax highlighting, substring search and autosuggestions; fzf, zoxide |

`.claude/` holds this repo's own Claude Code skills, not a `$HOME` config.

## Homebrew

`install` reads these in order and offers each entry not yet installed. Together they mirror the machine 1:1; the only
third-party tap is `gigalixir/brew`.

| File | Holds |
|------|-------|
| [`Brewfile`](Brewfile) | What every Mac gets |
| [`Brewfile.personal`](Brewfile.personal) | Games, hardware utilities, personal projects and App Store apps (`--profile=personal`) |
| `Brewfile.local` | Untracked: this machine only |

## Machine-local files

Untracked and optional; each is read only if it exists.

| File | Holds |
|------|-------|
| `~/.ssh/config.local` | Extra SSH hosts, read before `Host *` |
| `git/.config/git/config-work` | The work identity for repos under `~/work/` |
| `~/.zprofile.local`, `~/.zshrc.local` | Machine-only environment, such as a proxy or company CA certificates |

## macOS defaults

| Area | Changes |
|------|---------|
| Finder | Extensions, path and status bars; list view, folders first; new windows at home; empty desktop; visible `~/Library`; Trash emptied after 30 days; no `.DS_Store` on network or USB volumes |
| Dock & desktop | 46 px tiles magnifying to 106 px, no recents, Spaces keep their order, no Quick Note hot corner, wallpaper click keeps windows |
| Keyboard | Key repeat faster than System Settings allows, no accent picker, no text substitutions, full keyboard access, Globe key off |
| Screenshots | To the clipboard without a shadow; recordings to `~/Pictures/Screenshots` |
| Miscellaneous | Expanded save and print dialogs, local saves instead of iCloud, no swipe navigation, seconds in the clock, no Time Machine prompts, plain-text TextEdit |
| Gatekeeper | Optional: no first-run warning for downloaded apps. Skipped by `--yes` unless `--allow-insecure` |

## Privacy

Telemetry is off for dotnet, azure-cli and Homebrew (`.zprofile`), gh (`config.yml`) and Claude Code (its settings
`env`). The vendored statusline calls only Anthropic's usage API; its update check is off.

## License

[Unlicense](LICENSE.md), except `claude/.claude/statusline.sh`, vendored from
[ClaudeCodeStatusLine](https://github.com/daniel3303/ClaudeCodeStatusLine): MIT, Copyright (c) 2025 Daniel Oliveira.
