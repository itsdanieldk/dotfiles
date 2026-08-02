#!/usr/bin/env bash
# Shared plugin helpers.

# The "$@" pass-through is deliberate — it lets a plugin reset one more property
# while hiding. No caller needs it today, which is exactly what SC2120 warns
# about, so the check is a false positive on an API kept open on purpose.
# shellcheck disable=SC2120
hide() {
    sketchybar --set "$NAME" drawing=off popup.drawing=off "$@"
    exit 0
}

truncate_label() {
    local s=$1 n=$2
    if [ "${#s}" -gt "$n" ]; then
        printf '%s…' "${s:0:n}"
    else
        printf '%s' "$s"
    fi
}

state_file() {
    printf '%s/sketchybar-%s' "${TMPDIR:-/tmp}" "$1"
}

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

require() {
    command -v "$1" >/dev/null 2>&1 && return 0
    printf 'sketchybar/%s: missing dependency: %s\n' "${NAME:-?}" "$1" >&2
    hide
}
