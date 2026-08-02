#!/usr/bin/env bash
# Current conditions from wttr.in.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

require curl

LOCATION="${SKETCHYBAR_WEATHER_LOCATION:-}"
CACHE="$(state_file weather)"

if [ "$LOCATION" = "off" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

reading="$(curl -sf --max-time 5 "https://wttr.in/${LOCATION}?format=%C|%t" 2>/dev/null)"

case "$reading" in
    *"|"*"°"*) printf '%s' "$reading" > "$CACHE" ;;
    *)         reading="$(cat "$CACHE" 2>/dev/null)" ;;
esac

if [ -z "$reading" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

condition="${reading%%|*}"
temp="${reading##*|}"

temp="${temp#+}"
temp="${temp%C}"
temp="${temp% }"

lower="$(printf '%s' "$condition" | tr '[:upper:]' '[:lower:]')"
case "$lower" in
    *thunder*)                  icon="󰖓"; color="$YELLOW" ;;
    *snow*|*sleet*|*ice*|*blizzard*) icon="󰖘"; color="$LAVENDER" ;;
    *heavy*rain*|*torrential*)  icon="󰖖"; color="$BLUE" ;;
    *rain*|*drizzle*|*shower*)  icon="󰖗"; color="$BLUE" ;;
    *fog*|*mist*|*haze*)        icon="󰖑"; color="$SURFACE2" ;;
    *overcast*)                 icon="󰖐"; color="$SUBTEXT0" ;;
    *partly*|*cloud*)           icon="󰖕"; color="$SUBTEXT0" ;;
    *clear*|*sunny*)            icon="󰖙"; color="$YELLOW" ;;
    *)                          icon="󰖐"; color="$SUBTEXT0" ;;
esac

sketchybar --set "$NAME" drawing=on \
    icon="$icon" icon.color="$color" \
    label.drawing=on label.color="$TEXT" label="$temp"
