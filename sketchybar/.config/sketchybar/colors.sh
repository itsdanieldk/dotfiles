#!/usr/bin/env bash
# Catppuccin Frappé, in sketchybar's 0xAARRGGBB form (leading ff = opaque).

export BASE=0xff303446
export MANTLE=0xff292c3c
export CRUST=0xff232634

export SURFACE0=0xff414559
export SURFACE1=0xff51576d
export SURFACE2=0xff626880

export TEXT=0xffc6d0f5
export SUBTEXT0=0xffa5adce
export OVERLAY0=0xff737994

export BLUE=0xff8caaee
export MAUVE=0xffca9ee6
export GREEN=0xffa6d189
export YELLOW=0xffe5c890
export PEACH=0xffef9f76
export RED=0xffe78284
export LAVENDER=0xffbabbf1

export TRANSPARENT=0x00000000

# Island backgrounds. The bar itself is fully transparent (color=0x0 in
# sketchybarrc) — these pills are the only thing drawn, so their alpha byte is
# the single knob for how see-through the whole bar looks.
#   0xe6 90%   0xcc 80%   0xb3 70% (current)   0x99 60%   0x80 50%
# Below about 60% the Catppuccin text starts losing contrast on a busy wallpaper —
# though the pills are frosted now (see ISLAND_STYLE in sketchybarrc), and blur
# buys back some of that headroom by killing the detail behind the text.
#
# BLUR IS PER-ITEM, NOT BAR-ONLY. An older version of this note said blur was a
# bar property with "no background.blur_radius", and concluded that using it
# would frost the whole bar rectangle including the gaps — a band across the
# screen top, which is exactly what the islands exist to avoid. Half right:
#   - true:  there is no background.blur_radius, so blur is not something a pill
#            inherits from its background the way it inherits colour.
#   - false: it is not bar-only. blur_radius is also an ITEM property
#            (PROPERTY_BLUR_RADIUS, src/bar_item.c), applied to that item's own
#            window — and a bracket IS an item whose window is the island rect.
# So the pills can be frosted individually while the bar stays transparent, which
# is what this config does. A full-width frosted band was tried and rejected.
export ISLAND=0xb3232634
# Kept fully opaque on purpose: as the fill gets more transparent the border is
# what keeps the pill's edge crisp and its shape readable against the desktop.
# It matters more with blur, not less — a frosted fill has softer edges than a
# flat one, so the border is what stops the pill dissolving into the wallpaper.
export ISLAND_BORDER=0xff414559
