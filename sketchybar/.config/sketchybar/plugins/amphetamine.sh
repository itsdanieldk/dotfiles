#!/usr/bin/env bash
# Amphetamine session state — whether the Mac is being kept awake, and for how
# long. Click toggles an indefinite session on/off.

source "$HOME/.config/sketchybar/colors.sh"

draw_off() {
    sketchybar --set "$NAME" icon.color="$OVERLAY0" label="" label.drawing=off \
        icon.padding_right=6
}

if ! pgrep -x Amphetamine >/dev/null 2>&1; then
    draw_off
    exit 0
fi

state="$(osascript \
    -e 'tell application "Amphetamine"' \
    -e 'set a to session is active' \
    -e 'set t to session time remaining' \
    -e 'end tell' \
    -e 'return (a as text) & "," & (t as text)' 2>/dev/null)"

active="${state%%,*}"
remaining="${state##*,}"

if [ "$SENDER" = "mouse.clicked" ]; then
    if [ "$active" = "true" ]; then
        osascript -e 'tell application "Amphetamine" to end session' >/dev/null 2>&1
    else
        osascript -e 'tell application "Amphetamine" to start new session with options {duration:0, interval:0, displaySleepAllowed:false}' >/dev/null 2>&1
    fi
    sleep 0.4
    state="$(osascript \
        -e 'tell application "Amphetamine"' \
        -e 'set a to session is active' \
        -e 'set t to session time remaining' \
        -e 'end tell' \
        -e 'return (a as text) & "," & (t as text)' 2>/dev/null)"
    active="${state%%,*}"
    remaining="${state##*,}"
fi

if [ "$active" != "true" ]; then
    draw_off
    exit 0
fi

case "$remaining" in
    0)  label="∞" ;;
    -1) label="trigger" ;;
    -2) label="auto" ;;
    -3) draw_off; exit 0 ;;
    ''|*[!0-9-]*) label="on" ;;
    *)
        h=$(( remaining / 3600 ))
        m=$(( (remaining % 3600) / 60 ))
        if [ "$h" -gt 0 ]; then label="${h}h${m}m"; else label="${m}m"; fi
        ;;
esac

sketchybar --set "$NAME" icon.color="$YELLOW" \
    label.drawing=on label.color="$TEXT" label="$label" \
    icon.padding_right=3
