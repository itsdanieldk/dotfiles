#!/usr/bin/env bash
# Display brightness, for whichever display is MAIN.
#
# TWO DISPLAYS, TWO MECHANISMS, and reading the wrong one is how this item spent
# a long time confidently showing 100%:
#
#   BUILT-IN   has a real backlight that macOS owns, so DisplayServicesGetBrightness
#              reports it truthfully.
#
#   EXTERNAL   does not. DisplayServicesGetBrightness SUCCEEDS on a non-Apple
#              external and returns a hardcoded 1.0 — measured on the Samsung
#              here (CGDirectDisplayID 2, builtin=false). It is not stale, it is
#              FABRICATED, which is worse: nothing errors and the number looks
#              plausible. The old version of this script looped display IDs 1..16
#              and took the first call that succeeded, which on a clamshell desk
#              is exactly that lie.
#
# So for an external we read what the DIMMER ACTUALLY DID rather than asking
# macOS. MonitorControl is in software-dimming mode for this display
# (`forceSw(...)=1`, `avoidGamma=0` in app.monitorcontrol.MonitorControl), which
# works by scaling the display's GAMMA RAMP — confirmed by `nm -u` on its binary,
# which imports both _CGSetDisplayTransferByTable and _CGGetDisplayTransferByTable.
# We read the ramp back through the same public API it writes with.
#
# WHY NOT DDC (m1ddc, ddcctl): in software mode MonitorControl never touches the
# monitor's internal DDC brightness, so a DDC read returns an unrelated number
# that happens to look reasonable. It would also cost a ~100-300ms subprocess on
# every poll and put traffic on a bus MonitorControl is already using.
# WHY NOT ASK MonitorControl: it has no .sdef, no NSAppleScriptEnabled, no
# CFBundleURLTypes and no bundled CLI. There is nothing to ask.
# Its `SwBrightness(<name><vendor><model>@<displayID>)` pref does hold the value,
# but that is a private, unversioned key layout — the gamma ramp is the effect
# itself and is public API.
#
# LIMIT: if MonitorControl is switched to hardware/DDC dimming, the ramp stays
# flat and this reports 100% at every real brightness. That is a knowing trade —
# it is no worse than the behaviour this replaced.

source "$HOME/.config/sketchybar/colors.sh"

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

# RED, not the max across channels. Colour-temperature shifters (Night Shift,
# f.lux) rewrite this same ramp, but they scale BLUE and some green while
# leaving red near 1.0; brightness dimming scales all three uniformly. Reading
# red therefore reports brightness alone and ignores the colour shift.
#
# The ramp is monotonic, so its last entry is its maximum — the scale factor the
# dimmer applied. A FLAT ramp (1.0) means no dimming, i.e. a genuine 100%, and
# must still be reported; exiting non-zero is reserved for a failed call, which
# is the only case where the level is truly unknown.
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
