#!/usr/bin/env bash
# Wi-Fi. Driven by the native wifi_change event ($INFO = the new SSID, empty on
# disconnect), with a query for the startup pass.

source "$HOME/.config/sketchybar/colors.sh"

dev="$(networksetup -listallhardwareports 2>/dev/null \
    | awk '/Hardware Port: Wi-Fi/{getline; print $2; exit}')"
dev="${dev:-en0}"

if ifconfig "$dev" 2>/dev/null | grep -q "status: active"; then
    up=1
else
    up=0
fi

if [ "$SENDER" = "wifi_change" ]; then
    ssid="$INFO"
else
    ssid="$(ipconfig getsummary "$dev" 2>/dev/null \
        | awk -F ' SSID : ' '/ SSID : / {print $2; exit}')"
fi

case "$ssid" in
    "<redacted>"|"(null)") ssid="" ;;
esac

if [ "$up" -eq 0 ]; then
    sketchybar --set "$NAME" icon="󰖪" icon.color="$OVERLAY0" \
        label.color="$OVERLAY0" label="offline"
else
    sketchybar --set "$NAME" icon="󰖩" icon.color="$GREEN" \
        label.color="$TEXT" label="${ssid:-Wi-Fi}"
fi
