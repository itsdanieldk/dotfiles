---
name: dotfiles-check
description: Verify this dotfiles repo -- zsh syntax check on install and the zsh configs, Brewfile parseability against install's actual regex, stow dry-runs for every package, and drift checks for orphan taps, stale .gitignore rules, and a README that no longer matches the tree.
---

There is no CI, no linter, and no test suite in this repo. This is the whole verification surface.

Run every check, then report a single grouped summary — do not stop at the first failure.
**Everything here is read-only or a dry run. Never run the real `stow`, `./install`, or `brew`.**

## 1. zsh syntax

    zsh -n install zsh/.zshrc zsh/.zprofile zsh/.p10k.zsh

A broken `.zshrc` is worse than a broken `install`: it breaks every new terminal. All four are zsh,
not bash — shellcheck cannot parse them, so don't reach for it. A clean exit means they parse, not
that they are correct.

Then eyeball for the three traps `set -eu` sets:
- A bare `(( ... ))` whose expansion is false returns non-zero and kills the script. It must sit
  inside an `if`, as the Xcode CLT wait loop does.
- `[[ ... ]] && cmd` as the **last** statement of a function: the function returns non-zero and
  the call site trips. Anywhere else an AND-OR list is exempt.
- The Brewfile loop must keep reading from FD 3 (`done 3< ${DOTFILES}/Brewfile`). If it is ever
  changed to plain stdin redirection, `ask()`'s `read -q` starts eating package lines.

## 2. Brewfile parseability

`install` parses the Brewfile with a hand-rolled regex, not `brew bundle`. Any line that does not
match is silently skipped — the package just never installs. Check every non-comment, non-blank
line against:

    ^(brew|cask|tap)[[:space:]]+"([^"]+)"

Report any line that fails (single quotes, missing quotes, `mas`/`vscode` verbs, `args:` suffixes
that shift the shape).

Then confirm ordering: every `tap "x"` appears **above** the packages drawn from it, since the file
is walked top to bottom.

## 3. Stow dry-run, every package

For each non-hidden top-level directory (what `install`'s `*(/)` glob matches):

    stow -d ~/dotfiles -t ~ --no-folding -n -R <pkg>

Report conflicts per package. A conflict means `./install` would exit 1.

Also check the inverse — files tracked in a package that are **not** currently symlinked into
`$HOME`. That is the signature of a package that gained a file and was never re-stowed.

## 3a. Dangling and missing symlinks

Two failure modes the dry run alone will not surface. Both have happened here.

**File in a package never linked.** A package gained a file and was never re-stowed, so the app
silently falls back to a default. Walk the packages on disk, not `git ls-files`:

    () {                                # anonymous function, so localoptions actually scopes
        local pkgs=(~/dotfiles/*(/))    # non-dotted only, exactly what install globs
        setopt localoptions globdots nullglob
        for d in $pkgs; do
            for f in ${d}/**/*(.); do
                rel=${f#${d}/}
                # -ef, not -e: also catches an app replacing the symlink with a regular file
                [[ "$HOME/$rel" -ef $f ]] || print "NOT LINKED: ${d:t}/${rel} -> ~/$rel"
            done
        done
    }

Two traps are baked into that snippet. `git ls-files` sees only *tracked* files, so it cannot catch
a deliberately untracked one — `git/.config/git/config-work` is exactly that, and a tracked-only
sweep reports clean while `stow -n -v -R git` shows the missing link. And `**` skips dot-directories
without `globdots`, which hides every `<pkg>/.config/...` path — i.e. almost all of them. Glob the
package list *before* setting `globdots`, or the outer `*(/)` starts matching `.git` and `.claude`.

This check is what missed `nvim/.config/nvim/colors/catppuccin-frappe.lua`, which made Neovim print
`E185: Cannot find color scheme` on every launch while still exiting 0 — so nothing failed loudly.

**Dangling links left by a removed package.** stow only unlinks what the package still contains, so
deleting files from a package strands their links:

    find ~ -maxdepth 1 -type l ! -exec test -e {} \; -print
    find ~/.config ~/.ssh ~/.claude -type l ! -exec test -e {} \; -print

Report both. Neither is fatal; both mean the tree and `$HOME` disagree.

## 4. Secrets allowlist integrity

For `ssh/` and `claude/` (and any other package with an ignore block), confirm every tracked file
has a matching `!` re-include. A tracked file without one is invisible to git:
`git/.config/git/config-work` is ignored deliberately and has no re-include — it is machine-local,
so a tracked copy of it would be the bug.

    git check-ignore -v <path>

Also confirm nothing sensitive slipped in — keys, `known_hosts`, `.credentials.json`, history files.

## 5. Drift

- **Brewfile vs. what is actually installed.** The Brewfile claims to be the source of truth, so
  check it both ways — but **the two directions need different sources**, which is easy to get wrong:

  - *Installed but not declared* → compare against formulae **installed on request**. Never
    `brew list --formula`: that includes every transitive dependency (~100 entries here) and reports
    dozens of phantoms. Not plain `brew leaves` either: it also lists orphaned dependencies (whose
    fix is `autoremove`, not declaring them) and misses a hand-installed formula that something
    else happens to depend on.
  - *Declared but not installed* → compare against **`brew list --formula`**. An on-request or leaf
    list is wrong here, in the opposite direction: a declared formula that something else pulled in
    first (here `node`, via `azurite` and `marp-cli`) is installed but not marked on-request, so it
    would be reported as missing when it is present.
  - *Orphans* → `brew autoremove --dry-run`. Dependencies nothing needs any more; report them
    separately, since the fix is removal.

  The `.name` field is the bare name, so tapped formulae need no prefix stripping; `brew list`
  already prints bare names.

  A mismatch here is also how an **alias** shows up: an entry declared under an alias appears in
  *both* directions at once — missing under the alias, undeclared under the canonical name. That is
  the signature, and the fix is to declare the canonical name. `azd` did this before it was changed
  to `azure-dev`. Confirm with `brew info --formula --json=v2 <name> | jq -r '.formulae[0].name'`.

      declared=$(grep -oE '^brew "[^"]+"' Brewfile | cut -d'"' -f2 | sed 's|.*/||' | sort -u)
      on_request=$(brew info --json=v2 --installed \
          | jq -r '.formulae[] | select(any(.installed[]; .installed_on_request)) | .name' | sort -u)
      comm -13 <(echo "$declared") <(echo "$on_request")                  # undeclared
      comm -23 <(echo "$declared") <(brew list --formula | sort -u)       # missing
      brew autoremove --dry-run                                           # orphans

  Casks have no dependency graph, so `brew list --cask` is correct for both directions there.
  Report both ways: undeclared installs mean the Brewfile no longer rebuilds the machine;
  declared-but-absent means a fresh run would install something the user may not want.

  If a package is ever installed by hand *on purpose*, record it as a `#` comment in the Brewfile
  and subtract it here — otherwise it is reported as drift on every run and the real findings get
  lost in the noise. Comment lines are inert to `install`'s parser, so this costs nothing.

  **Never suggest `brew uninstall --zap` without reading the cask's stanza first.** `--zap` is
  correct for application residue and catastrophic for live user data, and the two are
  indistinguishable from the cask name — `steam`'s stanza trashes the entire Steam library,
  `codex`'s removes `~/.codex` and its auth. Note that `brew info --cask <name>` **truncates** the
  artifact list and can make a zap stanza look absent when it is not; fetch the real one:

      curl -fsSL https://formulae.brew.sh/api/cask/<name>.json

  Casks from third-party taps are not in that API at all, so their stanzas cannot be checked this
  way — default to a plain uninstall, which leaves user data intact and is reversible.
- **Orphan taps and packages**: `tap` lines in the Brewfile whose packages are all gone, and
  comments naming removed tools. Also check `brew tap` output against the Brewfile, and the trust
  file (`$XDG_CONFIG_HOME/homebrew/trust.json` when that variable is set, else
  `~/.homebrew/trust.json`) for taps that are trusted but no longer declared.
- **Stale `.gitignore` rules**: ignore blocks pointing at packages that no longer exist on disk.
- **README drift**: package lists, install steps, script paths, and CI badges that contradict the
  tree. Verify any linked path actually exists. Cross-check three things mechanically: the package
  table against `*(/)`, both Brewfile lists against `Brewfile`, and the numbered install steps
  against `grep -oE 'ask "[^"]+"' install`.

## Report

Group as PASS / FAIL / DRIFT. For each failure give the file, the line, and the one-line fix.
Do not apply fixes unless asked — propose them.
