#!/usr/bin/env bash
# Microphone-in-use indicator — the same signal as the orange dot in the menu
# bar. Hidden unless something is actually recording.

source "$HOME/.config/sketchybar/colors.sh"

HELPER_DIR="$HOME/.config/sketchybar/helpers"
SRC="$HELPER_DIR/mic.swift"
BIN="$HELPER_DIR/mic"

hide() {
    sketchybar --set "$NAME" drawing=off
    exit 0
}

if [ ! -x "$BIN" ] || [ "$SRC" -nt "$BIN" ]; then
    [ -r "$SRC" ] || hide
    command -v swiftc >/dev/null 2>&1 || hide
    swiftc -O -o "$BIN.new" "$SRC" >/dev/null 2>&1 && mv "$BIN.new" "$BIN" || {
        rm -f "$BIN.new"
        hide
    }
fi

[ "$("$BIN" 2>/dev/null)" = "on" ] || hide

sketchybar --set "$NAME" drawing=on \
    icon="󰍬" icon.color="$RED" \
    label.drawing=off \
    icon.padding_right=6
