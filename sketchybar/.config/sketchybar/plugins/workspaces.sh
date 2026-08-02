#!/usr/bin/env bash
# Repaints EVERY workspace pill from ONE pass. Driven by the spaces.driver item.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

require aerospace

focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"
occupied=" $(aerospace list-workspaces --empty no 2>/dev/null | tr '\n' ' ')"

args=()
for sid in $(aerospace list-workspaces --all 2>/dev/null); do
    if [ "$sid" = "$focused" ]; then
        args+=(--set "space.$sid"
               background.drawing=on label.color="$CRUST" icon.color="$CRUST")
    elif [ "${occupied#* $sid }" != "$occupied" ]; then
        args+=(--set "space.$sid"
               background.drawing=off label.color="$TEXT" icon.color="$TEXT")
    else
        args+=(--set "space.$sid"
               background.drawing=off label.color="$SURFACE2" icon.color="$SURFACE2")
    fi
done

[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
