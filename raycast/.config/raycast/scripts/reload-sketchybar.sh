#!/usr/bin/env bash
#
# Raycast script command. Raycast indexes every script in a directory added under
# Settings > Script Commands > Add Script Directory; point it at the stowed
# ~/.config/raycast/scripts. Metadata directives are the contract — a script
# missing schemaVersion/title/mode is ignored rather than reported.
# Reference: https://github.com/raycast/script-commands#metadata
#
# @raycast.schemaVersion 1
# @raycast.title Reload SketchyBar
# @raycast.mode silent
# @raycast.icon 🔄
# @raycast.packageName Dotfiles
# @raycast.description Re-read sketchybarrc without restarting the bar.

# A GUI-launched script does not get a login shell's environment. Two variables
# have to be repaired before sketchybar's client will work, both found by running
# this under `env -i`:
#   PATH  sketchybar is a Homebrew binary and is not on a minimal PATH. This is
#         the same repair sketchybarrc makes at the top of itself.
#   USER  the client resolves the running bar's mach port through it and aborts
#         with "sketchybar-msg: 'env USER' not set! abort.." if it is missing.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:$PATH"
export USER="${USER:-$(id -un)}"

# --reload re-executes the config in place, so the bar keeps its PID and nothing
# has to be backgrounded. That matters here: a process this script leaves running
# is at the mercy of how Raycast reaps the script's children, which is not
# something this config controls.
#
# NOT extended to borders on purpose. `man borders`: bordersrc is read only "if no
# instance of borders is running", so reloading borders means kill-and-restart —
# exactly the backgrounding this avoids. Restarting both is what
# aerospace's after-startup-command is for.
#
# mode=silent closes the Raycast window and shows the last line below as a HUD, so
# the message has to be earned. `--reload` cannot report the case that matters:
# measured, with no bar running it is a silent no-op that still exits 0, so an
# `if sketchybar --reload` guard alone would cheerfully claim success against a bar
# that is not there. Check for the process first. The exit-code branch still earns
# its place — the client does return 1 when it cannot reach a bar that IS running.
if ! pgrep -x sketchybar >/dev/null 2>&1; then
    echo "SketchyBar is not running — it starts from aerospace's after-startup-command"
    exit 1
fi

if sketchybar --reload; then
    echo "SketchyBar reloaded"
else
    echo "SketchyBar reload failed"
    exit 1
fi
