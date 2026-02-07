# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

macOS dotfiles managed with GNU Stow. Each top-level directory (git, zsh, hushlogin, ssh, nvim, kitty) is a stow package whose contents mirror the home directory structure.

## Commands

- Syntax-check the install script: `zsh -n install`
- Re-stow a single package: `stow -d ~/dotfiles -R <package>`
- Run the full bootstrap: `./install` (interactive, prompts y/N for each step)

## Install Script

`./install` — interactive bootstrap that prompts (y/N) before each step:
1. Xcode Command Line Tools
2. Homebrew
3. Each Brewfile package individually (brew/cask)
4. Oh My Zsh (unattended, preserves .zshrc)
5. Oh My Zsh custom plugins (zsh-autosuggestions, zsh-syntax-highlighting)
6. macOS defaults (Finder, Dock, keyboard, screenshots, Safari, misc)
7. Stow dotfile linking (auto-discovers all top-level directories)

## Stow Packages

Each directory is a stow package. The internal structure mirrors `$HOME`:
- `zsh/.zshrc` → `~/.zshrc`
- `zsh/.zprofile` → `~/.zprofile`
- `git/.gitconfig` → `~/.gitconfig`
- `git/.config/git/ignore` → `~/.config/git/ignore`
- `ssh/.ssh/config` → `~/.ssh/config`
- `hushlogin/.hushlogin` → `~/.hushlogin`
- `nvim/.config/nvim/` → `~/.config/nvim/`
- `kitty/.config/kitty/kitty.conf` → `~/.config/kitty/kitty.conf`

To add a new dotfile: create the directory with the home-relative path inside it. The install script's stow loop auto-discovers all top-level directories via `*(/)`.

## Shell

All scripts use zsh (not bash). The install script uses zsh-specific builtins like `read -q`, `print`, and glob qualifiers like `*(/)`.
