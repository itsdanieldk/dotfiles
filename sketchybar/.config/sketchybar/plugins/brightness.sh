#!/usr/bin/env bash
# Display brightness, for whichever display is MAIN.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

if [ "$SENDER" = "brightness_change" ] && [ -n "$INFO" ]; then
    pct="$INFO"
else
    pct="$(python3 -c '
import ctypes, sys

cg = ctypes.CDLL("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics")
cg.CGMainDisplayID.restype = ctypes.c_uint32
cg.CGDisplayIsBuiltin.argtypes = [ctypes.c_uint32]
cg.CGDisplayIsBuiltin.restype = ctypes.c_uint32

did = cg.CGMainDisplayID()

if cg.CGDisplayIsBuiltin(did):
    ds = ctypes.CDLL("/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices")
    ds.DisplayServicesGetBrightness.argtypes = [ctypes.c_uint32, ctypes.POINTER(ctypes.c_float)]
    ds.DisplayServicesGetBrightness.restype = ctypes.c_int
    b = ctypes.c_float()
    if ds.DisplayServicesGetBrightness(ctypes.c_uint32(did), ctypes.byref(b)) != 0:
        sys.exit(1)
    print(round(b.value * 100))
    sys.exit()

cg.CGDisplayGammaTableCapacity.argtypes = [ctypes.c_uint32]
cg.CGDisplayGammaTableCapacity.restype = ctypes.c_uint32
cg.CGGetDisplayTransferByTable.argtypes = [
    ctypes.c_uint32, ctypes.c_uint32,
    ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_float),
    ctypes.POINTER(ctypes.c_float), ctypes.POINTER(ctypes.c_uint32),
]
cg.CGGetDisplayTransferByTable.restype = ctypes.c_int

cap = cg.CGDisplayGammaTableCapacity(did)
if cap == 0:
    sys.exit(1)

Table = ctypes.c_float * cap
r, g, b = Table(), Table(), Table()
n = ctypes.c_uint32()
if cg.CGGetDisplayTransferByTable(did, cap, r, g, b, ctypes.byref(n)) != 0 or n.value == 0:
    sys.exit(1)

print(round(r[n.value - 1] * 100))
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
