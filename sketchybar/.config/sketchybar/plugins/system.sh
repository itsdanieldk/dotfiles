#!/usr/bin/env bash
# CPU load, memory, temperature and fan speed — every reading macmon gives us,
# from ONE sample.

source "$HOME/.config/sketchybar/colors.sh"

IFS=$'\t' read -r temp rpm cpu_pct ram_used ram_pct <<EOF
$(macmon pipe -s 1 -i 100 2>/dev/null | python3 -c '
import json, sys

try:
    d = json.loads(sys.stdin.readline())
except Exception:
    print(0, -1, 0, 0, 0, sep=chr(9))
    sys.exit()

temp = d.get("temp", {}).get("cpu_temp_avg") or 0
fans = d.get("fans", []) or []
# Fans are per-side and rarely equal; the louder one is the one you can hear.
rpm = max((f.get("rpm", 0) for f in fans), default=0) if fans else -1

# cpu_usage_pct is a RATIO despite the name — measured 0.0558 for 5.6% load.
cpu = round((d.get("cpu_usage_pct") or 0) * 100)

mem = d.get("memory", {}) or {}
total = mem.get("ram_total") or 0
used = mem.get("ram_usage") or 0
# GiB to one decimal; macmon reports bytes (25769803776 = 24 GiB).
gib = used / (1024 ** 3)
pct = round(used * 100 / total) if total else 0

print(round(temp), round(rpm), cpu, "%.1f" % gib, pct, sep=chr(9))
')
EOF

if [ -z "$temp" ] || [ "$temp" -eq 0 ]; then
    sketchybar --set thermals drawing=off --set cpu drawing=off --set memory drawing=off
    exit 0
fi

if   [ "$temp" -ge 85 ]; then temp_color="$RED"
elif [ "$temp" -ge 70 ]; then temp_color="$PEACH"
elif [ "$temp" -ge 55 ]; then temp_color="$YELLOW"
else                          temp_color="$GREEN"
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

if [ -n "$rpm" ] && [ "$rpm" -ge 0 ]; then
    thermal_label="${temp}°  󰈐 ${rpm}"
else
    thermal_label="${temp}°"
fi

sketchybar \
    `# md-speedometer, not md-cpu_64_bit: cpu sits directly beside memory in` \
    `# island.system, and md-cpu_64_bit is a detailed chip that reads as almost` \
    `# the same picture as md-memory at 13pt.` \
    --set cpu drawing=on icon="󰓅" icon.color="$cpu_color" \
        label.color="$TEXT" label="${cpu_pct}%" \
    --set memory drawing=on icon="󰍛" icon.color="$ram_color" \
        label.color="$TEXT" label="${ram_used}G" \
    --set thermals drawing=on icon="󰔏" icon.color="$temp_color" \
        label.color="$TEXT" label="$thermal_label"
