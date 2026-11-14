# dotfiles

**⚙️ macOS configuration for Apple Silicon, managed with [GNU Stow](https://www.gnu.org/software/stow/)**

[![Platform: macOS arm64](https://img.shields.io/badge/platform-macOS%20arm64-000000.svg?logo=apple)](https://support.apple.com/macos)
[![Shell: zsh](https://img.shields.io/badge/shell-zsh-4EAA25.svg)](https://www.zsh.org)
[![Managed with GNU Stow](https://img.shields.io/badge/managed%20with-GNU%20Stow-4E9A06.svg)](https://www.gnu.org/software/stow/)
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](LICENSE.md)

---

Every non-hidden top-level directory is a stow package whose contents mirror `$HOME` — `zsh/.zshrc`
becomes `~/.zshrc` — and one interactive `./install` sets up the rest. Apple Silicon only: every
Homebrew path assumes `/opt/homebrew`.

- **Leaf-only symlinks** — `--no-folding` keeps `~/.ssh` and `~/.claude` real directories, so secrets never land in the repo
- **One interactive installer** — prompts per step and per package
- **Catppuccin Frappé everywhere** — Ghostty, Neovim, bat, btop, lazygit, delta, fzf
- **Private by default** — telemetry opt-outs, allowlist `.gitignore`s for credentials

## Install

```zsh
git clone https://github.com/itsdanieldk/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install
```

`install` asks before each step: Xcode Command Line Tools, Homebrew, the Brewfile packages, stow,
Oh My Zsh with Powerlevel10k and its plugins, then macOS defaults. Anything already installed is skipped.

| Flag | Effect |
|------|--------|
| `--yes`, `-y` | Yes to every prompt except the security-weakening one. Prime sudo first with `sudo -v` |
| `--adopt` | Resolve stow conflicts by moving `$HOME` files into the repo. **Destructive** — review `git diff` after |
| `--allow-insecure` | With `--yes`, also accept the security-weakening prompt |

> **Trade-offs.** The Homebrew and Oh My Zsh bootstraps, Powerlevel10k and its plugins track their
> default branches, unpinned. One prompt disables Gatekeeper's "downloaded from the internet"
> warning; answer `N` to keep it.

## Packages

| Package | Contents |
|---------|----------|
| `bat` | Theme and style |
| `btop` | Catppuccin theme; `install` seeds `btop.conf`, since btop rewrites it on exit |
| `claude` | Claude Code settings and a vendored statusline |
| `ghostty` | Fira Code Nerd Font, splits, left Option as Alt so right Option still types Danish characters |
| `git` | delta pager, LFS, SSH-signed commits and tags, global gitignore; an untracked work identity for `~/work/` |
| `hushlogin` | Silences "Last login" |
| `lazygit` | Catppuccin theme, delta diffs |
| `nvim` | Quick-edit Neovim: file tree, treesitter, git signs, fzf — six plugins via the built-in `vim.pack`, no LSP |
| `ssh` | Keychain agent, hardened algorithms; machine-local hosts in an untracked `~/.ssh/config.local` |
| `zsh` | Oh My Zsh + Powerlevel10k with fzf-tab, autosuggestions and syntax highlighting; fzf, mise, zoxide |

`.claude/` holds this repo's own Claude Code skills, not a `$HOME` config.

## Homebrew

The [`Brewfile`](Brewfile) is a sectioned catalogue, not a manifest: `install` offers each entry in
turn. The only third-party tap is `gigalixir/brew`.

## macOS defaults

- **Finder** — extensions, path and status bars, full path in the title, list view, folders first, search in the current folder, new windows at home, nothing on the desktop, Trash emptied after 30 days, visible `~/Library`, no `.DS_Store` on network or USB volumes
- **Desktop & Dock** — no recents, 46 px tiles magnifying to 106 px, Spaces keep their order, no Quick Note hot corner, wallpaper click doesn't hide windows, no tiling margins
- **Keyboard** — key repeat faster than System Settings allows, text substitutions off, full keyboard access, Globe key does nothing
- **Screenshots** — to the clipboard, no shadow; recordings saved to `~/Pictures/Screenshots`
- **Miscellaneous** — save and print dialogs expanded, new documents saved locally rather than to iCloud, no swipe navigation on horizontal scroll, seconds in the menu-bar clock, no Time Machine prompts for new disks, plain-text TextEdit

## Privacy

Telemetry is off for dotnet, azure-cli, Homebrew and gh (`.zprofile`) and for Claude Code (its settings
`env`). The vendored statusline calls only Anthropic's usage API; its update check is off.

## License

[Unlicense](LICENSE.md), except `claude/.claude/statusline.sh`, vendored from
[ClaudeCodeStatusLine](https://github.com/daniel3303/ClaudeCodeStatusLine): MIT, Copyright (c) 2025 Daniel Oliveira.
