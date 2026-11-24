---
name: dotfiles-check
description: Verify this dotfiles repo — zsh syntax, Brewfile parseability against install's regex, stow dry-runs for every package, missing and dangling links, the secrets allowlists and gitleaks, and drift between the Brewfile, Homebrew and the README.
---

The pre-commit hook and CI run `.githooks/checks.zsh` (zsh syntax, Brewfile lines and duplicates,
JSON/YAML/TOML parsing, shellcheck, gitleaks); this is the full check on top. Run every check, then report once, grouped.
**Read-only and dry runs only — never the real `stow`, `./install` or `brew`.**

## 1. Syntax and config validation

    zsh .githooks/checks.zsh                                   # the hook's checks, on the tracked tree
    /Applications/Ghostty.app/Contents/MacOS/ghostty +validate-config

`ghostty` is on PATH only inside Ghostty (its shell integration adds it), hence the full path. Also
check that `git config --local core.hooksPath` is `.githooks`, or commits skip the hook.

`install` and the zsh files are zsh, so shellcheck can't parse them. A broken `.zshrc` breaks every new terminal. Then
read `install` for the `set -eu` traps listed in CLAUDE.md: a bare false `(( ))`/`[[ ]]` outside an
`if`, a function ending in `[[ ]] && cmd`, and the Brewfile loop no longer reading from FD 3.

## 2. Brewfile

`install` reads `Brewfile`, then `Brewfile.<profile>` (the profile is in `~/.config/dotfiles/profile`),
then the untracked `Brewfile.local`. Check every `Brewfile*` in the repo. Every non-comment,
non-blank line must match `install`'s regex, or it is silently skipped:

    ^(brew|cask|tap|mas|vscode)[[:space:]]+"([^"]+)"(,[[:space:]]*id:[[:space:]]*([0-9]+))?

Report failures (single quotes, other verbs, `args:` suffixes, a `mas` line without `id:`), and any
entry declared in more than one file. In reading order, every `tap` must come before the packages
drawn from it, and `brew "mas"` and `cask "visual-studio-code"` before the `mas` and `vscode` entries.

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

Every tracked file in `ssh/`, `claude/`, `gh/`, `k9s/` and `git/.config/git/` needs a `!` re-include (`git check-ignore --no-index -v <path>`);
`config-work` and `Brewfile.local` are ignored on purpose and must stay untracked. Nothing sensitive may be tracked: keys,
`known_hosts`, `.credentials.json`, history files. The repo is public, so scan history and the
uncommitted changes:

    gitleaks git --redact --no-banner ~/dotfiles
    gitleaks git --pre-commit --redact --no-banner ~/dotfiles

## 5. Drift

Compare this machine against the files `install` reads for it. A missing profile file means shared
only; report it, since `install` will prompt:

    profile=$(<~/.config/dotfiles/profile 2>/dev/null)
    brewfiles=(Brewfile ${profile:+Brewfile.$profile}(N) Brewfile.local(N))

**Brewfile vs Homebrew**, both ways — each direction needs a different source:

    declared=$(cat $brewfiles | grep -oE '^brew "[^"]+"' | cut -d'"' -f2 | sed 's|.*/||' | sort -u)
    on_request=$(brew info --json=v2 --installed \
        | jq -r '.formulae[] | select(any(.installed[]; .installed_on_request)) | .name' | sort -u)
    comm -13 <(echo "$declared") <(echo "$on_request")                  # undeclared
    comm -23 <(echo "$declared") <(brew list --formula | sort -u)       # missing
    brew autoremove --dry-run                                           # orphans

- _Undeclared_ compares against on-request formulae: `brew list` includes ~100 dependencies, and `brew leaves` lists orphans and misses hand installs that something depends on.
- _Missing_ compares against `brew list`: a declared formula another one pulled in first isn't marked on-request.
- Missing under one name and undeclared under another is an **alias** — declare the canonical name (`brew info --formula --json=v2 <name> | jq -r '.formulae[0].name'`).
- Casks have no dependencies, so `brew list --cask` works both ways. Declared casks come from `cat $brewfiles` too.
- A deliberate hand install is recorded as a `#` comment in the Brewfile; subtract it.
- An undeclared package that another profile's Brewfile declares belongs to that profile: either it was installed here by hand, or this machine's profile is wrong.

**App Store and VS Code**, both ways. App Store ids come from the receipts, so `mas` needn't be installed:

    declared=$(cat $brewfiles | grep -oE '^mas "[^"]+", id: [0-9]+' | grep -oE '[0-9]+$' | sort -u)
    owned=$(for a in /Applications/*.app(N); do [[ -d $a/Contents/_MASReceipt ]] \
        && mdls -raw -name kMDItemAppStoreAdamID $a; echo; done | grep -E '^[0-9]+$' | sort -u)
    comm -3 <(echo "$declared") <(echo "$owned")

    comm -3 <(cat $brewfiles | grep -oE '^vscode "[^"]+"' | cut -d'"' -f2 | tr A-Z a-z | sort -u) \
            <(code --list-extensions | tr A-Z a-z | sort -u)

**Live configs never tracked:** a file under `~/.config/<tool>/` that isn't a repo link, for a tool
that has no package, is drift — a new package or a deliberate omission.

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
