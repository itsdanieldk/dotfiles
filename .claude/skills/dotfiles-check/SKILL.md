---
name: dotfiles-check
description: Verify this dotfiles repo — zsh syntax, Brewfile parseability against install's regex, stow dry-runs for every package, missing and dangling links, the secrets allowlists and gitleaks, and drift between the Brewfile, Homebrew and the README.
---

There is no CI, linter or test suite; this is the whole verification surface. Run every check, then
report once, grouped. **Read-only and dry runs only — never the real `stow`, `./install` or `brew`.**

## 1. zsh syntax

    zsh -n install zsh/.zshrc zsh/.zprofile zsh/.p10k.zsh

All four are zsh, so shellcheck can't parse them. A broken `.zshrc` breaks every new terminal. Then
read `install` for the `set -eu` traps listed in CLAUDE.md: a bare false `(( ))`/`[[ ]]` outside an
`if`, a function ending in `[[ ]] && cmd`, and the Brewfile loop no longer reading from FD 3.

## 2. Brewfile

Every non-comment, non-blank line must match `install`'s regex, or it is silently skipped:

    ^(brew|cask|tap)[[:space:]]+"([^"]+)"

Report failures (single quotes, `mas`/`vscode` verbs, `args:` suffixes). Every `tap` must sit above
the packages drawn from it.

## 3. Stow and links

Dry-run every package `install` would stow (the non-dotted top-level directories). A conflict means
`install` would exit 1:

    stow -d ~/dotfiles -t ~ --no-folding -n -R <pkg>

**Files never linked.** A package gained a file and wasn't re-stowed, so the app silently falls back
to a default — that is how a missing Neovim colorscheme went unnoticed. Walk the disk, not
`git ls-files`, so untracked files such as `git/.config/git/config-work` are covered:

    () {                                # anonymous function, so localoptions actually scopes
        local pkgs=(~/dotfiles/*(/))    # glob before globdots, or .git and .claude match
        setopt localoptions globdots nullglob
        for d in $pkgs; do
            for f in ${d}/**/*(.); do
                rel=${f#${d}/}
                # -ef, not -e: also catches an app replacing the symlink with a regular file
                [[ "$HOME/$rel" -ef $f ]] || print "NOT LINKED: ${d:t}/${rel} -> ~/$rel"
            done
        done
    }

An unlinked `nvim/.config/nvim/nvim-pack-lock.json` means `vim.pack` writes a real file instead and
the repo copy stops tracking plugin revisions.

**Dangling links.** stow only unlinks what a package still contains, so deleted files strand theirs:

    find ~ -maxdepth 1 -type l ! -exec test -e {} \; -print
    find ~/.config ~/.ssh ~/.claude -type l ! -exec test -e {} \; -print

## 4. Secrets

Every tracked file in `ssh/` and `claude/` needs a `!` re-include (`git check-ignore -v <path>`);
`config-work` is ignored on purpose and must stay untracked. Nothing sensitive may be tracked: keys,
`known_hosts`, `.credentials.json`, history files. The repo is public, so scan history and the
uncommitted changes:

    gitleaks git --redact --no-banner ~/dotfiles
    gitleaks git --pre-commit --redact --no-banner ~/dotfiles

## 5. Drift

**Brewfile vs Homebrew**, both ways — each direction needs a different source:

    declared=$(grep -oE '^brew "[^"]+"' Brewfile | cut -d'"' -f2 | sed 's|.*/||' | sort -u)
    on_request=$(brew info --json=v2 --installed \
        | jq -r '.formulae[] | select(any(.installed[]; .installed_on_request)) | .name' | sort -u)
    comm -13 <(echo "$declared") <(echo "$on_request")                  # undeclared
    comm -23 <(echo "$declared") <(brew list --formula | sort -u)       # missing
    brew autoremove --dry-run                                           # orphans

- _Undeclared_ compares against on-request formulae: `brew list` includes ~100 dependencies, and `brew leaves` lists orphans and misses hand installs that something depends on.
- _Missing_ compares against `brew list`: a declared formula another one pulled in first isn't marked on-request.
- Missing under one name and undeclared under another is an **alias** — declare the canonical name (`brew info --formula --json=v2 <name> | jq -r '.formulae[0].name'`).
- Casks have no dependencies, so `brew list --cask` works both ways.
- A deliberate hand install is recorded as a `#` comment in the Brewfile; subtract it.

**Never suggest `brew uninstall --zap` without reading the cask's zap stanza** — it can delete live
user data (`steam`'s trashes the whole library). `brew info --cask` truncates the stanza; fetch
`https://formulae.brew.sh/api/cask/<name>.json`. Third-party casks aren't in that API: default to a
plain uninstall.

**Taps** — Brewfile `tap` lines vs `brew tap`, and taps still trusted in
`$XDG_CONFIG_HOME/homebrew/trust.json` (else `~/.homebrew/trust.json`) but no longer declared.

**`.gitignore`** — blocks for packages that no longer exist.

**README** — the package table vs `*(/)`, the install-steps sentence vs
`grep -oE 'ask "[^"]+"' install`, and every relative link resolves.

## Report

Group as PASS / FAIL / DRIFT, each failure with its file, line and a one-line fix. Propose fixes;
don't apply them unless asked.
