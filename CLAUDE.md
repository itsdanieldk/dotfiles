# CLAUDE.md

## Working agreement

- **Never run `./install`, `stow` or `brew` installs.** They mutate the live machine. Edit files and report; the user runs them.
- **No git writes** — commit, push, stash, branch, staging, history rewriting — unless asked in that message. Reading is fine.
- `HEAD`, the index and disk may all differ: the user stages selectively.

## Layout

Every non-hidden top-level directory is a stow package mirroring `$HOME`:

    zsh/.zshrc                  ->  ~/.zshrc
    nvim/.config/nvim/init.lua  ->  ~/.config/nvim/init.lua

- Never put a file at a package root unless it is a real `$HOME` path.
- **`--no-folding` is mandatory** (`.stowrc` and `install`). Without it `~/.ssh` and `~/.claude` become symlinks into the repo and apps write secrets into git.
- **A new file in a package needs a re-stow:** `stow -d ~/dotfiles -t ~ --no-folding -R <package>`. Edits to existing files apply at once. `-t ~` is explicit because stow's default target is the parent of `-d`.
- `install` globs `*(/)`, which skips dotted directories — repo tooling lives in `.claude/` and needs no exclusion list.
- A stow conflict makes `install` exit 1. `--adopt` resolves it toward the repo, overwriting the tracked file.

## install

zsh, not bash (`read -q`, `print -P`, `$match[]`, `*(/)`, `${+assoc[key]}`) — shellcheck can't parse it.
`set -eu` plus `setopt pipefail`. There is no CI or test suite: `zsh -n install`, a `stow -n` dry run
and `/dotfiles-check` are the whole verification surface.

- **arm64 only:** a guard after flag parsing exits 3 on Intel. Every path hardcodes `/opt/homebrew`; don't add a `/usr/local` fallback.
- **The Brewfile is read from FD 3** (`done 3< Brewfile`): `ask()`'s `read -q` would otherwise eat package lines.
- **`set -e`:** a bare false `(( ))` or `[[ ]]` kills the script, so keep it inside an `if`; as the left side of `&&`/`||` it is exempt. Never end a function with `[[ ]] && cmd` — the call site trips.
- **Stow runs before Oh My Zsh.** `--keep-zshrc` only protects an existing `~/.zshrc`; on a fresh machine OMZ writes its template and stow conflicts.
- `--yes` passes `NONINTERACTIVE=1` to the Homebrew bootstrap, which then uses `sudo -n`.
- `brew_needs_trust` must work before `jq` is installed (taps come first); both guards at its top are load-bearing.
- Failures warn and continue. Only an unknown flag (2), a stow conflict (1) and non-arm64 (3) are fatal.

## Brewfile

Parsed by `install`'s own regex, not `brew bundle`; any other shape is silently skipped:

    ^(brew|cask|tap)[[:space:]]+"([^"]+)"

- Double quotes only, `#` comments start the line, `args:` extras are ignored.
- Taps go in the `# Taps` block, above their packages. Prefer homebrew-core: a tap is a third party trusted to run install code.
- New entries go under the right `# --- Section ---`.
- **Declare the canonical name, never an alias.** The skip-check compares against `brew list --formula`, so an alias is re-prompted every run. Check with `brew info --formula --json=v2 <name> | jq -r '.formulae[0].name'`.
- `install` uses `brew install --formula` on purpose: a bare install picks a same-named cask, which the skip-check never sees.

## Secrets and ignores

- `/.gitignore` allowlists `ssh/` and `claude/`: `ssh/.ssh/*` + `!ssh/.ssh/config`, and `claude/.claude/*` + `!` lines for `settings.json` and `statusline.sh`. **A new tracked file there needs its own `!` re-include**, or git never sees it.
- `git/.config/git/config-work` is ignored outright — the work identity is machine-local, and git skips an `includeIf` whose file is missing.
- `.gitignore` has **no trailing-comment syntax**: `pattern  # note` silently stops matching.
- `/.gitignore` covers this repo; `git/.config/git/ignore` applies to every repo on the machine, so keep it conservative.

## Load order

Wrong order breaks silently.

- **`.zshrc`** — p10k instant prompt first, nothing on stdout before it. `fpath` changes before `source $ZSH/oh-my-zsh.sh` (it runs `compinit`). `fzf-tab` before `zsh-autosuggestions` and `zsh-syntax-highlighting`. `HISTSIZE`/`SAVEHIST` after the OMZ source.
- **`.p10k.zsh`** — the option-restore lines at the bottom stay outside the anonymous function: inside it, `emulate -L zsh` scopes them away, `no_aliases` leaks and every alias dies. Don't bring back a `setopt aliases` workaround.
- **`.zprofile`** — `typeset -U path PATH` first; `.zshrc` repeats it because non-login shells skip `.zprofile`.
- **`ssh/.ssh/config`** — first match wins. `Include ~/.ssh/config.local`, then OrbStack's, both above `Host *`, which stays last. `KexAlgorithms` strips with `-` so the post-quantum defaults stay; never pin it. `Ciphers`, `MACs` and `HostKeyAlgorithms` replace the defaults; a legacy host gets a `+` value in `config.local`.
- **`.gitconfig`** — `[includeIf "gitdir/i:~/work/"]` stays last; `gitdir/i` because the filesystem is case-insensitive. `[delta]` is the single source of truth; lazygit runs bare `delta`.

## Conventions

- Config files use `# ====` section banners, and `install` and `Brewfile` add `# --- Sub-section ---` inside them. 4-space indent, 2 for yml/yaml/json (`.editorconfig`).
- **Comments are terse:** one line per fact, only where losing it lets a known bug back in. Prefer a trailing `# note`; never a paragraph; never restate the code.
- **Ghostty and `.gitignore` have no trailing comments** — a `# note` folds into the value. Put comments on their own line.
- `zsh/.p10k.zsh` is generated; leave its `# === Name ===` style alone.
- When a package is added or removed, update the README's package table.

## Neovim

- Sized for quick terminal edits; real work happens in Rider and VS Code.
- Plugins come **only from the built-in `vim.pack`**, pinned by the tracked `nvim-pack-lock.json`, which it writes in place through the stow link: catppuccin, nvim-tree, nvim-web-devicons, nvim-treesitter (`main`; parsers built with `tree-sitter-cli`, since 0.12 ships no Elixir, HEEx or F# highlighting), gitsigns, fzf-lua. Ask before adding one.
- Every `setup()` is guarded by `pcall(require, ...)`, so a declined install still leaves a working editor — `EDITOR=nvim` opens commit messages.
- **No LSP, diagnostics or formatter**, and no keymaps for them.

## Vendored statusline

`claude/.claude/statusline.sh` comes from [ClaudeCodeStatusLine](https://github.com/daniel3303/ClaudeCodeStatusLine).
Keep it bash 3.2-compatible and don't restyle it. It is MIT, Copyright (c) 2025 Daniel Oliveira — the
licence header must survive every edit.
