<div align="center">

# dotfiles

<p><strong>⚙️ macOS configuration, managed with <a href="https://www.gnu.org/software/stow/">GNU Stow</a></strong></p>

<p>
  <a href="https://support.apple.com/macos"><img src="https://img.shields.io/badge/platform-macOS%20arm64-000000.svg?logo=apple" alt="Platform: macOS arm64"></a>
  <a href="https://www.zsh.org"><img src="https://img.shields.io/badge/shell-zsh-4EAA25.svg" alt="Shell: zsh"></a>
  <a href="https://www.gnu.org/software/stow/"><img src="https://img.shields.io/badge/managed%20with-GNU%20Stow-4E9A06.svg" alt="Managed with GNU Stow"></a>
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/license-Unlicense-blue.svg" alt="License: Unlicense"></a>
</p>

</div>

---

Every non-hidden top-level directory is a [stow](https://www.gnu.org/software/stow/) package whose
contents mirror `$HOME` — `zsh/.zshrc` becomes `~/.zshrc` — and one interactive `./install` links the
lot. macOS on **Apple Silicon** only: every Homebrew path hardcodes `/opt/homebrew`.

- **Leaf-only symlinks** — `--no-folding` keeps `~/.ssh` and `~/.claude` real directories, so runtime state and secrets never land in the repo
- **One interactive installer** — `./install` prompts per step and per package, from a commented [`Brewfile`](Brewfile)
- **Catppuccin Frappé everywhere** — Ghostty, Neovim, bat, btop, lazygit, delta, fzf
- **Private by default** — telemetry opt-outs in `.zprofile`, allowlist `.gitignore`s for credentials
- **No CI, no tests** — `zsh -n install` plus a `stow -n` dry run, wrapped in the `/dotfiles-check` skill

## Install

```zsh
git clone https://github.com/itsdanieldk/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install
```

Seven prompted steps, in order: Xcode Command Line Tools, Homebrew, Brewfile packages (taps first,
then formulae, then casks, skipping what's installed), stow, Oh My Zsh, Powerlevel10k and three
plugins, macOS defaults. A btop theme seed runs unprompted after stow, only if there's no
`~/.config/btop/btop.conf`.

| Flag | Effect |
|------|--------|
| `--yes` / `-y` | Auto-yes every prompt **except** the security-weakening ones, which are skipped with a warning. Also sets `NONINTERACTIVE=1` for the Homebrew bootstrap, which then uses `sudo -n` — prime it with `sudo -v` |
| `--adopt` | Resolve stow conflicts by adopting `$HOME` files into the repo. **Destructive** — it overwrites tracked configs, so review `git diff` afterwards |
| `--allow-insecure` | Also auto-yes the security-weakening prompts. Only meaningful with `--yes` |

- **arm64 is a hard requirement** — `install` checks `uname -m` and **exits 3** on an Intel Mac rather than half-installing in silence
- **It's zsh, not bash** — `read -q`, `print`, `*(/)`; syntax-check with `zsh -n install`, never shellcheck
- **Stow runs before Oh My Zsh** — OMZ's `--keep-zshrc` only protects a `~/.zshrc` that already exists, so on a clean machine it would write its own template and the stow step would then die on the conflict
- **One prompt weakens a security control** — it disables the Gatekeeper "downloaded from the internet" warning (`LSQuarantine`). Answer `N` to keep it; `--yes` declines it automatically
- **Upstreams are unpinned** — both bootstraps, Powerlevel10k and the plugins track a default branch, so a compromised upstream runs as your user. Both bootstraps verify the download before running it. Install Homebrew and Oh My Zsh yourself first if you'd rather not take the trade; `install` skips both when present
- **Failures warn rather than abort** — only an unknown flag (exit 2), a stow conflict (exit 1) and a non-arm64 machine (exit 3) stop the run

## Packages

| Package | Contents |
|---------|----------|
| `bat` | bat config |
| `btop` | btop theme — `install` seeds `color_theme` separately, because btop rewrites its own config on exit and would write through the symlink |
| `claude` | Claude Code settings and statusline |
| `ghostty` | Ghostty terminal (Fira Code Nerd Font Mono) |
| `git` | `.gitconfig` with the delta pager, plus the global gitignore. Repos under `~/work/` use a separate identity from an untracked `config-work`; git ignores the `includeIf` when it's absent |
| `hushlogin` | Suppresses the "Last login" message |
| `lazygit` | lazygit config (delta diff renderer) |
| `nvim` | Neovim — zero plugins, no lockfile; `init.lua` and a vendored colorscheme |
| `ssh` | SSH config with macOS Keychain and hardened algorithms. Machine-local hosts go in the untracked `~/.ssh/config.local`, included first |
| `zsh` | `.zshrc` (Oh My Zsh + Powerlevel10k, fzf, zoxide, direnv, aliases), `.p10k.zsh`, `.zprofile` |

`.claude/` is this repo's own tooling — the `dotfiles-check` and `new-package` skills — not a `$HOME`
config. It needs no exclusion: the installer globs `*(/)`, which doesn't match dotted directories.

`zsh` expects ten Oh My Zsh built-ins and three external plugins that `install` clones. Their order
in `plugins=()` is load-bearing.

| Plugin | What it does |
|--------|--------------|
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Replaces tab completion with an fzf menu, with bat and eza previews |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like suggestions from history; `→` accepts |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Valid commands green, invalid red |

## Homebrew

The [`Brewfile`](Brewfile) is a catalogue, not a manifest — `install` prompts per entry and doesn't
remember a decline. A hand-rolled regex parses it instead of `brew bundle`, so the `verb "name"`
shape is load-bearing: any other line is skipped silently. Two taps are declared, `azure/functions`
and `azure/bicep`, each granted trust as it's added and each kept above the packages drawn from it.

| Group | Formulae |
|-------|----------|
| Core | `stow`, `git`, `neovim` |
| Modern CLI replacements | `bat`, `dust`, `eza`, `fd`, `ripgrep`, `zoxide` |
| Shell utilities | `direnv`, `fzf`, `tealdeer`, `tree` |
| Data processing | `jq`, `yq` |
| System monitoring | `btop`, `fastfetch` |
| Git | `gh`, `git-delta`, `lazygit` |
| Containers | `docker`, `docker-compose`, `lazydocker` |
| Languages & runtimes | `mise`, `elixir`, `elm`, `node`, `pnpm`, `powershell` — `mise` owns the project node; `node` is declared only because `azurite` and `marp-cli` depend on it |
| Azure | `azure-cli`, `azure-dev`, `azure-functions-core-tools@4`, `azurite`, `bicep` |
| Authoring & linting | `marp-cli`, `shellcheck` |

| Group | Casks |
|-------|-------|
| Fonts | Fira Code Nerd Font, Fira Sans |
| Terminal & editors | Ghostty, JetBrains Toolbox, VS Code |
| Dev tooling | .NET SDK, OrbStack, Yaak |
| Windows compatibility | CrossOver — the one entry that still needs Rosetta 2 |
| AI | Claude, Claude Code, Copilot CLI |
| Notes & productivity | Obsidian |
| Browsers & media | Chrome, IINA |
| Communication & remote access | Discord, TeamViewer |
| System & hardware | Focusrite Control 2, logi-options+, macs-fan-control, MonitorControl, OnyX, Philips Hue Sync, Thaw |

## macOS Defaults

Five groups, each prompted separately — plus the Gatekeeper prompt above, which runs between
Finder and Dock:

- **Finder** — extensions, path and status bars, list view, folders on top, search scoped to the current folder, visible `~/Library`, no `.DS_Store` on network or USB volumes
- **Dock** — minimize into the app icon, no recents, fixed tile size with magnification off, Spaces stay put, faster Mission Control
- **Keyboard** — key repeat faster than the sliders can express (`KeyRepeat=1.5`, `InitialKeyRepeat=12`, in 15 ms ticks), every text substitution off because smart quotes corrupt pasted code, full keyboard access. Takes effect after a logout
- **Screenshots** — PNGs to `~/Pictures/Screenshots`, no drop shadow
- **Miscellaneous** — save and print panels expanded by default

## Privacy

`.zprofile` opts out of telemetry for every tool here that collects it, in one auditable block.

| Variable | Tool |
|----------|------|
| `DOTNET_CLI_TELEMETRY_OPTOUT=1` | dotnet CLI |
| `FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1` | Azure Functions Core Tools |
| `AZURE_CORE_COLLECT_TELEMETRY=0` | azure-cli |
| `AZURE_DEV_COLLECT_TELEMETRY=no` | azd |
| `HOMEBREW_NO_ANALYTICS=1` | Homebrew |

These reach anything launched from a shell that sourced `.zprofile` — including VS Code's integrated
terminal, but not apps launched from Finder. `brew analytics off` is the persistent equivalent.

Two outbound calls aren't covered, both from the vendored
[`statusline.sh`](https://github.com/daniel3303/ClaudeCodeStatusLine), on every statusline render.

| Call | Frequency | Notes |
|------|-----------|-------|
| `api.anthropic.com/api/oauth/usage` | ≤ every 60s, cached | Your usage quota. Sends an OAuth token from the Keychain, passed to `curl` via `--config` on stdin so it never shows in `ps` |
| `api.github.com/.../releases/latest` | ≤ every 24h, cached | Upstream update check. Disable with `STATUSLINE_CHECK_UPDATES=false` |

Only the update check is switchable — the usage call is what the statusline exists to display. It
inherits Claude Code's environment, so `.zprofile` covers a shell-launched Claude Code but not one
started from Finder; use `launchctl setenv` for that.

## Gotchas

- **A new file in an existing package needs a re-stow** — `stow -d ~/dotfiles --no-folding -R <package>`. Editing an existing file takes effect immediately; adding one does nothing until you re-stow
- **Apps rewrite their own stowed configs** — the write goes through the symlink and lands as an unexplained modification in `git status`. lazygit did it renaming `git.pagers`; OrbStack did it twice. Check `git status` after installing anything that manages its own config
- **`.zshrc` load order is load-bearing** — p10k's instant prompt first with nothing writing to stdout before it, and `fzf-tab` before `zsh-autosuggestions` and `zsh-syntax-highlighting`, or completion and highlighting break without saying so
- **The Brewfile is read from FD 3** — `ask()`'s `read -q` consumes stdin, so a plain `< Brewfile` makes every prompt eat the next line and silently skip packages
- **Two ignore files, different scopes** — `/.gitignore` is allowlist-based, so a tracked file added to `ssh/` or `claude/` needs a matching `!` line or git never sees it; `git/.config/git/ignore` applies to **every** repo on the machine. Neither has trailing-comment syntax

## License

Public domain under [The Unlicense](LICENSE.md), with one exception:
`claude/.claude/statusline.sh` is vendored from
[ClaudeCodeStatusLine](https://github.com/daniel3303/ClaudeCodeStatusLine) and stays MIT,
Copyright (c) 2025 Daniel Oliveira; its notice is retained in the file header.
