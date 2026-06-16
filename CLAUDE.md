# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

macOS dotfiles managed with GNU Stow. Each top-level directory (bat, btop, claude, git, hushlogin, kitty, lazygit, nvim, ssh, zsh) is a stow package whose contents mirror the home directory structure (e.g. `zsh/.zshrc` symlinks to `~/.zshrc`).

## Commands

- Syntax-check the install script: `zsh -n install`
- Re-stow a single package: `stow -d ~/dotfiles --no-folding -R <package>`
- Run the full bootstrap: `./install` (interactive, prompts y/N for each step; use `./install --yes` for non-interactive, `./install --adopt` to allow stow conflict adoption)

## Shell

All scripts use **zsh** (not bash). The install script relies on zsh-specific builtins (`read -q`, `print`) and glob qualifiers (`*(/)` for directories).

## Install Script

`./install` is an interactive bootstrap with `set -eu`. It skips already-installed brew packages, catches individual failures with `|| warn`. Flags: `--yes`/`-y` for non-interactive mode, `--adopt` to opt into stow conflict adoption.

- **Stow conflicts fail by default.** If `$HOME` already has files that would collide with the symlinks, the script errors out. To resolve, re-run with `--adopt` — but that's destructive toward the repo: stow moves the existing home-directory file *into the repo* (overwriting the tracked version) and symlinks it back. Always `git diff` after running with `--adopt` before committing.
- **Brewfile loop reads from FD 3** (`while ... <&3; done 3< Brewfile`) because `ask()`'s `read -q` consumes stdin. If you refactor the loop to a plain `< Brewfile`, every `ask` prompt eats the next Brewfile line and packages get silently skipped.
- **Brewfile parser handles `tap`, `brew`, `cask`** — all three must use the exact `<directive> "pkg"` quoting; the regex (`^(brew|cask|tap)[[:space:]]+"([^"]+)"`) won't match anything else.

## Adding a New Stow Package

Create a directory whose internal structure mirrors the home-relative path (e.g. `foo/.config/foo/config.toml`). The install script's stow loop picks it up automatically via the `*(/)` glob qualifier.

## Architecture Notes

- **Catppuccin Mocha** is the unified theme across kitty, nvim, bat, btop, lazygit, delta (git pager), and fzf (via `FZF_DEFAULT_OPTS` in `.zshrc`). When adding new tools with theme support, use Catppuccin Mocha for consistency.
- **Kitty theme** is extracted to `kitty/.config/kitty/themes/catppuccin-mocha.conf` via `include` — edit the theme file, not `kitty.conf`.
- **Git pager** is `delta` (not `less`). The `[delta]` section in `.gitconfig` and lazygit's `git.paging.pager` must stay in sync.
- **Powerlevel10k** is the zsh prompt. Config lives in `zsh/.p10k.zsh`. The instant prompt block at the top of `.zshrc` must remain first — nothing can print to stdout before it.
- **Neovim** uses lazy.nvim for plugin management. Plugin specs live in `nvim/.config/nvim/lua/plugins/`. Core config (options, keymaps) lives in `nvim/.config/nvim/lua/config/`.
- **Zsh load order** in `.zshrc` is critical and must be preserved:
  1. Powerlevel10k instant prompt (must be first — nothing can print to stdout before it)
  2. Oh My Zsh config + `source $ZSH/oh-my-zsh.sh` — any `fpath` additions (e.g. `$HOME/.docker/completions`) must come *before* the source line, since OMZ runs `compinit` during sourcing. In the `plugins=()` array, `fzf-tab` must come *before* `zsh-autosuggestions` and `zsh-syntax-highlighting` — fzf-tab wraps the completion widget and the syntax/autosuggestion plugins wrap the line editor; swapping their order silently breaks tab completion or kills syntax highlighting.
  3. Aliases and shell tool inits (fzf, zoxide, direnv)
  4. `source ~/.p10k.zsh`
  5. `setopt aliases` (required — p10k leaks `noaliases` from its config)
- **Brewfile format** uses `tap "pkg"`, `brew "pkg"`, or `cask "pkg"` — the install script's regex parser depends on this exact quoting.
- **Stow uses `--no-folding`** (set in `install` and `.stowrc`): target directories are created as real directories and only tracked leaf files are symlinked. This stops stow from folding an app-managed directory (`~/.ssh`, `~/.claude`, `~/.config/btop`) into a single symlink that points into the repo — which would otherwise let app runtime state and secrets (e.g. `~/.claude/.credentials.json`) get written *inside* the repo. Tradeoff: adding a *new* file to an existing package requires a re-stow to link it. `.gitignore` also defensively ignores everything under `ssh/.ssh/` and `claude/.claude/` except the tracked configs.
