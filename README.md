# dotfiles

macOS configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Install

```zsh
git clone https://github.com/itsdanieldk/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install
```

The install script interactively prompts (y/N) before each step:

1. Xcode Command Line Tools
2. Homebrew
3. Brewfile packages (skips already installed)
4. Oh My Zsh
5. Oh My Zsh custom plugins (fzf-tab, zsh-autosuggestions, zsh-syntax-highlighting)
6. macOS defaults (Finder, Dock, keyboard, screenshots, trackpad, misc power-user)
7. Stow dotfile linking (errors on conflict by default)

Flags:
- `--yes` / `-y` — non-interactive (auto-yes to all prompts)
- `--adopt` — allow stow to resolve conflicts by adopting `$HOME` files into the repo (**destructive**: overwrites tracked configs; review `git diff` after)

## Homebrew Packages

Installed from the [`Brewfile`](Brewfile) (step 3). Highlights:

- **CLI** — modern replacements (`ripgrep`, `fd`, `bat`, `eza`, `fzf`, `zoxide`), plus `jq`/`yq`, `btop`, `dust`, `tealdeer`, `tree`, `fastfetch`
- **Git & dev** — `gh`, `git-delta`, `lazygit`, `lazydocker`
- **Runtimes** — `node`, `pnpm`, `elixir`, `elm`, with `direnv` for per-project env
- **Development apps** — Kitty, VS Code, JetBrains Toolbox, Docker Desktop, .NET SDK, Yaak
- **Notes & productivity** — Obsidian
- **AI** — Claude, Claude Code, Codex, Copilot CLI, `ollama`
- **Browsers & media** — Chrome, IINA, Discord
- **System & hardware** — MonitorControl, macs-fan-control, logi-options+, Focusrite Control, Philips Hue Sync, OnyX, thaw

## Stow Packages

| Package | Contents |
|---------|----------|
| `bat` | bat config (Catppuccin Mocha theme) |
| `btop` | btop Catppuccin Mocha theme (the install script seeds `color_theme = "catppuccin_mocha"` for you) |
| `claude` | Claude Code settings and statusline |
| `git` | `.gitconfig` with delta pager, global gitignore |
| `hushlogin` | Suppresses "Last login" message |
| `kitty` | Kitty terminal (Catppuccin Mocha, JetBrains Mono Nerd Font) |
| `lazygit` | lazygit config (Catppuccin Mocha theme, delta pager) |
| `nvim` | Neovim (lazy.nvim, Treesitter, Telescope, Catppuccin Mocha) |
| `ssh` | SSH config with macOS Keychain, hardened algorithms |
| `zsh` | `.zshrc` (Oh My Zsh + Powerlevel10k, fzf, zoxide, direnv, aliases), `.p10k.zsh`, `.zprofile` |

## Zsh Plugins

**Built-in** (ship with Oh My Zsh): `git`, `macos`, `sudo`, `extract`, `copypath`, `copyfile`, `colored-man-pages`, `docker`, `dotnet`, `aliases`

**External** (cloned during install):

| Plugin | What it does |
|--------|-------------|
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Replaces zsh tab completion with an fzf-powered fuzzy menu (with bat/eza previews) |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like suggestions from history; press `→` to accept |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Colors valid commands green, invalid red |

## macOS Defaults

The install script can configure:

- **Finder** — show hidden files, extensions, path/status bar, list view, folders on top, search current folder, no `.DS_Store` on network/USB
- **Dock** — auto-hide, minimize to app icon, hide recent apps, no space rearranging
- **Keyboard** — fastest key repeat (below the UI minimum), no auto-correct/smart quotes/smart dashes, full keyboard access
- **Screenshots** — save to `~/Pictures/Screenshots`, PNG format, no shadow
- **Trackpad** — three-finger drag
- **Misc** — expanded save/print panels by default

## Re-stow

```zsh
stow -d ~/dotfiles --no-folding -R <package>
```
