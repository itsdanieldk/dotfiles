#!/usr/bin/env bash
# Display brightness for the BUILT-IN screen.

source "$HOME/.config/sketchybar/colors.sh"

if [ "$SENDER" = "brightness_change" ] && [ -n "$INFO" ]; then
    pct="$INFO"
else
    pct="$(python3 -c '
import ctypes, sys

ds = ctypes.CDLL("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices")
ds.DisplayServicesGetBrightness.argtypes = [ctypes.c_uint32, ctypes.POINTER(ctypes.c_float)]
ds.DisplayServicesGetBrightness.restype = ctypes.c_int

for d in range(1, 17):
    b = ctypes.c_float()
    if ds.DisplayServicesGetBrightness(ctypes.c_uint32(d), ctypes.byref(b)) == 0:
        print(round(b.value * 100))
        sys.exit()
sys.exit(1)
' 2>/dev/null)"
fi

case "$pct" in
    ''|*[!0-9]*) sketchybar --set "$NAME" drawing=off; exit 0 ;;
esac

if   [ "$pct" -ge 66 ]; then icon="󰃠"
elif [ "$pct" -ge 33 ]; then icon="󰃟"
else                         icon="󰃞"
fi

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$YELLOW" \
    label.drawing=on label.color="$TEXT" label="${pct}%" icon.padding_right=3
