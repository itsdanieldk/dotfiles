#!/usr/bin/env bash
# Name of the frontmost app. $INFO carries it on the front_app_switched event.

if [ "$SENDER" = "front_app_switched" ] && [ -n "$INFO" ]; then
    app="$INFO"
else
    app="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)"
fi

sketchybar --set "$NAME" label="${app:-—}"
