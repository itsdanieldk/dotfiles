#!/usr/bin/env bash
# Catches the SketchyBar failure classes that are INVISIBLE when they happen.
#
# Every check here exists because the failure it detects looks exactly like
# "working, with nothing to report". That is the property that makes them
# expensive: the bar comes up, the item is simply absent or stale, and nothing
# anywhere says why.
#
# Run by hand, or from CI. Exits non-zero on any failure.
#
# NOT a general shell linter — it defers to shellcheck for that, and runs it if
# present. These are the checks shellcheck cannot make because they are about
# SketchyBar's semantics, not the shell's.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

PLUGINS="sketchybar/.config/sketchybar/plugins"
RC="sketchybar/.config/sketchybar/sketchybarrc"
fail=0

note() { printf '  %s\n' "$*"; }
bad()  { printf 'FAIL  %s\n' "$*"; fail=1; }

# ---------------------------------------------------------------
# 1. Every plugin must be executable.
#
# SketchyBar fork_execs its plugins. When the bit is missing it reports NOTHING
# AT ALL — the item just never updates, which is indistinguishable from a script
# that runs and decides to do nothing. Editors and `git apply` both create files
# without it.
printf '\n== executable bits ==\n'
for f in "$PLUGINS"/*.sh; do
    if [ -x "$f" ]; then note "ok    $(basename "$f")"
    else bad "$(basename "$f") is not executable — sketchybar will never run it"; fi
done

# ---------------------------------------------------------------
# 2. Any item whose plugin can hide it must declare updates=on.
#
# Under the config-wide `updates=when_shown` default a hidden item stops being
# updated ENTIRELY: bar_item_update() gates timed and event runs behind
# `updates_only_when_shown ? is_shown : true`, and bar_draw() clears the bar
# association of anything it does not draw. So the item works right after a
# reload, hides itself when there is nothing to show, and never runs again.
# Eight items were found in that state at once.
printf '\n== self-hiding items declare updates=on ==\n'

# ITEM-level drawing=off only. `label.drawing=off`, `background.drawing=off` and
# `popup.drawing=off` hide a COMPONENT and leave the item drawn and updating —
# amphetamine and pomodoro both dim their label this way and are correctly on the
# when_shown default. Requiring a preceding space excludes the dotted forms.
# Calling hide() or require() counts too: both end in an item-level drawing=off
# inside lib.sh.
can_hide() {
    grep -qE '(^|[[:space:]])drawing=off' "$1" && return 0
    grep -qE '^[[:space:]]*(hide|require)([[:space:]]|$)|\|\|[[:space:]]*hide|&&[[:space:]]*hide' "$1"
}

# Which items a plugin writes. Usually itself, but system.sh writes three.
items_for() {
    case "$(basename "$1" .sh)" in
        system)     printf 'cpu memory thermals' ;;
        workspaces) printf '' ;;   # drives space.N; none of them ever hide
        *)          basename "$1" .sh ;;
    esac
}

for f in "$PLUGINS"/*.sh; do
    can_hide "$f" || continue
    for item in $(items_for "$f"); do
        block="$(awk -v it="$item" '
            $0 ~ ("--add item[[:space:]]+" it "[[:space:]]") {found=1}
            found {print}
            found && /script=/ {exit}' "$RC")"
        # PASSIVE ITEMS ARE NOT AT RISK. cpu and memory carry no script of their
        # own — they are written by thermals' script, which has updates=on and
        # therefore un-hides them on its next run. Only an item that must run its
        # OWN script to recover can be trapped by when_shown.
        if [ -z "$block" ]; then
            bad "item '$item' hides itself but has no --add item block in sketchybarrc"
        elif ! printf '%s' "$block" | grep -q 'script='; then
            note "skip  $item (passive — driven by another item's script)"
        elif printf '%s' "$block" | grep -q 'updates=on'; then
            note "ok    $item"
        else
            bad "item '$item' can set drawing=off but does not declare updates=on"
        fi
    done
done

# ---------------------------------------------------------------
# 3. Cross-references must resolve.
#
# The comments in this repo carry the measurements, so a comment that points at
# a section which no longer exists is a defect, not untidiness. Three were live
# at once: a deleted WIDTH BUDGET section, a privacy note that was never written,
# and a claim that an installed app was not installed.
printf '\n== cross-references resolve ==\n'
while IFS= read -r ref; do
    [ -z "$ref" ] && continue
    target="${ref#see the }"; target="${target% *}"
    if grep -qF "$target" "$RC" "$PLUGINS"/*.sh 2>/dev/null; then
        note "ok    -> $target"
    else
        bad "dangling reference: '$ref' has no target"
    fi
done < <(grep -ohE 'see the [A-Z][A-Z ]{3,}' "$RC" "$PLUGINS"/*.sh 2>/dev/null | sort -u)

# ---------------------------------------------------------------
# 4. shellcheck, if available.
printf '\n== shellcheck ==\n'
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck -S warning -e SC1091 "$PLUGINS"/*.sh \
        sketchybar/.config/sketchybar/lib.sh || fail=1
    note "shellcheck done"
else
    note "skip  shellcheck not installed (brew install shellcheck)"
fi

printf '\n'
if [ "$fail" -eq 0 ]; then printf 'PASS — no silent-failure patterns found\n'
else printf 'FAIL — see above\n'; fi
exit "$fail"
