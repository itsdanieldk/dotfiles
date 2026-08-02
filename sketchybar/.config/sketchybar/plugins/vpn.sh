#!/usr/bin/env bash
# VPN connection state. Hidden unless something is actually connected.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

MAX_LEN=14

name="$(scutil --nc list 2>/dev/null \
    | sed -n 's/^\* (Connected)[^"]*"\([^"]*\)".*/\1/p' \
    | head -1)"

if [ -z "$name" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

name="$(truncate_label "$name" "$MAX_LEN")"

sketchybar --set "$NAME" drawing=on \
    `# md-vpn, not md-shield_lock — a shield reads as firewall/password manager` \
    `# /antivirus just as easily. MDI has a dedicated VPN glyph.` \
    icon="󰖂" icon.color="$GREEN" \
    label.drawing=on label.color="$TEXT" label="$name"
