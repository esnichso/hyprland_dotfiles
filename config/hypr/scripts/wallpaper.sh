#!/usr/bin/env bash
# Jump to a random wallpaper immediately — bound to SUPER+W.
#
# hyprpaper rotates on its own every 15 minutes (see hyprpaper.conf). This is
# for when you want a different one right now.

set -euo pipefail

DIR="${1:-$HOME/Pictures/wallpapers}"

if [[ ! -d $DIR ]]; then
	notify-send "Wallpaper" "No such directory: $DIR"
	exit 1
fi

# -print0/-z so filenames with spaces survive.
mapfile -d '' -t images < <(
	find "$DIR" -maxdepth 1 -type f \
		\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.jxl' \) \
		-print0
)

if ((${#images[@]} == 0)); then
	notify-send "Wallpaper" "No images in $DIR"
	exit 1
fi

pick="${images[RANDOM % ${#images[@]}]}"

# Empty monitor field = apply to every display.
hyprctl hyprpaper wallpaper ",$pick,cover" >/dev/null

notify-send -t 2000 "Wallpaper" "$(basename "$pick")"
