#!/usr/bin/env bash
# Volume. Driven by sketchybar's native volume_change event ($INFO = the new
# percentage), so there is no polling.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

settings="$(osascript -e 'get volume settings' 2>/dev/null)"

vol="${settings#*output volume:}"
vol="${vol%%,*}"
muted="${settings##*output muted:}"

case "$vol" in
    '' | *'missing value'*)
        sketchybar --set "$NAME" drawing=off
        exit 0
        ;;
esac

if [ "$SENDER" = "volume_change" ] && [ -n "$INFO" ]; then
    vol="$INFO"
fi

case "$muted" in
    *'missing value'*) muted="false" ;;
esac

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
