# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

macOS dotfiles managed with GNU Stow. Each top-level directory (git, zsh, hushlogin, ssh, nvim, kitty) is a stow package whose contents mirror the home directory structure (e.g. `zsh/.zshrc` symlinks to `~/.zshrc`).

## Commands

- Syntax-check the install script: `zsh -n install`
- Re-stow a single package: `stow -d ~/dotfiles -R <package>`
- Run the full bootstrap: `./install` (interactive, prompts y/N for each step)

## Shell

All scripts use **zsh** (not bash). The install script relies on zsh-specific builtins (`read -q`, `print`) and glob qualifiers (`*(/)` for directories).

## Install Script

`./install` is an interactive bootstrap. It prompts (y/N) before each step: Xcode CLI Tools, Homebrew, individual Brewfile packages (brew/cask), Oh My Zsh (unattended, preserves .zshrc), custom plugins (zsh-autosuggestions, zsh-syntax-highlighting), macOS defaults (Finder, Dock, keyboard, screenshots, Safari), and stow linking.

The Brewfile parser extracts `type` and `pkg` from each line (skipping comments via `\#*`) and dispatches to `brew install` or `brew install --cask`. Individual brew failures are caught with `|| print` so they don't abort the loop (the script runs under `set -eu`). The stow loop auto-discovers all top-level directories via the `*(/)` glob qualifier.

## Adding a New Stow Package

Create a directory whose internal structure mirrors the home-relative path (e.g. `foo/.config/foo/config.toml`). The install script's stow loop picks it up automatically.

## Key Config Details

- **Git**: pull rebase, push auto-setup-remote, fetch prune, zdiff3 conflict style, rerere, histogram diffs, colorMoved, rebase autoStash, branch sort by recent
- **Zsh**: Oh My Zsh with awesomepanda theme; editor is nvim locally, vim over SSH; Docker v2 aliases (`dc`, `dcu`, `dcd`, `dcl`, `dps`, `dcb`, `dcr`); .NET telemetry opted out
- **Kitty**: Catppuccin Mocha theme, FiraCode Nerd Font Mono, splits+stack layouts, `cmd+d`/`cmd+shift+d` for splits, `cmd+t`/`cmd+w`/`cmd+1-9` for tabs, `cmd+f` scrollback search
- **SSH**: macOS Keychain integration, IdentitiesOnly, 60s keepalive, hashed known_hosts
- **Global gitignore** (`git/.config/git/ignore`): `.DS_Store`, macOS metadata, `.claude/settings.local.json`, `.vs/`, `.idea/`, `*.user`, `*.suo`
