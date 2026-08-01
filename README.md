# dotfiles

macOS configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

Assumes macOS with zsh. Homebrew is detected at both the Apple Silicon
(`/opt/homebrew`) and Intel (`/usr/local`) prefixes.

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
4. .NET global tools (`dotnet-ef`, `dotnet-outdated-tool`; skips already installed)
5. Oh My Zsh
6. Oh My Zsh theme (powerlevel10k)
7. Oh My Zsh custom plugins (fzf-tab, zsh-autosuggestions, zsh-syntax-highlighting)
8. macOS defaults (Finder, Dock, keyboard, screenshots, trackpad, misc power-user)
9. Stow dotfile linking (errors on conflict by default)

Step 8 includes a separate, individually-prompted step that **disables the
Gatekeeper "downloaded from the internet" warning** (`LSQuarantine`). It is the
one prompt that weakens a security control — answer `N` to keep the warning.

Flags:
- `--yes` / `-y` — non-interactive (auto-yes to all prompts)
- `--adopt` — allow stow to resolve conflicts by adopting `$HOME` files into the repo (**destructive**: overwrites tracked configs; review `git diff` after)

## Homebrew Packages

Installed from the [`Brewfile`](Brewfile) (step 3), which is grouped and commented —
treat it as the source of truth. By group:

**Formulae**

- **Core** — `stow`, `git`, `neovim`
- **Modern CLI replacements** — `ripgrep`, `fd`, `bat`, `eza`, `fzf`, `jq`, `zoxide`
- **Utilities** — `btop`, `dust`, `yq`, `tealdeer`, `tree`, `fastfetch`, `marp-cli`
- **Git & dev tools** — `gh`, `git-delta`, `lazygit`, `lazydocker`
- **Languages & runtimes** — `node`, `pnpm`, `elixir`, `elm`, `powershell`, with `direnv` for per-project env
- **Azure** — `azure-cli`, `azd`, `azure-functions-core-tools@4`, `azurite` (Storage emulator), `bicep`
- **Containers & Kubernetes** — `docker`, `docker-compose`, `kubectl`, `helm`, `k9s`, and Azure's `kubelogin` for AKS/Entra ID auth
- **AI** — `ollama`

**Casks**

- **Fonts** — Fira Code Nerd Font, Fira Sans
- **Terminal & editors** — Kitty, VS Code, JetBrains Toolbox
- **Dev tooling** — .NET SDK 10, Docker Desktop, Yaak
- **AI** — Claude, Claude Code, Codex, Copilot CLI
- **Notes & productivity** — Obsidian
- **Browsers & media** — Chrome, IINA, Discord
- **Remote access** — TeamViewer
- **Window management** — AeroSpace
- **System & hardware** — MonitorControl, macs-fan-control, logi-options+, Focusrite Control, Philips Hue Sync, OnyX, thaw
- **Games** — Steam

Several packages come from third-party taps (Azure's, `isen-ng`, `nikitabobko`).
Homebrew 6+ refuses to load from an untrusted tap, so the install script grants
each declared tap trust as it adds it.

## Stow Packages

| Package | Contents |
|---------|----------|
| `aerospace` | [AeroSpace](https://github.com/nikitabobko/AeroSpace) tiling WM. Numeric workspaces on `alt-1`–`alt-9`, focus/move on `alt-hjkl`. Needs Accessibility permission; does **not** start at login |
| `bat` | bat config (Catppuccin Frappé theme) |
| `btop` | btop Catppuccin Frappé theme (the install script seeds `color_theme = "catppuccin_frappe"` for you) |
| `claude` | Claude Code settings and statusline |
| `git` | `.gitconfig` with delta pager, global gitignore. Repos under `~/work/` commit with the work identity — the rule is inert until that directory exists |
| `hushlogin` | Suppresses "Last login" message |
| `kitty` | Kitty terminal (Catppuccin Frappé, Fira Code Nerd Font Mono) |
| `lazygit` | lazygit config (Catppuccin Frappé theme, delta pager) |
| `nvim` | Neovim (lazy.nvim, Treesitter, Telescope, Catppuccin Frappé) |
| `raycast` | [Raycast](https://www.raycast.com) script commands. Raycast's own settings are not file-based, so only this directory is tracked — add it under Settings > Script Commands > Add Script Directory |
| `ssh` | SSH config with macOS Keychain, hardened algorithms. Put machine-local hosts in `~/.ssh/config.local` (included first, untracked) |
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

- **Finder** — show hidden files, extensions, path/status bar, list view, folders on top, search current folder, unhide `~/Library`, no `.DS_Store` on network/USB
- **Dock** — minimize to app icon, hide recent apps, no space rearranging, icon size, faster animations (auto-hide timings are tuned, but auto-hide itself is left to you)
- **Keyboard** — fast key repeat, below what System Settings can express (`KeyRepeat=1.5`, `InitialKeyRepeat=12`, in 15 ms ticks — the slider bottoms out at 2 and 15). Also disables auto-correct, smart quotes and smart dashes, and enables full keyboard access. Takes effect after logout/login
- **Launcher** — disables the Spotlight (`⌘Space`) and Finder-search (`⌘⌥Space`) shortcuts so Raycast can take the key. `⌥Space` is deliberately *not* used: kitty runs `macos_option_as_alt left`, so it would swallow zsh's `expand-history`
- **Screenshots** — save to `~/Pictures/Screenshots`, PNG format, no shadow
- **Trackpad** — three-finger drag
- **Misc** — expanded save/print panels by default

## Privacy

`.zprofile` opts out of telemetry for every tool in this setup that collects it:

| Variable | Tool |
|---|---|
| `DOTNET_CLI_TELEMETRY_OPTOUT=1` | dotnet CLI |
| `FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1` | Azure Functions Core Tools |
| `AZURE_CORE_COLLECT_TELEMETRY=0` | azure-cli |
| `AZURE_DEV_COLLECT_TELEMETRY=no` | azd |
| `HOMEBREW_NO_ANALYTICS=1` | Homebrew |

These reach anything launched from a shell that sourced `.zprofile`, which
includes VS Code's integrated terminal but not apps launched from Finder. For a
setting that holds regardless of environment, `brew analytics off` writes
Homebrew's own persistent config.

## Ignore files

Two, with different scopes:

- **`.gitignore`** — this repo only. Mostly allowlists: the `ssh` and `claude`
  packages ignore everything and re-include just the tracked configs, so app
  runtime state and credentials can't be committed.
- **`git/.config/git/ignore`** — stowed to `~/.config/git/ignore` and applied to
  **every** repo on the machine. Git finds it there automatically; no
  `core.excludesfile` needed.

Note that gitignore has no trailing-comment syntax — `pattern  # note` silently
stops matching. Keep comments on their own lines.

## Re-stow

```zsh
stow -d ~/dotfiles --no-folding -R <package>
```
