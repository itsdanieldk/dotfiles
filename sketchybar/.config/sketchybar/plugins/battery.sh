#!/usr/bin/env bash
# Battery percentage and a nerd-font icon. Runs on a timer and on
# power_source_change.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

batt="$(pmset -g batt)"

case "$batt" in
    *%*)
        pct="${batt%%\%*}"        # drop from the '%' onward
        pct="${pct##*[!0-9]}"     # keep the trailing digit run
        ;;
    *)  pct="" ;;                 # no battery — the guard below hides the item
esac

case "$batt" in
    *"; charging"*) charging=1 ;;
    *)              charging=0 ;;
esac

if [ -z "$pct" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

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
