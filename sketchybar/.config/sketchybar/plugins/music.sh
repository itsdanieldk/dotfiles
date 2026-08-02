#!/usr/bin/env bash
# Apple Music now-playing. Click toggles play/pause.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"


pgrep -x Music >/dev/null 2>&1 || hide

if [ "$SENDER" = "mouse.clicked" ]; then
    case "$BUTTON" in
        right)
            sketchybar --set "$NAME" popup.drawing=toggle
            exit 0
            ;;
        *)
            osascript -e 'tell application "Music" to playpause' >/dev/null 2>&1
            sleep 0.3
            ;;
    esac
fi

IFS=$'\t' read -r state track artist <<EOF
$(osascript \
    -e 'tell application "Music"' \
    -e '  set s to player state as text' \
    -e '  if s is "stopped" then return s' \
    -e '  try' \
    -e '    set n to name of current track' \
    -e '    set a to artist of current track' \
    -e '  on error' \
    -e '    return s' \
    -e '  end try' \
    -e '  return s & tab & n & tab & a' \
    -e 'end tell' 2>/dev/null)
EOF

case "$state" in
    stopped|'') hide ;;
esac
[ -n "$track" ] || exit 0

case "$state" in
    playing|"fast forwarding"|rewinding) icon="󰎇"; color="$GREEN" ;;
    paused)                              icon="󰏤"; color="$OVERLAY0" ;;
    *)                                   exit 0 ;;
esac

if [ -n "$artist" ]; then
    label="$track — $artist"
else
    label="$track"
fi

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$color" \
    label.drawing=on label.color="$TEXT" label="$label"
