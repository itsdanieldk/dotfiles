#!/usr/bin/env bash
# Amphetamine session state — whether the Mac is being kept awake, and for how
# long. Click toggles an indefinite session on/off.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

draw_off() {
    sketchybar --set "$NAME" icon.color="$OVERLAY0" label="" label.drawing=off \
        icon.padding_right=6
}

if ! pgrep -x Amphetamine >/dev/null 2>&1; then
    draw_off
    exit 0
fi

# One definition, two call sites. This block was previously written out twice,
# verbatim — once here and once after the click below — and the two copies are
# exactly the kind of thing that drifts the first time either is touched.
read_session() {
    local state
    state="$(osascript \
        -e 'tell application "Amphetamine"' \
        -e 'set a to session is active' \
        -e 'set t to session time remaining' \
        -e 'end tell' \
        -e 'return (a as text) & "," & (t as text)' 2>/dev/null)"
    active="${state%%,*}"
    remaining="${state##*,}"
}

read_session

if [ "$SENDER" = "mouse.clicked" ]; then
    if [ "$active" = "true" ]; then
        osascript -e 'tell application "Amphetamine" to end session' >/dev/null 2>&1
    else
        osascript -e 'tell application "Amphetamine" to start new session with options {duration:0, interval:0, displaySleepAllowed:false}' >/dev/null 2>&1
    fi
    # Amphetamine updates its state asynchronously; without this the re-read
    # below races the toggle and paints the previous state.
    sleep 0.4
    read_session
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
