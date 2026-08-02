#!/usr/bin/env bash
# Microphone-in-use indicator — the same signal as the orange dot in the menu
# bar. Hidden unless something is actually recording.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

bin="$(ensure_helper mic)" || hide

[ "$("$bin" 2>/dev/null)" = "on" ] || hide

sketchybar --set "$NAME" drawing=on \
    icon="󰍬" icon.color="$RED" \
    label.drawing=off \
    icon.padding_right=6
