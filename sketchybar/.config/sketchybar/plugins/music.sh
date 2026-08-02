#!/usr/bin/env bash
# Now-playing for ANY player, via macOS's system-wide Now Playing state — the
# same source Control Center shows. Left-click toggles play/pause, right-click
# opens the transport popup.
#
# WHY NOT AppleScript. This used to be Apple-Music-only (`pgrep -x Music`), and
# per-app AppleScript branching was the obvious way to widen it. It cannot work
# here: IINA — the actual music player on this machine — ships no .sdef, leaves
# NSAppleScriptEnabled unset, and its iina-cli is open-only with no way to query
# state. It does link MediaPlayer.framework, so it publishes to Now Playing and
# is visible to MediaRemote and to nothing else.
#
# PRIVATE API, KNOWINGLY. media-control reads MediaRemote, which Apple gated
# behind an entitlement in macOS 15.4 — that is what broke nowplaying-cli.
# Measured on 26.6: dlopen succeeds and MRMediaRemoteGetNowPlayingInfo's callback
# fires from an ad-hoc-signed process, but hands back a NULL dictionary while
# IINA was demonstrably publishing. media-control gets real data from the same
# machine because bin/media-control is `#!/usr/bin/perl` and execs its adapter
# under that interpreter, inheriting APPLE's signature on /usr/bin/perl.
#
# So this depends on a hole Apple has closed once already. If it closes again the
# `null` branch below hides the pill cleanly — no error, no stale label. To
# confirm the tool itself rather than guess: `media-control test` exits non-zero
# when it cannot operate on the running macOS.
#
# --no-artwork is NOT an optimisation of runtime — with and without measured 23
# and 24ms CPU, inside noise. It is about payload: 414 bytes versus 49,579, since
# the default embeds the cover as base64 JPEG on every single poll. Nothing here
# renders artwork.

source "$HOME/.config/sketchybar/colors.sh"
source "$HOME/.config/sketchybar/lib.sh"

require media-control

if [ "$SENDER" = "mouse.clicked" ]; then
    case "$BUTTON" in
        right)
            sketchybar --set "$NAME" popup.drawing=toggle
            exit 0
            ;;
        *)
            media-control toggle-play-pause >/dev/null 2>&1
            sleep 0.3
            ;;
    esac
fi

# `null` is the documented response when nothing holds a Now Playing session —
# not an error, and the normal state most of the day. Empty output means the
# adapter failed outright; both hide.
info="$(media-control get --no-artwork 2>/dev/null)"
[ -n "$info" ] && [ "$info" != "null" ] || hide

IFS=$'\t' read -r playing track artist <<EOF
$(printf '%s' "$info" | jq -r '[.playing, (.title // ""), (.artist // "")] | @tsv' 2>/dev/null)
EOF

# A session can exist with no title (a stream still resolving, an app that
# registered before it had metadata). Nothing worth drawing, so hide rather than
# leave the previous track's label sitting there.
[ -n "$track" ] || hide

# `playing` is a mandatory key in the adapter's payload — it is never null — so
# this is a real two-state test, not a fallthrough.
if [ "$playing" = "true" ]; then
    icon="󰎇"; color="$GREEN"
else
    icon="󰏤"; color="$OVERLAY0"
fi

if [ -n "$artist" ]; then
    label="$track — $artist"
else
    label="$track"
fi

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$color" \
    label.drawing=on label.color="$TEXT" label="$label"
