#!/usr/bin/env bash
# 24-hour clock with the date. Updated on a timer from sketchybarrc.

sketchybar --set "$NAME" label="$(date '+%a %d %b %H:%M')"
