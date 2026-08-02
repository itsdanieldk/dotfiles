#!/usr/bin/env bash
# Bluetooth: power state, and what's actually connected.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

MAX_LEN=8

IFS=$'\t' read -r state label <<EOF
$(system_profiler SPBluetoothDataType -json 2>/dev/null | python3 -c '
import json, sys

try:
    d = json.load(sys.stdin)["SPBluetoothDataType"][0]
except Exception:
    print("error\t")
    sys.exit()

if d.get("controller_properties", {}).get("controller_state") != "attrib_on":
    print("off\t")
    sys.exit()

names = [n for e in d.get("device_connected", []) for n in e]
if not names:
    print("on\t")
elif len(names) == 1:
    print("connected\t" + names[0])
else:
    print(f"connected\t{len(names)} devices")
')
EOF

case "$state" in
    connected)
        case "$label" in
            *' devices') ;;
            *)
                label="$(truncate_label "$label" "$MAX_LEN")"
                ;;
        esac
        sketchybar --set "$NAME" drawing=on icon="󰂱" icon.color="$BLUE" \
            label.drawing=on label.color="$TEXT" label="$label" \
            icon.padding_right=3
        ;;
    on)
        sketchybar --set "$NAME" drawing=on icon="󰂯" icon.color="$OVERLAY0" \
            label.drawing=off icon.padding_right=6
        ;;
    *)
        sketchybar --set "$NAME" drawing=off
        ;;
esac
