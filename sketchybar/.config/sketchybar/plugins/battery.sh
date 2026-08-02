#!/usr/bin/env bash
# Battery percentage and a nerd-font icon. Runs on a timer and on
# power_source_change.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

batt="$(pmset -g batt)"

# Parameter expansion, not `grep | head | tr`. pmset prints e.g.
#   Now drawing from 'AC Power'
#    -InternalBattery-0 (id=…)	100%; charged; 0:00 remaining present: true
#
# THE NO-BATTERY CASE IS NOT HYPOTHETICAL — it is this machine. A Mac Studio
# prints only the "Now drawing from 'AC Power'" line, with no battery line and no
# percent sign anywhere. So test for '%' FIRST: an earlier version of this parse
# assumed the battery line existed, and on a desktop it happily produced the
# string "Power'" as a percentage.
case "$batt" in
    *%*)
        pct="${batt%%\%*}"        # drop from the '%' onward
        pct="${pct##*[!0-9]}"     # keep the trailing digit run
        ;;
    *)  pct="" ;;                 # no battery — the guard below hides the item
esac

# CHARGING IS NOT THE SAME AS ON AC, and this used to conflate them. The old test
# was `grep -c "AC Power"`, which is true whenever the cable is in — so a battery
# sitting at 100% on mains was painted green as though it were still charging.
# pmset states its own answer: the status field reads "charging", "charged",
# "discharging" or "AC attached". Only the first is actually charging.
case "$batt" in
    *"; charging"*) charging=1 ;;
    *)              charging=0 ;;
esac

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
