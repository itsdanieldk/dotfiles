---
name: new-package
description: Scaffold a new GNU stow package in this dotfiles repo — correct $HOME-mirroring directory shape, Brewfile entry, .gitignore allowlist if the app writes state, and README updates. Use when adding a config for a new tool.
disable-model-invocation: true
---

Add a stow package for: $ARGUMENTS

Report the plan before writing anything. CLAUDE.md has the rules for layout, comments, the Brewfile
and ignores; follow them.

1.  **Find the real config path** relative to `$HOME`, from the tool's docs or `man` page — a wrong
    path is a symlink nothing reads. Prefer `~/.config/<tool>/` when the tool honours `XDG_CONFIG_HOME`.
2.  **Create the package**, mirroring `$HOME`:

        <tool>/.config/<tool>/<file>  ->  ~/.config/<tool>/<file>
        <tool>/.<tool>rc              ->  ~/.<tool>rc

    Write a real, working config, not a stub, themed Catppuccin Frappé if the tool supports themes.
    Check whether the format allows trailing comments before using one.

3.  **Ignore runtime state.** Under `--no-folding` the directory is real in `$HOME`, so caches,
    history or credentials the app writes there land in the repo. If it does, add an allowlist block
    to `/.gitignore` like the `ssh/` and `claude/` ones:

        <tool>/.config/<tool>/*
        !<tool>/.config/<tool>/config

    If the app rewrites its config on exit (as btop does), track only the stable part and have
    `install` seed the rest.

4.  **Add it to the Brewfile** under the right `# --- Section ---`, by canonical name. If it needs a
    tap, say so explicitly — the user should weigh trusting a third party.
5.  **Add a row to the README's package table.**
6.  **Verify, don't stow:** `stow -d ~/dotfiles -t ~ --no-folding -n -R <tool>`, plus `zsh -n install`
    if `install` changed. Remind the user that a new package needs a stow before it takes effect.
