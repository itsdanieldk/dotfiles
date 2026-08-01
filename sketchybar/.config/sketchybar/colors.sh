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
# Below about 60% the Catppuccin text starts losing contrast on a busy wallpaper.
# There is no blur to fall back on: blur_radius is a BAR-level property and there
# is no background.blur_radius, so enabling it would frost the entire bar
# rectangle including the gaps between islands — a blurred band across the whole
# screen top, which is exactly the effect the islands exist to avoid.
export ISLAND=0xb3232634
# Kept fully opaque on purpose: as the fill gets more transparent the border is
# what keeps the pill's edge crisp and its shape readable against the desktop.
export ISLAND_BORDER=0xff414559
