#!/usr/bin/env bash
# Wi-Fi. Driven by the native wifi_change event ($INFO = the new SSID, empty on
# disconnect), with a query for the startup pass.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

# CACHED, because the device name does not change between reboots and the lookup
# is the most expensive thing in this script: `networksetup -listallhardwareports`
# measured 40ms, and it ran on every single invocation to rediscover a constant.
# $TMPDIR is cleared by macOS, so the cache re-warms on reboot, which is exactly
# when the answer could legitimately differ.
DEV_CACHE="$(state_file wifi-dev)"
if [ -s "$DEV_CACHE" ]; then
    read -r dev < "$DEV_CACHE"
else
    dev="$(networksetup -listallhardwareports 2>/dev/null \
        | awk '/Hardware Port: Wi-Fi/{getline; print $2; exit}')"
    dev="${dev:-en0}"
    printf '%s' "$dev" > "$DEV_CACHE"
fi

case "$(ifconfig "$dev" 2>/dev/null)" in
    *"status: active"*) up=1 ;;
    *)                  up=0 ;;
esac

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
