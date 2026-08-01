#!/usr/bin/env bash
# Volume. Driven by sketchybar's native volume_change event ($INFO = the new
# percentage), so there is no polling.

source "$HOME/.config/sketchybar/colors.sh"

if [ "$SENDER" = "volume_change" ]; then
    vol="$INFO"
else
    vol="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
fi

muted="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"

# An unreadable volume is not a volume of zero. Kept separate from the branch
# below so the bar never states a level it does not actually know — the same rule
# thermals follows in system.sh.
if [ -z "$vol" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

# Muted reads 0%, not "muted": it is the same quantity as every other state of
# this item rather than a different kind of thing, so it lines up with the
# neighbouring percentages instead of making the pill jump width. The struck-out
# speaker icon is what carries "muted" — note this branch also catches a genuine
# 0% that is not muted, which is why the icon does the work and the text does not.
if [ "$muted" = "true" ] || [ "$vol" -eq 0 ] 2>/dev/null; then
    sketchybar --set "$NAME" drawing=on icon="󰖁" icon.color="$OVERLAY0" \
        label.color="$OVERLAY0" label="0%"
    exit 0
fi

if   [ "$vol" -ge 60 ]; then icon="󰕾"
elif [ "$vol" -ge 30 ]; then icon="󰖀"
else                         icon="󰕿"
fi

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$LAVENDER" \
    label.color="$TEXT" label="${vol}%"
