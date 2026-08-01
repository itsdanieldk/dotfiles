#!/usr/bin/env bash
# Pomodoro timer. Click cycles: idle → 25min work → 5min break → idle.

source "$HOME/.config/sketchybar/colors.sh"

STATE="${TMPDIR:-/tmp}/sketchybar-pomodoro"

WORK_MIN=25
BREAK_MIN=5

# md-timer, not md-alarm — an alarm bell reads as "alarm clock" and competes with
# the actual clock two pills to its right. Held in a variable because the idle and
# running branches below both draw it, and they drifted apart the moment they
# didn't share one.
ICON="󱎫"

now=$(date +%s)

phase=""
deadline=0
if [ -r "$STATE" ]; then
    IFS=' ' read -r phase deadline < "$STATE"
fi
[ -n "$deadline" ] || deadline=0

notify() {
    osascript -e "display notification \"$2\" with title \"$1\"" >/dev/null 2>&1
}

start() {
    phase="$1"
    deadline=$((now + $2 * 60))
    printf '%s %s\n' "$phase" "$deadline" > "$STATE"
}

idle() {
    phase=""
    rm -f "$STATE"
}

if [ "$SENDER" = "mouse.clicked" ]; then
    case "$phase" in
        work)  start break "$BREAK_MIN" ;;
        break) idle ;;
        *)     start work "$WORK_MIN" ;;
    esac
elif [ -n "$phase" ] && [ "$now" -ge "$deadline" ]; then
    case "$phase" in
        work)
            notify "Pomodoro" "Work done — ${BREAK_MIN}min break."
            start break "$BREAK_MIN"
            ;;
        *)
            notify "Pomodoro" "Break over."
            idle
            ;;
    esac
fi

if [ -z "$phase" ]; then
    sketchybar --set "$NAME" \
        icon="$ICON" icon.color="$SURFACE2" \
        label.drawing=off \
        icon.padding_right=6 \
        update_freq=0
    exit 0
fi

remaining=$((deadline - now))
[ "$remaining" -lt 0 ] && remaining=0

if [ "$phase" = "work" ]; then
    color="$RED"
else
    color="$GREEN"
fi

sketchybar --set "$NAME" \
    icon="$ICON" icon.color="$color" \
    label.drawing=on label.color="$TEXT" \
    label="$(printf '%d:%02d' $((remaining / 60)) $((remaining % 60)))" \
    icon.padding_right=3 \
    update_freq=1
