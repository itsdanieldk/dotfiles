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
5. Oh My Zsh custom plugins (zsh-autosuggestions, zsh-syntax-highlighting)
6. macOS defaults (Finder, Dock, keyboard, screenshots, trackpad, Safari)
7. Stow dotfile linking (with conflict detection)

Pass `--yes` or `-y` for non-interactive mode.

## Stow Packages

| Package | Contents |
|---------|----------|
| `bat` | bat config (Catppuccin Mocha theme) |
| `claude` | Claude Code settings and statusline |
| `git` | `.gitconfig` with delta pager, global gitignore |
| `hushlogin` | Suppresses "Last login" message |
| `kitty` | Kitty terminal (Catppuccin Mocha, FiraCode Nerd Font) |
| `lazygit` | lazygit config (Catppuccin Mocha theme, delta pager) |
| `nvim` | Neovim (lazy.nvim, Treesitter, Telescope, Catppuccin Mocha) |
| `ssh` | SSH config with macOS Keychain, hardened algorithms |
| `zsh` | `.zshrc` (Oh My Zsh + Powerlevel10k, fzf, zoxide, direnv, aliases), `.p10k.zsh`, `.zprofile` |

## Zsh Plugins

**Built-in** (ship with Oh My Zsh): `git`, `macos`, `sudo`, `extract`, `copypath`, `copyfile`, `colored-man-pages`, `docker`, `dotnet`, `aliases`

**External** (cloned during install):

| Plugin | What it does |
|--------|-------------|
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like suggestions from history; press `→` to accept |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Colors valid commands green, invalid red |

## macOS Defaults

The install script can configure:

- **Finder** — show hidden files, extensions, path/status bar, list view, folders on top, search current folder
- **Dock** — auto-hide, minimize to app icon, hide recent apps, no space rearranging
- **Keyboard** — fast key repeat, no auto-correct/smart quotes/smart dashes, full keyboard access
- **Screenshots** — save to `~/Pictures/Screenshots`, PNG format, no shadow
- **Trackpad** — three-finger drag
- **Misc** — expanded save/print panels by default

## Re-stow

```zsh
stow -d ~/dotfiles -R <package>
```
