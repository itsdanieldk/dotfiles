# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

macOS dotfiles managed with GNU Stow. Each top-level directory (bat, claude, git, hushlogin, kitty, lazygit, nvim, ssh, zsh) is a stow package whose contents mirror the home directory structure (e.g. `zsh/.zshrc` symlinks to `~/.zshrc`).

## Commands

- Syntax-check the install script: `zsh -n install`
- Re-stow a single package: `stow -d ~/dotfiles -R <package>`
- Run the full bootstrap: `./install` (interactive, prompts y/N for each step; use `./install --yes` for non-interactive)

## Shell

All scripts use **zsh** (not bash). The install script relies on zsh-specific builtins (`read -q`, `print`) and glob qualifiers (`*(/)` for directories).

## Install Script

`./install` is an interactive bootstrap with `set -eu`. It skips already-installed brew packages, catches individual failures with `|| warn`, and uses stow `--adopt` to resolve symlink conflicts. Pass `--yes` or `-y` for non-interactive mode.

## Adding a New Stow Package

Create a directory whose internal structure mirrors the home-relative path (e.g. `foo/.config/foo/config.toml`). The install script's stow loop picks it up automatically via the `*(/)` glob qualifier.

## Architecture Notes

- **Catppuccin Mocha** is the unified theme across kitty, nvim, bat, lazygit, and delta (git pager). When adding new tools with theme support, use Catppuccin Mocha for consistency.
- **Kitty theme** is extracted to `kitty/.config/kitty/themes/catppuccin-mocha.conf` via `include` — edit the theme file, not `kitty.conf`.
- **Git pager** is `delta` (not `less`). The `[delta]` section in `.gitconfig` and lazygit's `git.paging.pager` must stay in sync.
- **Powerlevel10k** is the zsh prompt. Config lives in `zsh/.p10k.zsh`. The instant prompt block at the top of `.zshrc` must remain first — nothing can print to stdout before it.
- **Neovim** uses lazy.nvim for plugin management. Plugin specs live in `nvim/.config/nvim/lua/plugins/`. Core config (options, keymaps) lives in `nvim/.config/nvim/lua/config/`.
- **Zsh load order** in `.zshrc` is critical and must be preserved:
  1. Powerlevel10k instant prompt (must be first — nothing can print to stdout before it)
  2. Oh My Zsh config + `source $ZSH/oh-my-zsh.sh`
  3. Aliases and shell tool inits (fzf, zoxide, direnv)
  4. `source ~/.p10k.zsh`
  5. `setopt aliases` (required — p10k leaks `noaliases` from its config)
- **Brewfile format** uses `brew "pkg"` or `cask "pkg"` — the install script's regex parser depends on this exact quoting.
