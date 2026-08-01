#!/usr/bin/env bash
# Battery percentage and a nerd-font icon. Runs on a timer and on
# power_source_change.

source "$HOME/.config/sketchybar/colors.sh"

batt="$(pmset -g batt)"
pct="$(printf '%s' "$batt" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')"
charging="$(printf '%s' "$batt" | grep -c "AC Power")"

if [ -z "$pct" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

# THE ONE PLACE THIS BAR LEAVES MATERIAL DESIGN. Every other icon is md-*, but
# all 95 md-battery_* glyphs are VERTICAL — the horizontal series (battery_horiz)
# postdates this Nerd Font build and is not present. Font Awesome's battery set
# is horizontal and happens to have exactly the five steps this script already
# used, so it maps 1:1. Checked by scanning every glyph name in the font, not
# assumed.
#
# CHARGING is carried by colour alone, because Font Awesome has no
# battery-with-bolt glyph. Using the md charging icon here would flip the shape
# between vertical and horizontal as the cable goes in and out, which is worse
# than losing the bolt. The level still shows while charging.
if   [ "$pct" -ge 80 ]; then icon=""; color="$TEXT"    # fa-battery_full
elif [ "$pct" -ge 60 ]; then icon=""; color="$TEXT"    # fa-battery_three_quarters
elif [ "$pct" -ge 40 ]; then icon=""; color="$YELLOW"  # fa-battery_half
elif [ "$pct" -ge 20 ]; then icon=""; color="$PEACH"   # fa-battery_quarter
else                         icon=""; color="$RED"     # fa-battery_empty
fi

if [ "$charging" -gt 0 ]; then
    color="$GREEN"
fi

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$color" label="${pct}%"
