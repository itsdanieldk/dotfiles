#!/usr/bin/env bash
# Unread GitHub notification count. Hidden at zero, which is most of the time.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

require gh

CACHE="$(state_file github)"

count="$(gh api notifications --jq 'length' 2>/dev/null)"

case "$count" in
    ''|*[!0-9]*) count="$(cat "$CACHE" 2>/dev/null)" ;;
    *)           printf '%s' "$count" > "$CACHE" ;;
esac

if [ -z "$count" ] || [ "$count" -eq 0 ] 2>/dev/null; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

if [ "$count" -ge 50 ]; then
    label="50+"
else
    label="$count"
fi

sketchybar --set "$NAME" drawing=on \
    icon="󰊤" icon.color="$MAUVE" \
    label.drawing=on label.color="$TEXT" label="$label"
