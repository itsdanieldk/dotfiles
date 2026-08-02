#!/usr/bin/env bash
# Catches the AeroSpace failure classes that are INVISIBLE when they happen —
# the sibling of scripts/lint-sketchybar.sh, same philosophy.
#
# AeroSpace's own validator (`reload-config --dry-run --warnings-as-errors`)
# already covers syntax and unknown commands, so this script does NOT re-check
# those. What it adds is the two CROSS-FILE couplings the validator cannot see,
# because each half is individually valid — they are only wrong together:
#
#   * gaps.outer.top must track SketchyBar's bar height. Get it wrong and windows
#     tuck under the bar or leave a band of wallpaper; nothing errors.
#   * the border colour AeroSpace settles on after its focus pulse must match the
#     resting colour in bordersrc. Get it wrong and every focus change "settles"
#     on the old colour; nothing errors.
#
# Plus the ~/.aerospace.toml ambiguity trap, and — when the AeroSpace app is
# actually running — the built-in validator as a bonus.
#
# Run by hand or from CI. Exits non-zero on any failure. The static checks need
# no binary and no running app, so they are CI-safe; the dry-run self-skips.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

TOML="aerospace/.config/aerospace/aerospace.toml"
RC="sketchybar/.config/sketchybar/sketchybarrc"
BORDERS="borders/.config/borders/bordersrc"
CLEARANCE=5   # gaps.outer.top - bar height, by design
fail=0

note() { printf '  %s\n' "$*"; }
bad()  { printf 'FAIL  %s\n' "$*"; fail=1; }

# ---------------------------------------------------------------
# 0. The files must exist where we expect them.
for f in "$TOML" "$RC" "$BORDERS"; do
    [ -f "$f" ] || { bad "missing file: $f"; }
done
[ "$fail" -eq 0 ] || { printf '\nFAIL — repo layout unexpected\n'; exit 1; }

# ---------------------------------------------------------------
# 1. Top gap must equal the SketchyBar bar height + clearance.
#
# aerospace.toml `gaps.outer.top` and sketchybarrc `--bar height` are coupled;
# the comments in both files spell out the +5. The height= match is anchored so
# it does not pick up `background.height=`.
printf '\n== bar height <-> top gap coupling ==\n'
height="$(grep -oE '^[[:space:]]+height=[0-9]+' "$RC" | grep -oE '[0-9]+' | head -1)"
top="$(grep -E '^gaps\.outer\.top' "$TOML" | grep -oE '[0-9]+' | head -1)"
if [ -z "$height" ] || [ -z "$top" ]; then
    bad "could not read height ('$height') or top gap ('$top')"
elif [ "$top" -eq "$((height + CLEARANCE))" ]; then
    note "ok    top=$top == height=$height + $CLEARANCE"
else
    bad "top gap $top != bar height $height + $CLEARANCE (=$((height + CLEARANCE))) — windows will tuck under the bar or leave a band"
fi

# ---------------------------------------------------------------
# 2. Border settle colour must match bordersrc's resting active colour.
#
# on-focus-changed pulses to lavender then back to a mauve; that second (settle)
# colour is the one that must equal bordersrc active_color. Take the LAST
# active_color on the pulse line as the settle value.
printf '\n== border settle colour <-> bordersrc ==\n'
settle="$(grep -E 'active_color=0x' "$TOML" | grep -oE 'active_color=0x[0-9a-fA-F]+' | tail -1 | cut -d= -f2)"
resting="$(grep -oE 'active_color=0x[0-9a-fA-F]+' "$BORDERS" | head -1 | cut -d= -f2)"
if [ -z "$settle" ] || [ -z "$resting" ]; then
    bad "could not read settle ('$settle') or bordersrc active ('$resting')"
elif [ "$settle" = "$resting" ]; then
    note "ok    settle=$settle == bordersrc active=$resting"
else
    bad "on-focus-changed settles on $settle but bordersrc rests at $resting — every focus change will settle on the wrong colour"
fi

# ---------------------------------------------------------------
# 3. No stray ~/.aerospace.toml.
#
# AeroSpace reads EITHER ~/.aerospace.toml OR the XDG path; having both is a
# hard error and the app refuses to start. The repo config lives only at the
# XDG path, so the home-dir file must not exist.
printf '\n== no ambiguous ~/.aerospace.toml ==\n'
if [ -e "$HOME/.aerospace.toml" ]; then
    bad "$HOME/.aerospace.toml exists — AeroSpace will error on the ambiguity with the XDG config"
else
    note "ok    none present"
fi

# ---------------------------------------------------------------
# 4. AeroSpace's own validator, when the app is reachable.
#
# reload-config is a client->server command: it validates the INSTALLED (stowed)
# config and needs the app running. Skip cleanly when the binary is absent (CI)
# or the server is down, so this stays a bonus rather than a false failure.
printf '\n== aerospace validator ==\n'
if ! command -v aerospace >/dev/null 2>&1; then
    note "skip  aerospace not installed"
elif ! aerospace list-workspaces --all >/dev/null 2>&1; then
    note "skip  AeroSpace app not running (validator needs the server)"
elif aerospace reload-config --dry-run --warnings-as-errors >/dev/null 2>&1; then
    note "ok    reload-config --dry-run --warnings-as-errors"
else
    bad "aerospace reload-config --dry-run --warnings-as-errors reported problems"
fi

printf '\n'
if [ "$fail" -eq 0 ]; then printf 'PASS — no silent-failure patterns found\n'
else printf 'FAIL — see above\n'; fi
exit "$fail"
