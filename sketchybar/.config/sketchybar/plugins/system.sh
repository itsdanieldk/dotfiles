#!/usr/bin/env bash
# CPU load, memory, temperature and fan speed.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

require macmon

IFS=$'\t' read -r ok rpm cpu_pct ram_used ram_pct <<EOF
$(macmon pipe -s 1 -i 100 2>/dev/null | python3 -c '
import json, sys

try:
    d = json.loads(sys.stdin.readline())
except Exception:
    print(0, -1, 0, 0, 0, sep=chr(9))
    sys.exit()

fans = d.get("fans", []) or []
rpm = max((f.get("rpm", 0) for f in fans), default=0) if fans else -1
cpu = round((d.get("cpu_usage_pct") or 0) * 100)

mem = d.get("memory", {}) or {}
total = mem.get("ram_total") or 0
used = mem.get("ram_usage") or 0
gib = used / (1024 ** 3)
pct = round(used * 100 / total) if total else 0

print(1, round(rpm), cpu, "%.1f" % gib, pct, sep=chr(9))
')
EOF

if [ "$ok" != "1" ]; then
    sketchybar --set thermals drawing=off --set cpu drawing=off --set memory drawing=off
    exit 0
fi

temp=""
if bin="$(ensure_helper thermal)"; then
    temp="$("$bin" 2>/dev/null)"
    case "$temp" in
        ''|*[!0-9.]*) temp="" ;;
    esac
fi

if [ -n "$temp" ]; then
    temp="$(printf '%.0f' "$temp")"
    if   [ "$temp" -ge 85 ]; then temp_color="$RED"
    elif [ "$temp" -ge 70 ]; then temp_color="$PEACH"
    elif [ "$temp" -ge 55 ]; then temp_color="$YELLOW"
    else                          temp_color="$GREEN"
    fi
else
    temp_color="$OVERLAY0"
fi

if   [ "$cpu_pct" -ge 80 ]; then cpu_color="$RED"
elif [ "$cpu_pct" -ge 50 ]; then cpu_color="$PEACH"
elif [ "$cpu_pct" -ge 25 ]; then cpu_color="$YELLOW"
else                             cpu_color="$GREEN"
fi

if   [ "$ram_pct" -ge 90 ]; then ram_color="$RED"
elif [ "$ram_pct" -ge 75 ]; then ram_color="$PEACH"
else                             ram_color="$TEXT"
fi

if [ -n "$temp" ] && [ -n "$rpm" ] && [ "$rpm" -ge 0 ]; then
    thermal_label="${temp}° 󰈐 ${rpm}"
elif [ -n "$temp" ]; then
    thermal_label="${temp}°"
elif [ -n "$rpm" ] && [ "$rpm" -ge 0 ]; then
    thermal_label="󰈐 ${rpm}"
else
    thermal_label="—"
fi

sketchybar \
    --set cpu drawing=on icon="󰓅" icon.color="$cpu_color" \
        label.color="$TEXT" label="${cpu_pct}%" \
    --set memory drawing=on icon="󰍛" icon.color="$ram_color" \
        label.color="$TEXT" label="${ram_used}G" \
    --set thermals drawing=on icon="󰔏" icon.color="$temp_color" \
        label.color="$TEXT" label="$thermal_label"
