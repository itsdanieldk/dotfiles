# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Working agreement

**Never run git operations** — no commits, no branches, no staging, no history rewriting — unless
explicitly asked in that message. Edit files and report; the user drives git.

## What This Is

macOS dotfiles managed with GNU Stow. Each top-level directory (`aerospace`, `bat`, `borders`,
`btop`, `claude`, `git`, `kitty`, `lazygit`, `nvim`, `raycast`, `sketchybar`, `ssh`, `zsh`) is a
stow package whose contents mirror `$HOME` (e.g. `zsh/.zshrc` → `~/.zshrc`).

**Stow runs `--no-folding`** (set in `install` and `.stowrc`): directories are created for real and
only tracked leaf files are symlinked. This stops an app-managed directory (`~/.ssh`, `~/.claude`)
being folded into a symlink pointing *into the repo*, which would let runtime state and secrets get
written inside it. **Tradeoff: a NEW file in an existing package needs a re-stow before anything
sees it** — an edit to an existing file takes effect immediately, a new file does not.

## Commands

```sh
zsh -n install                              # syntax-check (install is zsh, not bash)
stow -d ~/dotfiles --no-folding -R <pkg>    # re-stow one package
./install [--yes] [--adopt]                 # bootstrap; interactive y/N per step
./scripts/lint-sketchybar.sh                # SketchyBar silent-failure checks
./scripts/lint-aerospace.sh                 # AeroSpace cross-file coupling checks
```

`install` is **zsh**, not bash: it uses `read -q`, `print`, and the `*(/)` glob qualifier.

`--adopt` is destructive toward the repo — stow moves the existing `$HOME` file *into* the repo,
overwriting the tracked version. Always diff after using it.

## Hardware assumptions

**Mac Studio (M4 Max), one 2560×1440 external.** No battery, no built-in display, no notch.
AeroSpace and SketchyBar are tuned for exactly this: no per-monitor gaps, no
`workspace-to-monitor-force-assignment`, no notch arithmetic. Don't reintroduce multi-monitor or
laptop assumptions without a second display actually present.

## Keyboard — two independent hazards on `alt`

- **`alt-<digit>` collides with the Danish layout.** `[ ] { } \` live on the Option layer of the
  digit row (`alt-8`, `alt-9`, `alt-shift-7/8/9`) with no other route, so binding those makes them
  untypable system-wide. **Workspaces are on `ctrl-<digit>` for this reason** — don't "tidy" them
  back to upstream's `alt`. Measured with `UCKeyTranslate`: `ctrl-8` → `8`, but `cmd-alt-8` → `[`,
  so `cmd` is *not* an escape. Same for Norwegian/Swedish/Finnish/German.
- **`alt-<letter>` collides with zsh widgets** (`^[b`/`^[f` word motion, `^[d` kill-word, …).
  Check `bindkey -M emacs` before adding one.

`kitty.conf` sets `macos_option_as_alt left`, so in the terminal the **right** Option key composes
layout characters and the left one sends `ESC` sequences.

## SketchyBar — four traps, each rediscovered more than once

All four fail *silently*: the bar comes up, an item is simply absent or stale, and nothing says why.
`./scripts/lint-sketchybar.sh` checks the first three.

1. **An item whose script sets item-level `drawing=off` MUST also set `updates=on`.** Under the
   config-wide `updates=when_shown`, a hidden item stops being updated entirely — so it works after
   a reload, hides itself, and never runs again. `updates=on` with `update_freq=0` stays event-only,
   so it costs no polling. Note `label.drawing=off` is *not* this — it hides a component, not the
   item.
2. **New plugin scripts need `chmod +x`.** SketchyBar `fork_exec`s them and reports nothing when the
   bit is missing.
3. **A plugin has less TCC access than your terminal.** The bar is launched by AeroSpace with no
   Full Disk Access. Anything TCC-protected under `~/Library` reads fine by hand and fails with
   `EPERM` in the plugin, at correct Unix permissions. **Test reads from a script the bar actually
   runs**, not from a shell.
4. **Don't trust `macmon`'s `temp.cpu_temp_avg`.** Bimodal at flat idle — measured landing on ~31.9
   or ~38.1 and never between, dropping to 20 °C at 0.06 W. It is a mean over a varying sensor set.
   `helpers/thermal.swift` exists because of this.

Several properties are **not echoed by `sketchybar --query`** (`label.max_chars`, `blur_radius`,
`notch_*`), so a wrong value looks identical to a right one. Verify behaviour, not the query.

## Install script gotchas

- **The Brewfile loop reads from FD 3** (`... <&3; done 3< Brewfile`) because `ask()`'s `read -q`
  consumes stdin. Convert it to a plain `< Brewfile` and every prompt eats the next line, silently
  skipping packages.
- **`brew install` passes `--formula` deliberately** — some taps ship a formula *and* a cask under
  one name, and the cask never matches the `brew list --formula` skip-check, so it re-prompts
  forever.
- **Taps must be trusted, not just added** (Homebrew 6+). The script runs `brew trust --tap`; a tap
  can be present but unusable.
- **The hand-rolled Brewfile parser is deliberate.** `brew bundle` would replace it but is
  all-or-nothing; the parser is what enables the per-package y/N prompt.
- Brewfile format is exactly `tap "pkg"` / `brew "pkg"` / `cask "pkg"` — the regex depends on it.

## `.zshrc` load order — must be preserved

1. Powerlevel10k instant prompt **first**; nothing may print to stdout before it.
2. Oh My Zsh config, then `source $ZSH/oh-my-zsh.sh`. Any `fpath` additions go *before* the source
   line (OMZ runs `compinit` during it). In `plugins=()`, **`fzf-tab` must precede
   `zsh-autosuggestions` and `zsh-syntax-highlighting`** — fzf-tab wraps the completion widget while
   the other two wrap the line editor; the wrong order silently breaks completion or highlighting.
3. Aliases and tool inits (fzf, zoxide, direnv)
4. `source ~/.p10k.zsh`
5. `setopt aliases` — required, p10k leaks `noaliases`.

## Other

- **Theme is Catppuccin Frappé** across kitty, nvim, bat, btop, lazygit, delta and fzf. Match it.
- **`claude/.claude/statusline.sh` is vendored** ([daniel3303/ClaudeCodeStatusLine]); it reads OAuth
  credentials and makes network calls, so review diffs before pulling upstream. Must stay **bash
  3.2**-compatible.
- A stray `~/.aerospace.toml` makes AeroSpace error on the ambiguity — config lives only at
  `aerospace/.config/aerospace/aerospace.toml`.

[daniel3303/ClaudeCodeStatusLine]: https://github.com/daniel3303/ClaudeCodeStatusLine
