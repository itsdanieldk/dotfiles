<div align="center">

# dotfiles

<p><strong>⚙️ macOS configuration, managed with <a href="https://www.gnu.org/software/stow/">GNU Stow</a></strong></p>

<p>
  <a href="https://support.apple.com/macos"><img src="https://img.shields.io/badge/platform-macOS%20arm64-000000.svg?logo=apple" alt="Platform: macOS arm64"></a>
  <a href="https://www.zsh.org"><img src="https://img.shields.io/badge/shell-zsh-4EAA25.svg" alt="Shell: zsh"></a>
  <a href="https://www.gnu.org/software/stow/"><img src="https://img.shields.io/badge/managed%20with-GNU%20Stow-4E9A06.svg" alt="Managed with GNU Stow"></a>
  <a href="https://github.com/catppuccin/catppuccin"><img src="https://img.shields.io/badge/theme-Catppuccin%20Frapp%C3%A9-8caaee.svg" alt="Theme: Catppuccin Frappé"></a>
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/license-Unlicense-blue.svg" alt="License: Unlicense"></a>
</p>

</div>

---

Every non-hidden top-level directory is a [stow](https://www.gnu.org/software/stow/) package whose
contents mirror `$HOME` exactly — `zsh/.zshrc` becomes `~/.zshrc` — and a single interactive
`./install` links the lot. There is no framework here and nothing to learn: the tree *is* the
config, and `stow` is the only moving part. Everything assumes macOS with zsh on **Apple Silicon**,
where Homebrew lives at the arm64 prefix `/opt/homebrew` with no Intel fallback, and everything is
tuned for one specific machine — a Mac Studio (M4 Max) driving a single 2560×1440 external display,
so there is no battery, no built-in display and no notch to account for.

- **Leaf-only symlinks** — stow runs `--no-folding`, so app-managed directories (`~/.ssh`, `~/.claude`) stay real folders and only tracked files are linked; runtime state and secrets never land inside the repo
- **One interactive installer** — `./install` prompts y/N before every step and per package, driven by a commented [`Brewfile`](Brewfile) you pick from at install time
- **Catppuccin Frappé everywhere** — Ghostty, Neovim, bat, btop, lazygit, delta and fzf share one palette
- **Private by default** — `.zprofile` opts out of every telemetry channel in the stack, and allowlist `.gitignore`s keep credentials uncommittable
- **No CI, no linter, no test suite** — `zsh -n install` plus a `stow -n` dry run is the entire verification surface, wrapped up in the `/dotfiles-check` agent skill

## Install

```zsh
git clone https://github.com/itsdanieldk/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install
```

arm64 is a hard requirement rather than a preference: every Homebrew path in `install` and
`.zprofile` hardcodes `/opt/homebrew`, so the script checks `uname -m` before touching anything and
**exits 3** on an Intel Mac instead of half-installing in silence. It is a **zsh** script — it uses
`read -q`, `print` and the `*(/)` glob qualifier, which shellcheck cannot parse — so syntax-check it
with `zsh -n install`, never shellcheck. It prompts before each of seven steps, in this order:
Xcode Command Line Tools, Homebrew, Brewfile packages (taps first, each granted trust, then
formulae, then casks, skipping whatever is already installed), stow linking, Oh My Zsh, the
Powerlevel10k theme and three custom plugins, and the macOS defaults. Stow deliberately runs
*before* Oh My Zsh: that installer's `--keep-zshrc` only protects a `~/.zshrc` that already exists,
so on a clean machine it would otherwise write its own template there and the stow step would then
die on the conflict. A btop theme seed runs unprompted straight after stow, and only when
there is no `~/.config/btop/btop.conf` yet. Failures are non-fatal by design and warn rather than abort; only an
unknown flag (exit 2), a stow conflict (exit 1) and a non-arm64 machine (exit 3) stop the run.

One prompt inside the macOS defaults step weakens a security control: it **disables the Gatekeeper
"downloaded from the internet" warning** (`LSQuarantine`). Answer `N` to keep the warning. Under
`--yes` it is declined automatically rather than auto-approved, so an unattended bootstrap can never
silently turn it off.

| Flag | Effect |
|------|--------|
| `--yes` / `-y` | Non-interactive — auto-yes to every prompt **except** the security-weakening ones, which are skipped with a warning. It reaches the Homebrew bootstrap too (`NONINTERACTIVE=1`), which switches that installer to `sudo -n`, so prime sudo with `sudo -v` first on a fresh machine |
| `--adopt` | Let stow resolve conflicts by adopting `$HOME` files into the repo. **Destructive**: it overwrites tracked configs, so review `git diff` afterwards |
| `--allow-insecure` | Also auto-yes the prompts that weaken a security control. Only meaningful together with `--yes` |

Four steps execute code fetched from the network — the Homebrew bootstrap from
`raw.githubusercontent.com/Homebrew/install` at `HEAD`, the Oh My Zsh bootstrap from
`ohmyzsh/ohmyzsh` at `master`, Powerlevel10k and three plugins as `--depth=1` clones of their
default branches, and the Brewfile packages themselves from Homebrew plus two declared Azure taps.
All of them track a moving target rather than a pinned revision. That is deliberate: pinning would
mean hand-bumping five revisions to stay current and secure, and these are the same installers their
own documentation tells you to pipe into a shell. The trade is explicit rather than accidental — a
compromised upstream runs with your user's privileges. Both bootstraps verify the download succeeded
before running it and warn instead of aborting, so a failed fetch can never be mistaken for a
successful install. If you would rather not take that trade, install Homebrew and Oh My Zsh yourself
first; `install` skips both steps when it finds them present.

## Packages

Each row is a stow package: its contents mirror `$HOME`, and `install` links every one of them.

| Package | Contents |
|---------|----------|
| `bat` | bat config (Catppuccin Frappé theme) |
| `btop` | btop Catppuccin Frappé theme — `install` seeds `color_theme` separately, because btop rewrites its own config on exit and would otherwise write through the symlink into the repo |
| `claude` | Claude Code settings and statusline |
| `ghostty` | Ghostty terminal (Catppuccin Frappé, Fira Code Nerd Font Mono) |
| `git` | `.gitconfig` with the delta pager, plus the global gitignore. Repos under `~/work/` commit with a separate work identity, kept in an untracked `config-work` alongside it — git ignores the `includeIf` when that file is absent, so a fresh clone just uses the personal identity |
| `hushlogin` | Suppresses the "Last login" message |
| `lazygit` | lazygit config (Catppuccin Frappé theme, delta diff renderer) |
| `nvim` | Neovim — zero plugins, no plugin manager, no lockfile; just `init.lua` and a vendored colorscheme |
| `ssh` | SSH config with macOS Keychain and hardened algorithms. Machine-local hosts go in `~/.ssh/config.local`, which is included first and untracked |
| `zsh` | `.zshrc` (Oh My Zsh + Powerlevel10k, fzf, zoxide, direnv, aliases), `.p10k.zsh` and `.zprofile` |

`.claude/` holds this repo's own tooling — the `dotfiles-check` and `new-package` agent skills — not
a `$HOME` config. It is deliberately not a stow package, and needs no exclusion list to stay out of
one: the installer globs `*(/)`, which does not match dotted directories.

The `zsh` package expects ten Oh My Zsh built-ins (`git`, `macos`, `sudo`, `extract`, `copypath`,
`copyfile`, `colored-man-pages`, `docker`, `dotnet`, `aliases`) and three external plugins that
`install` clones for you. Their order in `plugins=()` is load-bearing.

| Plugin | What it does |
|--------|--------------|
| [fzf-tab](https://github.com/Aloxaf/fzf-tab) | Replaces zsh tab completion with an fzf fuzzy menu, with bat and eza previews |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like suggestions from history; press `→` to accept |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Colors valid commands green, invalid red |

## Homebrew

The [`Brewfile`](Brewfile) is a catalogue, not a manifest — `install` prompts per entry and a decline
is not remembered, so not everything listed is installed on any given machine. It is parsed by a
hand-rolled regex rather than `brew bundle`, which makes the `verb "name"` shape load-bearing: any
line that does not match is silently skipped.

| Group | Formulae |
|-------|----------|
| Core | `stow`, `git`, `neovim` |
| Modern CLI replacements | `bat`, `dust`, `eza`, `fd`, `ripgrep`, `zoxide` |
| Shell utilities | `direnv`, `fzf`, `tealdeer`, `tree` |
| Data processing | `jq`, `yq` |
| System monitoring | `btop`, `fastfetch` |
| Git | `gh`, `git-delta`, `lazygit` |
| Containers | `docker`, `docker-compose`, `lazydocker` |
| Languages & runtimes | `mise`, `elixir`, `elm`, `node`, `pnpm`, `powershell` — `mise` owns the node used for project work, because Homebrew's `node` tracks Node's **Current** line rather than LTS. `node` stays declared because `azurite` and `marp-cli` depend on it; it is not a leaf and is not the project runtime |
| Azure | `azure-cli`, `azure-dev` (the `azd` CLI), `azure-functions-core-tools@4`, `azurite`, `bicep` |
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

Two third-party taps are declared, `azure/functions` and `azure/bicep`, and both must appear above
the packages drawn from them because the file is walked top to bottom. Homebrew 6+ refuses to load
from an untrusted tap, so `install` grants each declared tap trust as it adds it — every tap is a
third party you are trusting to run install code, which is why the list stays this short.

## macOS Defaults

Five individually-prompted groups, each of which can be declined on its own. **Finder** shows file
extensions, the path and status bars, list view with folders on top and search scoped to the current
folder, unhides `~/Library`, and stops `.DS_Store` files landing on network and USB volumes.
**Dock** minimizes into the app icon, hides recent apps, stops Spaces rearranging themselves, pins a
fixed icon size with magnification off so that size is the only one rendered, and speeds up the
Mission Control animation. **Keyboard** sets a key repeat faster than System Settings can express —
`KeyRepeat=1.5` and `InitialKeyRepeat=12`, in 15 ms ticks, where the sliders bottom out at 2 and 15 —
disables every automatic text substitution because smart quotes corrupt code on paste, and enables
full keyboard access; it takes effect after a logout. **Screenshots** go to `~/Pictures/Screenshots`
as PNGs without the drop shadow, and a final group expands the save and print panels by default.

## Privacy

`.zprofile` opts out of telemetry for every tool in this setup that collects it, in one block so the
posture is auditable at a glance.

| Variable | Tool |
|----------|------|
| `DOTNET_CLI_TELEMETRY_OPTOUT=1` | dotnet CLI |
| `FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1` | Azure Functions Core Tools |
| `AZURE_CORE_COLLECT_TELEMETRY=0` | azure-cli |
| `AZURE_DEV_COLLECT_TELEMETRY=no` | azd |
| `HOMEBREW_NO_ANALYTICS=1` | Homebrew |

These reach anything launched from a shell that sourced `.zprofile`, which includes VS Code's
integrated terminal but not apps launched from Finder. For a setting that holds regardless of
environment, `brew analytics off` writes Homebrew's own persistent config.

Two outbound calls are not covered by any of the above. Both come from
`claude/.claude/statusline.sh`, which is vendored from
[ClaudeCodeStatusLine](https://github.com/daniel3303/ClaudeCodeStatusLine) and runs on every Claude
Code statusline render.

| Call | Frequency | Notes |
|------|-----------|-------|
| `api.anthropic.com/api/oauth/usage` | at most every 60s, cached | Reports your usage quota. Sends an OAuth token read from the macOS Keychain, passed to `curl` via `--config` on stdin so it never appears in `ps` output |
| `api.github.com/.../releases/latest` | at most every 24h, cached | Third-party update check against the upstream repo. Disable with `STATUSLINE_CHECK_UPDATES=false` |

Only the update check is switchable; the usage call is what the statusline exists to display. The
statusline inherits the environment Claude Code was launched with, so setting
`STATUSLINE_CHECK_UPDATES` in `.zprofile` covers a Claude Code started from a shell but not one
launched from Finder — use `launchctl setenv` for that.

## Gotchas

Each of these has been rediscovered more than once, and some of them fail *silently*.

- **A new file in an existing package needs a re-stow.** Because stow runs `--no-folding`,
  directories are real and only tracked leaf files are symlinked. Editing an existing file takes
  effect immediately; adding a *new* one does nothing until you run
  `stow -d ~/dotfiles --no-folding -R <package>`.
- **A stowed config can be rewritten by the app that reads it.** stow links leaf files *into* the
  repo, so a tool that migrates or extends its own config writes through the symlink and the change
  lands as an unexplained modification in `git status`. lazygit 0.64 did it renaming `git.pagers` to
  `git.diffRenderers`; OrbStack did it twice, adding an `Include` to `~/.ssh/config` and a `source`
  line to `.zprofile`. Check `git status` after installing anything that manages its own config.
- **`.zshrc` load order is load-bearing.** Powerlevel10k's instant prompt must come first and
  nothing may write to stdout before it, and in `plugins=()` **`fzf-tab` must precede
  `zsh-autosuggestions` and `zsh-syntax-highlighting`** or completion and highlighting break without
  saying so.
- **The installer reads the Brewfile from FD 3.** `ask()`'s `read -q` consumes stdin, so the package
  loop uses `... <&3; done 3< Brewfile`. Converting that to a plain `< Brewfile` makes every prompt
  eat the next line, silently skipping packages.
- **Two ignore files, different scopes.** `/.gitignore` covers this repo only and is mostly
  allowlists — the `ssh` and `claude` packages ignore everything and re-include just the tracked
  configs, so adding a tracked file to either needs a matching `!` line or git never sees it.
  `git/.config/git/ignore` is stowed to `~/.config/git/ignore` and applies to **every** repo on the
  machine. Neither has trailing-comment syntax: `pattern  # note` makes the comment part of the
  pattern and silently stops it matching.

## License

Released into the public domain under [The Unlicense](LICENSE.md) — take any of it, with one
exception. `claude/.claude/statusline.sh` is vendored from
[ClaudeCodeStatusLine](https://github.com/daniel3303/ClaudeCodeStatusLine) and stays MIT,
Copyright (c) 2025 Daniel Oliveira; its licence is retained in the file header.
