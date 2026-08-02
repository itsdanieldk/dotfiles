#!/usr/bin/env bash
# Repaints EVERY workspace pill from ONE pass. Driven by the spaces.driver item.
#
# WHY THIS REPLACED aerospace.sh, which was per-item:
# there is one sketchybar item per workspace (space.1 .. space.9), and each one
# used to run its own copy of the plugin, and each copy shelled out to
# `aerospace list-workspaces --monitor all --empty no` to ask a GLOBAL question —
# which workspaces have windows — whose answer is identical for all nine.
#
# Measured: 25ms per aerospace call, 104ms for nine sequential calls, plus nine
# `grep` subprocesses. And the items were subscribed to front_app_switched as
# well as aerospace_workspace_change, so that ran on every APPLICATION SWITCH,
# which is one of the highest-frequency actions a user performs.
#
# This does 2 aerospace calls and 1 sketchybar call, total, however many
# workspaces exist. The occupancy test is parameter expansion rather than a
# `grep` per item.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

require aerospace

# FOCUSED_WORKSPACE is set by aerospace's exec-on-workspace-change; fall back to
# a query for the startup pass and for front_app_switched, which does not carry it.
focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"

# Sentinel spaces on both ends so the substring test below cannot match a prefix.
# Workspaces are single digits today, so "1" could never be found inside "10" —
# but the guard is free and this is exactly the bug that appears the day someone
# adds a tenth workspace.
occupied=" $(aerospace list-workspaces --empty no 2>/dev/null | tr '\n' ' ')"

args=()
for sid in $(aerospace list-workspaces --all 2>/dev/null); do
    if [ "$sid" = "$focused" ]; then
        # The mauve pill. This is the only place background.drawing is turned on
        # for a workspace item; the bracket renders below its members, so the
        # pill draws on top of the island rather than being hidden by it.
        args+=(--set "space.$sid"
               background.drawing=on label.color="$CRUST" icon.color="$CRUST")
    elif [ "${occupied#* $sid }" != "$occupied" ]; then
        args+=(--set "space.$sid"
               background.drawing=off label.color="$TEXT" icon.color="$TEXT")
    else
        args+=(--set "space.$sid"
               background.drawing=off label.color="$SURFACE2" icon.color="$SURFACE2")
    fi
done

# One call. Nine --set clauses in a single message is dramatically cheaper than
# nine invocations, and it repaints atomically so the pill never appears on two
# workspaces at once mid-update.
[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
