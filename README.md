<div align="center">

# ⚙️ dotfiles

<p><strong>macOS configuration, managed with <a href="https://www.gnu.org/software/stow/">GNU Stow</a></strong></p>

<p>
  <a href="https://github.com/itsdanieldk/dotfiles/actions/workflows/lint.yml"><img src="https://github.com/itsdanieldk/dotfiles/actions/workflows/lint.yml/badge.svg" alt="lint"></a>
  <img src="https://img.shields.io/badge/platform-macOS-000000.svg?logo=apple" alt="Platform: macOS">
  <img src="https://img.shields.io/badge/shell-zsh-4EAA25.svg" alt="Shell: zsh">
  <img src="https://img.shields.io/badge/managed%20with-GNU%20Stow-4E9A06.svg" alt="Managed with GNU Stow">
  <img src="https://img.shields.io/badge/theme-Catppuccin%20Frapp%C3%A9-8caaee.svg" alt="Theme: Catppuccin Frappé">
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/license-Unlicense-blue.svg" alt="License: Unlicense"></a>
</p>

</div>

---

Every top-level directory is a [stow](https://www.gnu.org/software/stow/) package whose contents
mirror `$HOME` (`zsh/.zshrc` → `~/.zshrc`), linked by a single interactive `./install`. Assumes
macOS with zsh; Homebrew is detected at both the Apple Silicon (`/opt/homebrew`) and Intel
(`/usr/local`) prefixes. Everything is tuned for one specific machine — see [Requirements](#requirements).

- **Leaf-only symlinks** — stow runs `--no-folding`, so app-managed directories (`~/.ssh`, `~/.claude`) stay real folders and only tracked files are linked; runtime state and secrets never land inside the repo
- **One interactive installer** — `./install` prompts y/N before each step and is driven by a commented [`Brewfile`](Brewfile) that is the source of truth for packages
- **Catppuccin Frappé everywhere** — kitty, Neovim, bat, btop, lazygit, delta, fzf, SketchyBar and JankyBorders share one palette
- **Tuned for one machine** — a Mac Studio (M4 Max) driving a single 2560×1440 external; AeroSpace and SketchyBar assume exactly that
- **Layout-aware keys** — workspaces live on `ctrl-<digit>`, because `alt-<digit>` is where the Danish layout hides `[ ] { } \`
- **Private by default** — `.zprofile` opts out of every telemetry channel in the stack, and allowlist `.gitignore`s keep credentials uncommittable

## Requirements

macOS with zsh, and [GNU Stow](https://www.gnu.org/software/stow/) (installed by the Brewfile). The
window-manager and status-bar configs assume a **Mac Studio (M4 Max) driving one 2560×1440 external
display** — no battery, no built-in display, no notch. AeroSpace and SketchyBar are tuned for exactly
that: no per-monitor gaps, no forced workspace-to-monitor assignment, no notch arithmetic.
Reintroducing multi-monitor or laptop assumptions needs a second display actually present.

## Install

```zsh
git clone https://github.com/itsdanieldk/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install
```

`install` is a **zsh** script (it uses `read -q`, `print` and the `*(/)` glob qualifier), so
shellcheck can't read it — syntax-check with `zsh -n install`. It prompts (y/N) before each step:

1. Xcode Command Line Tools
2. Homebrew
3. Brewfile packages (skips already installed)
4. .NET global tools (`dotnet-ef`, `dotnet-outdated-tool`; skips already installed)
5. Oh My Zsh
6. Oh My Zsh theme (powerlevel10k)
7. Oh My Zsh custom plugins (fzf-tab, zsh-autosuggestions, zsh-syntax-highlighting)
8. macOS defaults (Finder, Dock, menu bar, keyboard, launcher, screenshots, trackpad, misc power-user)
9. Stow dotfile linking (errors on conflict by default)

Step 8 includes a separate, individually-prompted step that **disables the Gatekeeper "downloaded
from the internet" warning** (`LSQuarantine`). It is the one prompt that weakens a security control —
answer `N` to keep the warning.

Flags:

- `--yes` / `-y` — non-interactive (auto-yes to all prompts)
- `--adopt` — allow stow to resolve conflicts by adopting `$HOME` files into the repo (**destructive**: overwrites tracked configs; review `git diff` after)

## Stow Packages

| Package | Contents |
|---------|----------|
| `aerospace` | [AeroSpace](https://github.com/nikitabobko/AeroSpace) tiling WM. Numeric workspaces on `ctrl-1`–`ctrl-9` (**not** `alt` — that is where a Danish layout keeps `[ ] { } \`), focus/move on `alt-hjkl`. Launches `borders` and `sketchybar` at startup. Needs Accessibility permission |
| `bat` | bat config (Catppuccin Frappé theme) |
| `borders` | [JankyBorders](https://github.com/FelixKratz/JankyBorders) focus ring (`bordersrc`), Catppuccin Frappé mauve/surface1. Started by AeroSpace, not `brew services`, so it reads the stowed config |
| `btop` | btop Catppuccin Frappé theme (the install script seeds `color_theme = "catppuccin_frappe"` for you) |
| `claude` | Claude Code settings and statusline |
| `git` | `.gitconfig` with delta pager, global gitignore. Repos under `~/work/` commit with the work identity — the rule is inert until that directory exists |
| `hushlogin` | Suppresses the "Last login" message |
| `kitty` | Kitty terminal (Catppuccin Frappé, Fira Code Nerd Font Mono) |
| `lazygit` | lazygit config (Catppuccin Frappé theme, delta pager) |
| `nvim` | Neovim (lazy.nvim, Treesitter, Telescope, Catppuccin Frappé) |
| `raycast` | [Raycast](https://www.raycast.com) script commands. Raycast's own settings are not file-based, so only this directory is tracked — add it under Settings > Script Commands > Add Script Directory |
| `sketchybar` | [SketchyBar](https://github.com/FelixKratz/SketchyBar) status bar with plugins and Swift helpers. Driven by AeroSpace workspace-change events; lint with [`scripts/lint-sketchybar.sh`](scripts/lint-sketchybar.sh) |
| `ssh` | SSH config with macOS Keychain, hardened algorithms. Put machine-local hosts in `~/.ssh/config.local` (included first, untracked) |
| `zsh` | `.zshrc` (Oh My Zsh + Powerlevel10k, fzf, zoxide, direnv, aliases), `.p10k.zsh`, `.zprofile` |

## Homebrew Packages

Installed from the [`Brewfile`](Brewfile) (step 3), which is grouped and commented — treat it as the
source of truth. By group:

**Formulae**

- **Core** — `stow`, `git`, `neovim`
- **Modern CLI replacements** — `ripgrep`, `fd`, `bat`, `eza`, `fzf`, `jq`, `zoxide`, `media-control`
- **Utilities** — `fastfetch`, `btop`, `dust`, `yq`, `tealdeer`, `tree`, `marp-cli`
- **Git & dev tools** — `gh`, `git-delta`, `lazygit`, `lazydocker`, `shellcheck`
- **Languages & runtimes** — `node`, `pnpm`, `elixir`, `elm`, `powershell`, with `direnv` for per-project env
- **Azure** — `azure-cli`, `azd`, `azure-functions-core-tools@4`, `azurite` (Storage emulator), `bicep`
- **Containers & Kubernetes** — `docker`, `docker-compose`, `kubectl`, `helm`, `k9s`, and Azure's `kubelogin` for AKS/Entra ID auth
- **Window management & bar** — `borders` (JankyBorders), `sketchybar`, `ical-buddy` and `macmon` (both feed SketchyBar)
- **AI** — `ollama`

**Casks**

- **Fonts** — Fira Code Nerd Font, Fira Sans
- **Terminal & editors** — Kitty, VS Code, JetBrains Toolbox
- **Dev tooling** — .NET SDK 10, Docker Desktop, Yaak
- **AI** — Claude, Claude Code, Codex, Copilot CLI
- **Notes & productivity** — Obsidian, Raycast
- **Browsers & media** — Chrome, IINA, Discord
- **Remote access** — TeamViewer
- **Window management** — AeroSpace
- **System & hardware** — MonitorControl, macs-fan-control, logi-options+, Focusrite Control 2, OnyX, Philips Hue Sync
- **Games** — Steam

Several packages come from third-party taps (`isen-ng`, Azure's, `nikitabobko`, `FelixKratz`).
Homebrew 6+ refuses to load from an untrusted tap, so the install script grants each declared tap
trust as it adds it.

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
- **Menu bar** — optionally auto-hide it (offered only if SketchyBar starts at login, so the two bars don't stack)
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

These reach anything launched from a shell that sourced `.zprofile`, which includes VS Code's
integrated terminal but not apps launched from Finder. For a setting that holds regardless of
environment, `brew analytics off` writes Homebrew's own persistent config.

## Ignore files

Two, with different scopes:

- **`.gitignore`** — this repo only. Mostly allowlists: the `ssh` and `claude` packages ignore
  everything and re-include just the tracked configs, so app runtime state and credentials can't be
  committed.
- **`git/.config/git/ignore`** — stowed to `~/.config/git/ignore` and applied to **every** repo on
  the machine. Git finds it there automatically; no `core.excludesfile` needed.

Note that gitignore has no trailing-comment syntax — `pattern  # note` silently stops matching. Keep
comments on their own lines.

## Gotchas

Each of these has been rediscovered more than once. Some fail *silently*.

> **A new file in an existing package needs a re-stow.** Because stow runs `--no-folding`,
> directories are real and only tracked leaf files are symlinked. Editing an existing file takes
> effect immediately; adding a *new* one does not until you re-stow that package.

> **Workspaces are on `ctrl`, not `alt` — leave them there.** On the Danish layout `[ ] { } \` live
> on the Option layer of the digit row, so binding `alt-<digit>` makes them untypable system-wide.
> `cmd` is not an escape (`cmd-alt-8` → `[`). The same holds for Norwegian/Swedish/Finnish/German.

> **`.zshrc` load order is load-bearing.** Powerlevel10k's instant prompt must come first — nothing
> may print to stdout before it — and in `plugins=()` **`fzf-tab` must precede `zsh-autosuggestions`
> and `zsh-syntax-highlighting`**, or completion and highlighting silently break.

> **SketchyBar fails silently.** An item that hides itself with `drawing=off` must also set
> `updates=on` or it never runs again; new plugin scripts need `chmod +x`; and a plugin has less TCC
> access than your terminal, so a read that works by hand can `EPERM` in the bar.
> [`scripts/lint-sketchybar.sh`](scripts/lint-sketchybar.sh) catches the first kinds.

> **The installer reads the Brewfile from FD 3.** `ask()`'s `read -q` consumes stdin, so the package
> loop uses `... <&3; done 3< Brewfile`. Converting it to a plain `< Brewfile` makes every prompt eat
> the next line, silently skipping packages.

## Re-stow

```zsh
stow -d ~/dotfiles --no-folding -R <package>
```

## License

Released into the public domain under [The Unlicense](LICENSE.md). Take any of it.
