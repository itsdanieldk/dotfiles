#!/usr/bin/env bash
# Shared plugin helpers.
#
# Source AFTER colors.sh:
#     source "$HOME/.config/sketchybar/colors.sh"
#     source "$HOME/.config/sketchybar/lib.sh"
#
# Every function assumes $NAME is set — sketchybar sets it when it runs a plugin.
# Running a plugin by hand without NAME produces `sketchybar --set "" ...`, which
# errors unhelpfully; that is the one case worth knowing about when debugging.
#
# WHY THIS EXISTS: before it, `hide()` was defined identically in three plugins,
# the truncate idiom was copy-pasted into three more, the helper build-on-demand
# block existed twice, and one plugin had a six-line osascript block duplicated
# verbatim inside itself. None of that is hard to write; all of it is easy to fix
# in one place and forget in the other five.

# ---------------------------------------------------------------
# Hide this item and exit.
#
# The single most repeated idiom in the plugins, and the one with a trap: an item
# that hides itself MUST also be declared `updates=on` in sketchybarrc. Under the
# config-wide `updates=when_shown` default a hidden item stops being updated
# entirely — bar_item_update() gates timed AND event runs behind
# `updates_only_when_shown ? is_shown : true`, and bar_draw() clears the bar
# association of anything it does not draw. The item then works right after a
# reload, hides itself, and never runs again, silently. Eight items were found in
# that state. scripts/lint-sketchybar.sh checks for it.
#
# It closes any popup too. Two of the three plugins that had their own hide()
# did that, and the third has no popup — and `popup.drawing=off` on an item
# without one is accepted silently (verified), so doing it unconditionally is
# safe and removes a footgun: a bare `hide` that left a popup open on screen
# would be a subtle, rare bug to chase.
#
# Extra arguments are passed through for anything else an item needs to reset.
hide() {
    sketchybar --set "$NAME" drawing=off popup.drawing=off "$@"
    exit 0
}

# ---------------------------------------------------------------
# Truncate to at most $2 characters, appending an ellipsis if it was cut.
#
# Pure parameter expansion. The idiom this replaces —
#     printf '%s' "$s" | cut -c1-"$n"
# — is a pipeline of two subprocesses, run on every invocation of every plugin
# that displays a name. `cut -c` also counts BYTES in some implementations while
# ${#s} and ${s:0:n} count characters, so the old form truncated UTF-8 names
# mid-codepoint; this does not.
truncate_label() {
    local s=$1 n=$2
    if [ "${#s}" -gt "$n" ]; then
        printf '%s…' "${s:0:n}"
    else
        printf '%s' "$s"
    fi
}

# ---------------------------------------------------------------
# Path for a plugin's cache or state file, e.g. state_file weather.
#
# $TMPDIR rather than /tmp: it is per-user and cleaned by macOS, so nothing
# accumulates and no other user can read or pre-create these paths.
state_file() {
    printf '%s/sketchybar-%s' "${TMPDIR:-/tmp}" "$1"
}

# ---------------------------------------------------------------
# Ensure a compiled Swift helper exists and is current; echo its path.
# Returns non-zero if it cannot be built, so callers can degrade.
#
#     bin="$(ensure_helper thermal)" || bin=""
#
# Rebuilds when the binary is missing OR older than the source, so a `git pull`
# that changes a helper does not require re-running ./install.
ensure_helper() {
    local name=$1
    local dir="$HOME/.config/sketchybar/helpers"
    local src="$dir/$name.swift" bin="$dir/$name"

    if [ ! -x "$bin" ] || [ "$src" -nt "$bin" ]; then
        [ -r "$src" ] || return 1
        command -v swiftc >/dev/null 2>&1 || return 1
        if swiftc -O -o "$bin.new" "$src" >/dev/null 2>&1; then
            mv "$bin.new" "$bin"
        else
            rm -f "$bin.new"
            return 1
        fi
    fi
    printf '%s' "$bin"
}

# ---------------------------------------------------------------
# Require an external command, or hide the item and say why.
#
# Most plugins here depend on something Homebrew installed — aerospace, macmon,
# gh, icalBuddy. Without this they fail into empty output and then hide, which is
# indistinguishable from "nothing to report". The stderr line is what makes a
# missing dependency diagnosable rather than merely quiet.
require() {
    command -v "$1" >/dev/null 2>&1 && return 0
    printf 'sketchybar/%s: missing dependency: %s\n' "${NAME:-?}" "$1" >&2
    hide
}
