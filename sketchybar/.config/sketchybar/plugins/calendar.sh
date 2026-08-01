#!/usr/bin/env bash
# Next calendar event today. Hidden when there is nothing left in the day.

source "$HOME/.config/sketchybar/colors.sh"

MAX_LEN=42

hide() {
    sketchybar --set "$NAME" drawing=off popup.drawing=off
    exit 0
}

case "$SENDER" in
    mouse.entered) sketchybar --set "$NAME" popup.drawing=on;  exit 0 ;;
    mouse.exited)  sketchybar --set "$NAME" popup.drawing=off; exit 0 ;;
esac

command -v icalBuddy >/dev/null 2>&1 || hide

raw="$(icalBuddy -n -nc -nrd -ea -b "" -df "" -tf "%H:%M" -li 1 \
        -iep "datetime,title" -ps "|@|" eventsToday 2>/dev/null)"

[ -n "$raw" ] || hide

start="$(printf '%s' "$raw" | grep -oE '[0-9]{1,2}:[0-9]{2}' | head -1)"
[ -n "$start" ] || hide

title="$(printf '%s' "$raw" \
    | tr '\n@' '  ' \
    | sed -E 's/[0-9]{1,2}:[0-9]{2}( ?- ?[0-9]{1,2}:[0-9]{2})?//g' \
    | sed -E 's/^[[:space:]|]+//; s/[[:space:]|]+$//; s/[[:space:]]+/ /g')"

[ -n "$title" ] || title="(untitled)"

if [ "${#title}" -gt "$MAX_LEN" ]; then
    title="$(printf '%s' "$title" | cut -c1-"$MAX_LEN")…"
fi

sketchybar --set "$NAME" drawing=on \
    icon="󰃭" icon.color="$PEACH" \
    label.drawing=on label.color="$TEXT" label="$start" \
    --set calendar.next label="$title"
