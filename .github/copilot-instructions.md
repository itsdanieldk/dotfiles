# Copilot Instructions

macOS dotfiles managed with GNU Stow. Each top-level directory is a stow package whose contents mirror the home directory structure (e.g. `zsh/.zshrc` symlinks to `~/.zshrc`).

## Commands

- Syntax-check the install script: `zsh -n install`
- Re-stow a single package: `stow -d ~/dotfiles -R <package>`
- Full bootstrap: `./install` (interactive; `./install --yes` for non-interactive)

## Shell

All scripts use **zsh** (not bash). The install script uses zsh-specific builtins (`read -q`, `print`) and glob qualifiers (`*(/)` for directories).

## Adding a New Stow Package

Create a directory whose internal structure mirrors the home-relative path (e.g. `foo/.config/foo/config.toml`). The install script's stow loop picks it up automatically via the `*(/)` glob qualifier.

## Architecture

- **Catppuccin Mocha** is the unified theme across kitty, nvim, bat, lazygit, and delta. When adding new tools with theme support, use Catppuccin Mocha.
- **Git pager** is `delta`. The `[delta]` section in `.gitconfig` and lazygit's `git.paging.pager` must stay in sync.
- **Kitty theme** is extracted to `kitty/.config/kitty/themes/catppuccin-mocha.conf` via `include` — edit the theme file, not `kitty.conf`.
- **Neovim** uses lazy.nvim for plugin management. Plugin specs live in `nvim/.config/nvim/lua/plugins/`. Core config (options, keymaps) lives in `nvim/.config/nvim/lua/config/`.

## Zsh Load Order

Order in `.zshrc` matters and must be preserved:

1. Powerlevel10k instant prompt (must be first — nothing can print to stdout before it)
2. Oh My Zsh config + `source $ZSH/oh-my-zsh.sh`
3. Aliases and shell tool inits (fzf, zoxide, direnv)
4. `source ~/.p10k.zsh`
5. `setopt aliases` (required — p10k leaks `noaliases` from its config)

## Brewfile Format

Uses `brew "pkg"` or `cask "pkg"` with double quotes. The install script's regex parser depends on this exact quoting format.
