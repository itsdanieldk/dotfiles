# CLAUDE.md

## Working agreement

- **Never run `./install`, `stow` or `brew` installs.** They mutate the live machine. Edit files and report; the user runs them.
- **No git writes** — commit, push, stash, branch, staging, history rewriting — unless asked in that message. Reading is fine.
- `HEAD`, the index and disk may all differ: the user stages selectively.

## Layout

Every non-hidden top-level directory is a stow package mirroring `$HOME`:

    zsh/.zshrc                   ->  ~/.zshrc
    emacs/.config/emacs/init.el  ->  ~/.config/emacs/init.el

- Never put a file at a package root unless it is a real `$HOME` path.
- **`--no-folding` is mandatory** (`.stowrc` and `install`). Without it `~/.ssh` and `~/.claude` become symlinks into the repo and apps write secrets into git.
- **A new file in a package needs a re-stow:** `stow -d ~/dotfiles -t ~ --no-folding -R <package>`. Edits to existing files apply at once. `-t ~` is explicit because stow's default target is the parent of `-d`.
- `install` globs `*(/)`, which skips dotted directories — repo tooling lives in `.claude/`, `.githooks/` and `.github/` and needs no exclusion list.
- A stow conflict makes `install` exit 1. `--adopt` resolves it toward the repo, overwriting the tracked file.

## install

zsh, not bash (`read -q`, `print -P`, `$match[]`, `*(/)`, `${+assoc[key]}`) — shellcheck can't parse it.
`set -eu` plus `setopt pipefail`. Verification: `.githooks/checks.zsh` runs as the pre-commit hook
(on the index) and in CI (`.github/workflows/check.yml`, on the tree); `/dotfiles-check` is the full
check, including `stow -n` dry runs and drift.

- **`.githooks/`** — `install` sets the repo-local `core.hooksPath` (not the tracked `.gitconfig`). `checks.zsh` has no `set -e` on purpose: every check runs and `fail` collects the result. `--staged` reads `git show :file`, since the index and disk differ.

- **arm64 only:** a guard after flag parsing exits 3 on Intel. Every path hardcodes `/opt/homebrew`; don't add a `/usr/local` fallback.
- **The Brewfile is read from FD 3** (`done 3< Brewfile`): `ask()`'s `read -q` would otherwise eat package lines.
- **`set -e`:** a bare false `(( ))` or `[[ ]]` kills the script, so keep it inside an `if`; as the left side of `&&`/`||` it is exempt. Never end a function with `[[ ]] && cmd` — the call site trips.
- `--yes` passes `NONINTERACTIVE=1` to the Homebrew bootstrap, which then uses `sudo -n`.
- **Profile:** `--profile=NAME`, else `~/.config/dotfiles/profile`, else a prompt (with `--yes`: shared only). A blank answer is saved too, so a shared-only Mac isn't asked again. The Brewfile loop is `install_brewfile`, run once per file.
- `brew_needs_trust` must work before `jq` is installed (taps come first); both guards at its top are load-bearing.
- Failures warn and continue. Only an unknown flag (2), a stow conflict (1) and non-arm64 (3) are fatal.

## Brewfile

Parsed by `install`'s own regex, not `brew bundle`; any other shape is silently skipped:

    ^(brew|cask|tap|mas|vscode)[[:space:]]+"([^"]+)"(,[[:space:]]*id:[[:space:]]*([0-9]+))?

- **Split by profile, read in order:** `Brewfile` (every Mac) → `Brewfile.<profile>` (e.g. `Brewfile.personal`) → the untracked `Brewfile.local`. Anything not every Mac should get goes in the profile file; employer-specific tools go in `Brewfile.local`, since the repo is public.
- Double quotes only, `#` comments start the line, `args:` extras are ignored.
- **1:1 with the machine:** the union of the files `install` reads declares every formula installed on request, cask, App Store app and VS Code extension. `mas "Name", id: N` installs only apps the signed-in Apple ID owns; `vscode "publisher.ext"` needs the `code` CLI from the VS Code cask. Both lists load lazily, so `brew "mas"` and `cask "visual-studio-code"` must come earlier in reading order than the entries that need them.
- Taps go in a `# Taps` block at the top of the file that uses them, above their packages. Prefer homebrew-core: a tap is a third party trusted to run install code.
- New entries go under the right `# --- Section ---`.
- **Declare the canonical name, never an alias.** The skip-check compares against `brew list --formula`, so an alias is re-prompted every run. Check with `brew info --formula --json=v2 <name> | jq -r '.formulae[0].name'`.
- `install` uses `brew install --formula` on purpose: a bare install picks a same-named cask, which the skip-check never sees.

## Secrets and ignores

- `/.gitignore` allowlists `ssh/`, `claude/`, `gh/`, `k9s/`, `emacs/` and `git/`: `ssh/.ssh/*` + `!ssh/.ssh/config`, `claude/.claude/*` + `!` lines for `settings.json` and `statusline.sh`, `gh/.config/gh/*` + `!gh/.config/gh/config.yml` (`hosts.yml` holds the token), `k9s/.config/k9s/*` + `!` lines for `config.yaml` and `skins/` (k9s writes `clusters/` and dumps there), `emacs/.config/emacs/*` + `!` lines for `init.el` and `themes/` (Emacs writes `custom.el`, `auto-save-list/` and packages there), and `git/.config/git/*` + `!` lines for `ignore` and `allowed_signers` (git's credential store can write there). **A new tracked file there needs its own `!` re-include**, or git never sees it.
- `git/.config/git/config-work` stays ignored by that allowlist — the work identity is machine-local, and git skips an `includeIf` whose file is missing. `/Brewfile.local` is ignored outright.
- `.gitignore` has **no trailing-comment syntax**: `pattern  # note` silently stops matching.
- `/.gitignore` covers this repo; `git/.config/git/ignore` applies to every repo on the machine, so keep it conservative.

## Load order

Wrong order breaks silently.

- **`.zimrc`** — zim's template order. Completion definitions (zsh-completions, the generated `_dotnet`) before `completion`, which runs compinit; fzf-tab after it and before the widget wrappers; the Catppuccin theme before syntax highlighting; history-substring-search after syntax highlighting; autosuggestions last, since `.zshrc` sets `ZSH_AUTOSUGGEST_MANUAL_REBIND`.
- **`.zshrc`** — keymap, `WORDCHARS` and plugin variables before zim's `init.zsh`; overrides of stock module zstyles (fzf-tab's `menu no`, descriptions format, list-colors), the history sizes and `ZSH_HIGHLIGHT_HIGHLIGHTERS` after it, since the modules and the Catppuccin theme set them unconditionally. The `compinit` in the guard's `else` is the only one without zimfw.
- **`.zprofile`** — `typeset -U path PATH fpath FPATH` first; `.zshrc` repeats it because non-login shells skip `.zprofile`.
- **Machine-local hooks** — `.zprofile` ends with `~/.zprofile.local`, `.zshrc` sources `~/.zshrc.local` just before the prompt, so `starship init` stays last. Both use `if [[ -r … ]]; then source …; fi`: a `[[ ]] && source` leaves `$?=1` when the file is missing, and Starship shows ✘1 on the first prompt.
- **`ssh/.ssh/config`** — first match wins. `Include ~/.ssh/config.local`, then OrbStack's, both above `Host *`, which stays last. `KexAlgorithms` strips with `-` so the post-quantum defaults stay; never pin it. `Ciphers`, `MACs` and `HostKeyAlgorithms` replace the defaults; a legacy host gets a `+` value in `config.local`.
- **`.gitconfig`** — `[includeIf "gitdir/i:~/work/"]` stays last; `gitdir/i` because the filesystem is case-insensitive. `[delta]` is the single source of truth; lazygit runs bare `delta`.

## Conventions

- Config files use `# ====` section banners, and `install` and `Brewfile` add `# --- Sub-section ---` inside them. 4-space indent, 2 for yml/yaml/json (`.editorconfig`).
- **Comments are terse:** one line per fact, only where losing it lets a known bug back in. Prefer a trailing `# note`; never a paragraph; never restate the code.
- **Ghostty and `.gitignore` have no trailing comments** — a `# note` folds into the value. Put comments on their own line.
- When a package is added or removed, update the README's package table.

## Emacs

- Sized for quick terminal edits; real work happens in Rider and VS Code.
- homebrew-core's formula is terminal-only (no Cocoa), so `EDITOR=emacs` needs no `-nw`. No daemon.
- **Vanilla on purpose:** `init.el` turns on `editorconfig-mode`, loads the vendored Catppuccin Frappé theme and moves `custom-file` out, since Customize and package.el would write through the stow link into the repo. Ask before adding a package or setting.
- **A `~/.emacs.d`, `~/.emacs` or `~/.emacs.el` silently shadows `~/.config/emacs`.** Stow `emacs` before the first launch.
- Backups, auto-saves and lock links (`*~`, `#*#`, `.#*`) land next to the file: stow's default ignore list skips them (a `.stow-local-ignore` would replace it), the global git ignore hides them.

## Vendored files

Both are MIT, listed as exceptions in `LICENSE.md` and the README; their licence headers must survive every edit.

- `claude/.claude/statusline.sh` comes from [ClaudeCodeStatusLine](https://github.com/daniel3303/ClaudeCodeStatusLine), Copyright (c) 2025 Daniel Oliveira. Keep it bash 3.2-compatible and don't restyle it.
- `emacs/.config/emacs/themes/` is [catppuccin/emacs](https://github.com/catppuccin/emacs) at `56c3cbe`, Copyright 2022-present Catppuccin; the notice is in `catppuccin-theme.el`. Keep both files verbatim — the theme reads `catppuccin-definitions.el` from its own directory — and update them together from one upstream commit.
