# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.


# ============================================================
# Working agreement
# ============================================================

**Never run `./install`, `stow`, or `brew` install commands.** They mutate the live machine
(symlinks in `$HOME`, `defaults write`, package installs). Edit files and report; the user runs them.

**Never run git write operations** — no commit, push, stash, branch, staging, or history rewriting —
unless asked in that message. The user drives git. Reading (`git status`, `git diff`, `git log`) is fine.

The working tree currently carries a large uncommitted refactor. Don't assume `HEAD` matches disk.


# ============================================================
# Repo shape: stow packages
# ============================================================

Every **non-hidden** top-level directory is a GNU stow package whose contents mirror `$HOME` exactly:

    zsh/.zshrc                  ->  ~/.zshrc
    nvim/.config/nvim/init.lua  ->  ~/.config/nvim/init.lua

To add a config, create `<package>/<path-relative-to-$HOME>`. Never add a file at the package root
that isn't a real `$HOME` path.

- **`--no-folding` is mandatory** (set in `.stowrc` *and* passed explicitly by `install`). Directories
  stay real; only leaf files are symlinked. Without it, `~/.ssh` and `~/.claude` become symlinks into
  the repo and apps write secrets and runtime state straight into git.
- **Adding a new file to an existing package requires a re-stow.** Editing an existing file takes
  effect immediately; a new one does not. Tell the user to run
  `stow -d ~/dotfiles --no-folding -R <package>`.
- Any new **non-hidden** top-level directory is auto-treated as a stow package: the loop globs
  `${DOTFILES}/*(/)`, which does **not** match dotted directories, so `.claude/` (repo tooling, not
  a `$HOME` config) is invisible to it and needs no exclusion. There is no exclusion list: repo
  tooling belongs in a dotted directory, which is what keeps it out of the loop.
- `install` **exits 1** on a stow conflict. `--adopt` resolves it destructively *toward the repo* —
  it moves the `$HOME` file in, overwriting the tracked version.

Recently and deliberately removed: aerospace, sketchybar, borders, raycast, and their lint scripts.
Do not resurrect them or reference them in new work.


# ============================================================
# `install` is zsh, not bash
# ============================================================

`install` is `#!/usr/bin/env zsh` and uses zsh-only syntax (`read -q`, `print -P`, `$match[]`,
`${0:A:h}`, `*(/)`, `${array[(Ie)x]}`). shellcheck cannot parse it. Header is `set -eu` +
`setopt pipefail` — zsh's `set` has no `-o pipefail`.

Syntax-check with:

    zsh -n install

There is no Makefile, no test suite, and no CI. That command plus a `stow -n -R` dry run is the
entire verification surface. Run `/dotfiles-check` for the full sweep.

Non-obvious internals, all load-bearing:
- The script is **arm64-only** and says so up front: an architecture guard sits between flag parsing
  and the first mutation, and **exits 3** on a non-Apple-Silicon Mac. Every Homebrew path in the repo
  hardcodes `/opt/homebrew`; on Intel the bootstrap lands in `/usr/local`, `.zprofile` never finds it,
  and the run still ends with "All done!". Don't reintroduce a `/usr/local` fallback.
- The Brewfile is parsed **from FD 3** (`done 3< Brewfile`) because `ask()`'s `read -q` consumes
  stdin and would otherwise eat the next package line.
- `set -e` and false conditionals, measured rather than assumed. A **bare** `(( ... ))` or
  `[[ ... ]]` statement that evaluates false returns non-zero and kills the script — keep those
  inside an `if`, as the Xcode CLT wait loop does. But as the left side of an AND-OR list
  (`(( ... )) && cmd`, `[[ ... ]] || return 0`) it is exempt, which is why `install:171` is correct
  as written. The one shape to avoid is `[[ ... ]] && cmd` as the **last** statement of a function:
  the function returns non-zero and the *call site* trips.
- **Stow runs before Oh My Zsh, and must stay there.** OMZ's `--keep-zshrc` only protects a
  `~/.zshrc` that already exists; with none linked it writes its own template there, and the stow
  step then dies on the conflict — on every fresh machine. Stowing first makes `~/.zshrc` a symlink,
  which that guard also accepts.
- `--yes` reaches the Homebrew bootstrap as `NONINTERACTIVE=1`; without it that installer blocks on
  a RETURN prompt. It then uses `sudo -n`, so an unattended run needs sudo primed.
- `brew_needs_trust` must stay usable **before `jq` is installed** — taps are the first Brewfile
  entries and `brew "jq"` is far below them. Both guards at the top of it are load-bearing; without
  them an already-added tap is re-prompted on every run.
- Failures are non-fatal by design: `cmd || warn "...continuing..."`. Only an unknown flag (exit 2),
  a stow conflict (exit 1) and a non-arm64 machine (exit 3) are fatal.


# ============================================================
# Brewfile
# ============================================================

`install` uses a **hand-rolled parser, not `brew bundle`**. The format is load-bearing:

    ^(brew|cask|tap)[[:space:]]+"([^"]+)"

Only that shape is recognised — double quotes required, `#` comments must start the line, and any
`brew "x", args: [...]` extras are ignored. Taps must appear **above** the packages that come from
them; the file is walked top to bottom.

When adding a package: put it under the right existing `# --- Section ---` heading, and prefer
homebrew-core over adding a tap (each tap is a third party trusted to run install code).

`brew install --formula` is used deliberately — some taps ship a formula and a cask under one name,
and a bare `brew install` picks the cask, which never satisfies the `brew list --formula` skip-check.

**Declare the canonical formula name, never an alias.** The skip-check compares the Brewfile entry
against `brew list --formula`, which prints the canonical name — so `brew "azd"` installs fine but is
re-prompted on every run, because brew lists it as `azure-dev`. Confirm before adding:

    brew info --formula --json=v2 <name> | jq -r '.formulae[0].name'


# ============================================================
# Secrets: the .gitignore allowlists
# ============================================================

`ssh/` and `claude/` map to directories their apps write secrets into, so `.gitignore` ignores
everything in them and re-includes only what is tracked:

    ssh/.ssh/*        + !ssh/.ssh/config
    claude/.claude/*  + !claude/.claude/settings.json  !claude/.claude/statusline.sh

**Adding a tracked file to either package requires a matching `!` re-include**, or it is silently
invisible to git.

`git/.config/git/config-work` is ignored outright — the work identity is machine-local, like
`~/.ssh/config.local`. The file stays on disk so stow links it; git ignores an `includeIf` whose
path is missing, so a fresh clone just uses the personal identity.

`.gitignore` has **no trailing-comment syntax** — `pattern  # note` makes the comment part of the
pattern and it silently stops matching. Keep every comment on its own line.

Two ignore files with different scopes: `/.gitignore` covers this repo only;
`git/.config/git/ignore` is stowed to `~/.config/git/ignore` and applies to **every** repo on the
machine — be conservative about what goes in it.


# ============================================================
# Load order (silent breakage if wrong)
# ============================================================

**`zsh/.zshrc`** — p10k instant prompt first, nothing may write to stdout before it. `fpath`
additions before `source $ZSH/oh-my-zsh.sh` (it runs `compinit`). In `plugins=()`, **`fzf-tab` must
precede `zsh-autosuggestions` and `zsh-syntax-highlighting`**. `HISTSIZE`/`SAVEHIST` after the OMZ
source so they win.

**`zsh/.p10k.zsh`** — the file disables `no_aliases` at the top and restores it at the bottom. Those
two restore lines must stay **outside** the anonymous function: its `emulate -L zsh` scopes option
changes to the function body, so moving them back in silently leaks `no_aliases` into every shell
and kills every alias. `.zshrc` used to carry a `setopt aliases` workaround for exactly this; the
root cause is fixed, so it is gone — do not reintroduce it.

**`zsh/.zprofile`** — `typeset -U path PATH` first (the file appends on every login shell; without
dedupe, entries accumulate). Telemetry opt-outs before `brew shellenv`. `.zshrc` declares
`typeset -U` too, because the attribute is shell-local and a non-login interactive shell never
sources `.zprofile`.

**`ssh/.ssh/config`** — first match wins. Two `Include`s at the top: `~/.ssh/config.local` first so
local overrides win, then OrbStack's (which defines only `Host orb`). Both must precede `Host *`,
which stays last. `KexAlgorithms`/`Ciphers`/`MACs` **replace** the built-in lists rather than extend
them, so a host offering only older algorithms fails; the fix is a `+`-prefixed value in the
untracked `~/.ssh/config.local`.

**`git/.gitconfig`** — the `[includeIf "gitdir/i:~/work/"]` block stays last. `gitdir/i`
(case-insensitive) is required on macOS's case-insensitive filesystem. The `[delta]` section is the
single source of truth; lazygit invokes bare `delta` and reads it.


# ============================================================
# Conventions
# ============================================================

Section banners, 4-space indent (2 for yml/yaml/json, per `.editorconfig`):

    # ============================================================
    # Section name
    # ============================================================

`install` and `Brewfile` also use `# --- Sub-section ---` inside a banner.

**Comments are terse.** One line per fact, and only where losing it would let a known bug back in —
an ordering invariant, a silent-failure trap, a value that looks wrong but isn't. Prefer a trailing
`# note` on the line itself. Never write a paragraph, and never restate what the code says.
`zsh/.p10k.zsh` is generated, so it keeps its own `# === Name ===` style; leave it alone.
`ghostty/` is the exception to the trailing-`# note` preference: Ghostty's parser has **no
trailing-comment syntax**, so `key = value  # note` folds the comment into the value and the config
fails to load. Every comment there goes on its own line above.

Neovim runs **zero plugins** — no plugin manager, no lockfile. Two files: `init.lua` and a vendored
`colors/catppuccin-frappe.lua` whose palette mirrors the ghostty theme. It is sized for terminal
quick-edits; real project work happens in VS Code and Rider. Don't reach for a plugin without being
asked: 0.12 already covers `gc`/`gcc`, `[b`/`]b`, `[q`/`]q`, `[d`/`]d` and seven bundled treesitter
parsers, and everything else falls back to Neovim's own regex syntax files. **LSP, diagnostics and
formatting are deliberately absent** — don't add diagnostic keymaps or a formatter either.

`claude/.claude/statusline.sh` is **vendored** from
[ClaudeCodeStatusLine](https://github.com/daniel3303/ClaudeCodeStatusLine), `#!/bin/bash`, and must
stay bash 3.2-compatible. Don't restyle it. It is **MIT, Copyright (c) 2025 Daniel Oliveira** — the
one file in this repo not covered by the Unlicense. MIT requires the notice be retained, so the
licence header at the top of the file must survive any edit.

When adding or removing a package, update `README.md` to match.
