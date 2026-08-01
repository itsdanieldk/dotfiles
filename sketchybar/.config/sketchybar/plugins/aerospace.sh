#!/usr/bin/env bash
# Workspace indicator. One item per workspace; $1 is the workspace this item
# represents.

source "$HOME/.config/sketchybar/colors.sh"

sid="$1"

focused="$FOCUSED_WORKSPACE"
if [ -z "$focused" ]; then
    focused="$(aerospace list-workspaces --focused 2>/dev/null)"
fi

if [ "$sid" = "$focused" ]; then
    sketchybar --set "$NAME" \
        background.drawing=on \
        label.color="$CRUST" \
        icon.color="$CRUST"
elif aerospace list-workspaces --monitor all --empty no 2>/dev/null | grep -qx "$sid"; then
    sketchybar --set "$NAME" \
        background.drawing=off \
        label.color="$TEXT" \
        icon.color="$TEXT"
else
    sketchybar --set "$NAME" \
        background.drawing=off \
        label.color="$SURFACE2" \
        icon.color="$SURFACE2"
fi
