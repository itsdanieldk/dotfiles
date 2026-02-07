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
3. Brewfile packages (each one individually)
4. Oh My Zsh
5. Oh My Zsh custom plugins (zsh-autosuggestions, zsh-syntax-highlighting)
6. macOS defaults (Finder, Dock, keyboard, screenshots, Safari)
7. Stow dotfile linking

## Stow Packages

| Package | Contents |
|---------|----------|
| `git` | `.gitconfig`, global gitignore (`~/.config/git/ignore`) |
| `zsh` | `.zshrc` (Oh My Zsh, awesomepanda theme, plugins), `.zprofile` |
| `kitty` | Kitty terminal (Catppuccin Mocha, FiraCode Nerd Font) |
| `ssh` | SSH config with macOS Keychain integration |
| `nvim` | Neovim configuration (placeholder) |
| `hushlogin` | Suppresses "Last login" message |

## Zsh Plugins

**Built-in** (ship with Oh My Zsh): `git`, `macos`, `sudo`, `extract`, `copypath`, `copyfile`, `colored-man-pages`, `docker-compose`, `aliases`

**External** (cloned during install):

| Plugin | What it does |
|--------|-------------|
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like suggestions from history; press `→` to accept |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Colors valid commands green, invalid red |

## macOS Defaults

The install script can configure:

- **Finder** — show hidden files, extensions, path/status bar, list view, folders on top
- **Dock** — minimize to app icon, hide recent apps
- **Keyboard** — fast key repeat, no auto-correct/smart quotes/smart dashes, full keyboard access
- **Screenshots** — save to `~/Pictures/Screenshots`, PNG format, no shadow
- **Safari** — enable Develop menu and Web Inspector, show full URL

## Re-stow

```zsh
stow -d ~/dotfiles -R <package>
```
