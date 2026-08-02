#!/usr/bin/env bash
# CPU load, memory, temperature and fan speed.
#
# TWO SOURCES, DELIBERATELY. macmon supplies load, memory and fan RPM from ONE
# sample; the temperature comes from helpers/thermal instead. macmon's
# temp.cpu_temp_avg used to drive this item and is not trustworthy — it is
# bimodal at flat idle and drops as far as 20°C. The full measurement is in the
# header of thermal.swift; the short version is that it is a mean over a varying
# set of sensors, so the bar was faithfully displaying a bogus number.

source "$HOME/.config/sketchybar/colors.sh"

HELPER_DIR="$HOME/.config/sketchybar/helpers"
SRC="$HELPER_DIR/thermal.swift"
BIN="$HELPER_DIR/thermal"

# ONE SAMPLE, THREE ITEMS: a macmon sample costs ~0.7s, so only `thermals` runs
# this script; it writes cpu and memory too. cpu and memory are passive — no
# script, no update_freq — and would never update on their own.
#
# The leading `ok` field is what distinguishes "macmon failed" from "macmon says
# zero". It has to be explicit: the temperature used to serve as that signal, and
# now that it comes from elsewhere there is nothing else in the row that cannot
# legitimately be 0.
IFS=$'\t' read -r ok rpm cpu_pct ram_used ram_pct <<EOF
$(macmon pipe -s 1 -i 100 2>/dev/null | python3 -c '
import json, sys

try:
    d = json.loads(sys.stdin.readline())
except Exception:
    print(0, -1, 0, 0, 0, sep=chr(9))
    sys.exit()

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

print(1, round(rpm), cpu, "%.1f" % gib, pct, sep=chr(9))
')
EOF

if [ "$ok" != "1" ]; then
    sketchybar --set thermals drawing=off --set cpu drawing=off --set memory drawing=off
    exit 0
fi

# Build the temperature helper on demand, exactly as mic.sh does, so a git pull
# that changes the source does not need a re-run of ./install.
if [ ! -x "$BIN" ] || [ "$SRC" -nt "$BIN" ]; then
    if [ -r "$SRC" ] && command -v swiftc >/dev/null 2>&1; then
        swiftc -O -o "$BIN.new" "$SRC" >/dev/null 2>&1 && mv "$BIN.new" "$BIN" || rm -f "$BIN.new"
    fi
fi

# A missing temperature must NOT hide the island. cpu and memory came from macmon
# and are still good; only the reading we could not take goes away. Same rule as
# volume.sh and brightness.sh — never state a value we do not know.
temp="$("$BIN" 2>/dev/null)"
case "$temp" in
    ''|*[!0-9.]*) temp="" ;;
esac

# The helper prints one decimal — precise enough to watch the die move while
# debugging, but the bar shows a whole number. A tenth of a degree is not
# information anyone acts on, and it keeps the pill one character narrower.
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

# ONE space each side of the fan glyph, not two. This read lopsided because it
# was, and the imbalance is in the glyph's own metrics rather than in the spaces.
# Measured per-glyph ink at label.font 13.5 (FiraCodeNF-Med), which is the face
# sketchybar actually resolves "FiraCode Nerd Font:Medium" to:
#   ° ink ends 22.22, right side bearing 2.70
#   󰈐 advance 8.31 but ink 11.26 wide — ZERO left side bearing, and it
#     OVERFLOWS its own cell by ~2.95 on the right
#   1 left side bearing 1.12
# So the fan glyph hugs whatever precedes it and crowds whatever follows:
#   gap before = 2.70 + 8.31 + 0.00  = 11.01pt
#   gap after  = 8.31 - 2.95 + 1.12  =  6.48pt
# A second space added 8.31 to the gap that was ALREADY the larger one, making
# it 19.32 vs 6.48 — a 3:1 split, which is what the eye caught.
# The residual 4.5pt cannot be closed with space characters: FiraCode is
# monospaced and has no thin/hair space at all (U+2009, U+200A, U+2006 are
# absent; U+2008 exists but is a full 8.31 cell), so reaching for one would only
# trigger the font fallback this config warns about elsewhere. 8.31 is the only
# quantum available, and one is closer than two.
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
    `# md-speedometer, not md-cpu_64_bit: cpu sits directly beside memory in` \
    `# island.system, and md-cpu_64_bit is a detailed chip that reads as almost` \
    `# the same picture as md-memory at icon sizes (13pt when this was chosen,` \
    `# 14.5 now — still too close to tell apart at a glance).` \
    --set cpu drawing=on icon="󰓅" icon.color="$cpu_color" \
        label.color="$TEXT" label="${cpu_pct}%" \
    --set memory drawing=on icon="󰍛" icon.color="$ram_color" \
        label.color="$TEXT" label="${ram_used}G" \
    --set thermals drawing=on icon="󰔏" icon.color="$temp_color" \
        label.color="$TEXT" label="$thermal_label"
