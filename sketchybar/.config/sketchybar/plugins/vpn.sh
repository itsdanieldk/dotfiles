#!/usr/bin/env bash
# VPN connection state. Hidden unless something is actually connected.

source "$HOME/.config/sketchybar/colors.sh"

MAX_LEN=14

name="$(scutil --nc list 2>/dev/null \
    | sed -n 's/^\* (Connected)[^"]*"\([^"]*\)".*/\1/p' \
    | head -1)"

if [ -z "$name" ]; then
    sketchybar --set "$NAME" drawing=off
    exit 0
fi

if [ "${#name}" -gt "$MAX_LEN" ]; then
    name="$(printf '%s' "$name" | cut -c1-"$MAX_LEN")…"
fi

sketchybar --set "$NAME" drawing=on \
    `# md-vpn, not md-shield_lock — a shield reads as firewall/password manager` \
    `# /antivirus just as easily. MDI has a dedicated VPN glyph.` \
    icon="󰖂" icon.color="$GREEN" \
    label.drawing=on label.color="$TEXT" label="$name"
