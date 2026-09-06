---
name: new-package
description: Scaffold a new GNU stow package in this dotfiles repo — correct $HOME-mirroring directory shape, Brewfile entry, .gitignore allowlist if the app writes state, and README/TODO updates. Use when adding a config for a new tool.
disable-model-invocation: true
---

Add a stow package for: $ARGUMENTS

Work through these steps in order. Report the plan before writing anything.

## 1. Find the real config path

Determine where the tool actually reads its config from on macOS, as a path relative to `$HOME`.
Most respect `~/.config/<tool>/`; some insist on `~/.<tool>rc`. Check the tool's docs or
`man` page rather than guessing — a wrong path produces a symlink nothing ever reads.

If the tool honours `XDG_CONFIG_HOME`, prefer `~/.config/<tool>/` for consistency with the rest
of the repo.

## 2. Create the package

The package directory mirrors `$HOME` exactly:

    <tool>/.config/<tool>/<file>      ->  ~/.config/<tool>/<file>
    <tool>/.<tool>rc                  ->  ~/.<tool>rc

Never place a file at the package root unless it is genuinely a dotfile at `$HOME`'s top level.

Write a real, working config — not a stub. Match the repo's house style: `# ====` section banners,
4-space indent, and terse comments — one line per fact, only where losing it would let a known bug
back in. Prefer a trailing `# note`. No paragraphs.

If the tool supports theming, use **Catppuccin Frappé** — it is the palette across ghostty, nvim,
bat, btop, lazygit, delta, and fzf.

## 3. Decide whether it needs a .gitignore allowlist

Does the app write runtime state, caches, credentials, or history into that same directory?
Because stow runs `--no-folding`, the directory is real in `$HOME` and the app can drop files
straight into the repo.

If yes, add an allowlist block to `/.gitignore` following the existing `ssh/` and `claude/`
pattern — ignore everything, then re-include only the tracked files:

    <tool>/.config/<tool>/*
    !<tool>/.config/<tool>/config

If the app rewrites its config on exit (as btop does), track only the parts that are stable and
have `install` seed the rest.

## 4. Brewfile entry

Add the tool under the correct existing `# --- Section ---` heading in `Brewfile`, matching the
exact parseable form — `install` uses a hand-rolled regex, not `brew bundle`:

    brew "name"
    cask "name"

Prefer homebrew-core. If it requires a tap, add the `tap "..."` line in the Taps block **above**
the package, and say so explicitly in your report — each tap is a third party trusted to run
install code, and the user should get to weigh that.

## 5. Update the docs

Add the package to `README.md`'s package list and reconcile anything the addition contradicts.

## 6. Verify, don't stow

Run the dry run only:

    stow -d ~/dotfiles --no-folding -n -R <tool>

Report the result. **Do not run the real `stow`** — the user does that. Remind them the new
package needs a stow (not just a re-stow of an existing one) before it takes effect.

If `install` gained anything, finish with `zsh -n install`.
