#!/usr/bin/env bash
# Volume. Driven by sketchybar's native volume_change event ($INFO = the new
# percentage), so there is no polling.
#
# NOT EVERY OUTPUT DEVICE HAS A VOLUME. Class-compliant USB interfaces set their
# level in hardware and expose no software control at all — measured on a
# Focusrite Scarlett 2i2 4th Gen, which has neither kAudioDevicePropertyVolumeScalar
# nor kAudioDevicePropertyMute on any scope or element. macOS greys its own slider
# out for these. That is a NORMAL state for such a device, not a failure, and this
# script's job is then to show nothing rather than to invent a number.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

# ONE osascript call for both readings. This used to be two — one for the level
# and one for the mute state — which is how the bug below survived: the two code
# paths disagreed about what an unreadable device looked like.
settings="$(osascript -e 'get volume settings' 2>/dev/null)"

# "output volume:50, input volume:100, alert volume:100, output muted:false"
# Parameter expansion rather than sed/awk, to keep this to a single subprocess.
# `#*output volume:` is safe despite "alert volume" also containing "volume" —
# it matches the shortest prefix, and "output volume" is the first field.
vol="${settings#*output volume:}"
vol="${vol%%,*}"
muted="${settings##*output muted:}"

# THE READABILITY TEST, AND IT RUNS BEFORE $SENDER IS CONSULTED. Two traps, both
# measured rather than guessed:
#
#   1. osascript prints the literal string "missing value" and EXITS 0 for a
#      device with no software volume. So the value is not empty, and the obvious
#      `[ -z "$vol" ]` guard sails straight past it — which is exactly how this
#      item came to render "missing value%" on the bar.
#
#   2. $INFO CANNOT BE TRUSTED HERE EITHER, so this test must not be skipped on
#      the volume_change path. sketchybar's own handler (src/volume.c) declares
#      `float volume_main = 0.f`, ignores the return of AudioObjectGetPropertyData,
#      and posts the untouched 0 when the read fails. device_changed() calls that
#      handler on every default-output-device switch, so switching TO such a
#      device delivers $INFO=0 — which would render as a confident "0%". That is
#      worse than the visible garbage it replaced, because it looks plausible.
#
# An unreadable volume is not a volume of zero. The bar never states a level it
# does not actually know — the same rule thermals follows in system.sh.
case "$vol" in
    '' | *'missing value'*)
        # See `updates=on` on this item in sketchybarrc: under the config-wide
        # when_shown default a hidden item stops receiving its subscribed events,
        # so this line would be a ONE-WAY DOOR and plugging in headphones later
        # could never bring the item back.
        sketchybar --set "$NAME" drawing=off
        exit 0
        ;;
esac

# Only now is the fast path safe: the device is known to have a readable volume,
# so a volume_change event's $INFO is a real percentage and is fresher than the
# reading above.
if [ "$SENDER" = "volume_change" ] && [ -n "$INFO" ]; then
    vol="$INFO"
fi

# A device can report a level but no mute state; treat that as not muted rather
# than letting "missing value" fall through the string comparison by accident.
case "$muted" in
    *'missing value'*) muted="false" ;;
esac

# Muted reads 0%, not "muted": it is the same quantity as every other state of
# this item rather than a different kind of thing, so it lines up with the
# neighbouring percentages instead of making the pill jump width. The struck-out
# speaker icon is what carries "muted" — note this branch also catches a genuine
# 0% that is not muted, which is why the icon does the work and the text does not.
if [ "$muted" = "true" ] || [ "$vol" -eq 0 ] 2>/dev/null; then
    sketchybar --set "$NAME" drawing=on icon="󰖁" icon.color="$OVERLAY0" \
        label.color="$OVERLAY0" label="0%"
    exit 0
fi

if   [ "$vol" -ge 60 ]; then icon="󰕾"
elif [ "$vol" -ge 30 ]; then icon="󰖀"
else                         icon="󰕿"
fi

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$LAVENDER" \
    label.color="$TEXT" label="${vol}%"
