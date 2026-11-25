# CLAUDE.md

## Rules

- **Never run `./install`, `stow` or `brew install`**: they mutate the live machine. Edit and report.
- **No git writes** (commit, push, stash, branch, stage, rewrite) unless asked in that message.
- `HEAD`, the index and disk may all differ: the user stages selectively.

## Layout

Each non-hidden top-level dir is a stow package mirroring `$HOME` (`zsh/.zshrc` → `~/.zshrc`).

- Package roots hold only real `$HOME` paths. Repo tooling lives in dotted dirs, which `install`'s `*(/)` skips.
- **`--no-folding` is mandatory**, or `~/.ssh` and `~/.claude` become repo symlinks and apps write secrets into git.
- A new file needs a re-stow: `stow -d ~/dotfiles -t ~ --no-folding -R <pkg>`. Edits apply at once.
- Adding or removing a package: update the README's package table.

## install

zsh, `set -eu` + `pipefail`; shellcheck can't parse it.

- arm64 and `/opt/homebrew` only; no `/usr/local` fallback.
- `set -e`: keep a bare `(( ))`/`[[ ]]` inside `if`; never end a function with `[[ ]] && cmd`.
- The Brewfile is read on FD 3, or `ask()`'s `read -q` eats its lines.
- `brew_needs_trust` runs before `jq` exists; both guards at its top are load-bearing.
- `brew install --formula` is deliberate: a bare install can pick a same-named cask.
- Failures warn and continue. Fatal only: stow conflict (1), unknown flag (2), non-arm64 (3).
- Checks: `.githooks/checks.zsh` is the pre-commit hook (`--staged`, on the index) and CI (on the tree); no `set -e` on purpose. `core.hooksPath` is set repo-locally, never in the tracked `.gitconfig`. `/dotfiles-check` is the full run.

## Brewfile

Parsed by `install`'s regex, not `brew bundle`; anything else is silently skipped:

    ^(brew|cask|tap|mas|vscode)[[:space:]]+"([^"]+)"(,[[:space:]]*id:[[:space:]]*([0-9]+))?

- Read order: `Brewfile` (every Mac) → `Brewfile.<profile>` → untracked `Brewfile.local` (employer tools; the repo is public).
- 1:1 with the machine: every on-request formula, cask, `mas` app and `vscode` extension is declared. `brew "mas"` and `cask "visual-studio-code"` must come before the entries that need them.
- Canonical names only — an alias is re-prompted every run: `brew info --formula --json=v2 <name> | jq -r '.formulae[0].name'`.
- Taps go in a `# Taps` block above their packages; prefer homebrew-core.
- New entries go under the matching `# --- Section ---`.

## Secrets and ignores

- `/.gitignore` allowlists inside `ssh/`, `claude/`, `gh/`, `k9s/`, `emacs/` and `git/`: **a new tracked file there needs its own `!` line.**
- `git/.config/git/config-work` and `/Brewfile.local` stay untracked.
- `git/.config/git/ignore` applies to every repo on the machine; keep it conservative.

## Load order (wrong order breaks silently)

- `.zimrc`: completion defs → `completion` → fzf-tab → widget wrappers; Catppuccin → syntax highlighting → history-substring-search; autosuggestions last.
- `.zshrc`: keymap, `WORDCHARS` and plugin vars before zim's `init.zsh`; zstyle overrides, history sizes and `ZSH_HIGHLIGHT_HIGHLIGHTERS` after it. `~/.zshrc.local` just before `starship init`, which stays last.
- `.zprofile`: `typeset -U path PATH fpath FPATH` first (repeated in `.zshrc` for non-login shells); `~/.zprofile.local` last.
- Optional sources use `if [[ -r f ]]; then source f; fi`: `[[ ]] && source` leaves `$?=1` and Starship shows ✘1.
- `ssh/.ssh/config`: first match wins; Includes above `Host *`, which stays last. Never pin `KexAlgorithms` (it strips with `-`); legacy hosts get `+` values in `config.local`.
- `.gitconfig`: `[includeIf "gitdir/i:~/work/"]` stays last (`/i`: case-insensitive FS). `[delta]` is the single source of truth.

## Conventions

- `# ====` banners; `install` and Brewfiles add `# --- Sub-section ---`. 4-space indent, 2 for yaml/json.
- Comments: one terse line, preferably trailing, only where losing it lets a bug back in. Never restate code.
- Ghostty and `.gitignore` have no trailing comments (`x  # note` breaks the line): put them on their own line.

## Emacs

- Vanilla, terminal-only, for quick edits. Ask before adding a package or setting.
- `custom-file` lives outside the repo, or Customize writes through the stow link.
- A `~/.emacs.d` or `~/.emacs` shadows `~/.config/emacs`.
- No `.stow-local-ignore`: it replaces stow's defaults, which skip Emacs's `*~`, `#*#` and `.#*`.

## Vendored files

MIT, listed in `LICENSE.md` and the README; keep their licence headers.

- `claude/.claude/statusline.sh` (ClaudeCodeStatusLine): stay bash 3.2-compatible, don't restyle.
- `emacs/.config/emacs/themes/` (catppuccin/emacs @ `56c3cbe`): verbatim; update both files from one upstream commit.
