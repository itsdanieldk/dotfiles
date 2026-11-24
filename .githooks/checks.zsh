#!/usr/bin/env zsh
# ============================================================
# Repo checks
# ============================================================
# --staged checks the index (pre-commit: the user stages selectively); without it, the tracked tree (CI).
# No set -e: every check runs, and the exit status says whether any failed.
setopt pipefail

cd "$(git rev-parse --show-toplevel)" || exit 1

staged=false
if [[ ${1-} == --staged ]]; then staged=true; fi

fail=0
problem() { print -u2 -P "%F{red}✘%f $1"; fail=1 }

content() {
    if $staged; then git show ":$1"; else cat -- "$1"; fi
}

if $staged; then
    files=(${(f)"$(git diff --cached --name-only --diff-filter=ACMR)"})
else
    files=(${(f)"$(git ls-files)"})
fi


# --- zsh syntax ---
for f in ${(M)files:#(install|zsh/.zshrc|zsh/.zprofile|zsh/.zimrc|.githooks/*)}; do
    content $f | zsh -n || problem "zsh syntax: $f"
done


# --- Brewfiles ---
# install's regex: any other line shape is silently skipped. Stricter on mas: without id: install runs `mas install ""`.
brewfiles=(${(M)files:#Brewfile*})  # an array first: inside (( )) the filter would see one joined string
for f in $brewfiles; do
    bad=$(content $f | grep -nvE '^[[:space:]]*(#|$)' \
        | grep -vE '^[0-9]+:((brew|cask|tap|vscode)[[:space:]]+"[^"]+"|mas[[:space:]]+"[^"]+",[[:space:]]*id:[[:space:]]*[0-9]+)')
    if [[ -n $bad ]]; then
        problem "$f: lines install would skip:"
        print -u2 -r -- "$bad"
    fi
done

if (( ${#brewfiles} )); then
    tracked=(${(f)"$(git ls-files)"})
    dups=$(for f in ${(M)tracked:#Brewfile*}; do content $f; done \
        | grep -oE '^(brew|cask|tap|mas|vscode)[[:space:]]+"[^"]+"' | sort | uniq -d)
    if [[ -n $dups ]]; then
        problem "declared in more than one Brewfile:"
        print -u2 -r -- "$dups"
    fi
fi


# --- Structured configs ---
# A parse error makes the app fall back to its defaults without a word.
if command -v jq >/dev/null; then
    for f in ${(M)files:#*.json}; do
        content $f | jq empty 2>/dev/null || problem "invalid JSON: $f"
    done
fi
if command -v yq >/dev/null; then
    for f in ${(M)files:#*.(yml|yaml)}; do
        content $f | yq -p yaml . - >/dev/null 2>&1 || problem "invalid YAML: $f"
    done
    for f in ${(M)files:#*.toml}; do
        content $f | yq -p toml . - >/dev/null 2>&1 || problem "invalid TOML: $f"
    done
fi


# --- Shell scripts ---
if command -v shellcheck >/dev/null; then
    for f in ${(M)files:#*.sh}; do
        content $f | shellcheck -S warning -e SC1091 - || problem "shellcheck: $f"
    done
fi


# --- Secrets ---
# The repo is public.
if command -v gitleaks >/dev/null; then
    if $staged; then
        gitleaks git --pre-commit --staged --redact --no-banner . || problem "gitleaks found a secret"
    else
        gitleaks git --redact --no-banner . || problem "gitleaks found a secret"
    fi
else
    print -u2 "gitleaks not installed; secret scan skipped."
fi

exit $fail
