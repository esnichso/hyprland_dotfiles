#!/usr/bin/env bash
# Wallpaper control.
#
#   wallpaper.sh pick       rofi picker with thumbnails   (SUPER+W)
#   wallpaper.sh random     jump to a random one          (SUPER+SHIFT+W)
#   wallpaper.sh set PATH   set a specific image
#   wallpaper.sh restore    re-apply the saved one        (run at login)
#   wallpaper.sh current    print the current path
#
# The choice persists across reboots. It is stored in
# $XDG_STATE_HOME/hypr/wallpaper rather than written back into
# hyprpaper.conf, because that file is a symlink into the git repo — editing
# it from a script would leave the repo permanently dirty.

set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypr"
STATE_FILE="$STATE_DIR/wallpaper"

notify() { command -v notify-send >/dev/null 2>&1 && notify-send -t 2500 "$@" || true; }

die() {
	notify "Wallpaper" "$1"
	echo "$1" >&2
	exit 1
}

# All images in the directory, newline-separated, sorted.
list_images() {
	find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \
		\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
		-o -iname '*.webp' -o -iname '*.jxl' -o -iname '*.bmp' \) |
		sort
}

apply() {
	local img="$1"
	[[ -f $img ]] || die "Not a file: $img"

	# Empty monitor field = every display, including ones plugged in later.
	if ! hyprctl hyprpaper wallpaper ",$img,cover" >/dev/null 2>&1; then
		die "hyprpaper is not running (start it, then try again)"
	fi

	mkdir -p "$STATE_DIR"
	printf '%s\n' "$img" >"$STATE_FILE"
}

require_images() {
	local n
	n=$(list_images | wc -l)
	((n > 0)) || die "No images in $WALLPAPER_DIR"
}

cmd_pick() {
	require_images

	# rofi's dmenu icon protocol: "label\0icon\x1f/path/to/image" gives each
	# row a thumbnail of the wallpaper itself, so you choose by looking rather
	# than by remembering filenames.
	local chosen
	chosen=$(
		while IFS= read -r img; do
			printf '%s\0icon\x1f%s\n' "$(basename "${img%.*}")" "$img"
		done < <(list_images) |
			rofi -dmenu -i \
				-p "Wallpaper" \
				-show-icons \
				-theme wallpaper \
				-no-custom
	) || exit 0 # Escape pressed

	[[ -n $chosen ]] || exit 0

	# Map the label back to a full path — basenames are unique per directory,
	# but extensions differ, so match on the stem.
	local img
	img=$(list_images | while IFS= read -r f; do
		[[ "$(basename "${f%.*}")" == "$chosen" ]] && printf '%s\n' "$f" && break
	done)

	[[ -n $img ]] || die "Could not resolve: $chosen"
	apply "$img"
	notify "Wallpaper" "$(basename "$img")"
}

cmd_random() {
	require_images

	local current="" images=() img
	[[ -f $STATE_FILE ]] && current=$(<"$STATE_FILE")

	mapfile -t images < <(list_images)

	# Don't pick the one already showing, unless it's the only image.
	if ((${#images[@]} > 1)) && [[ -n $current ]]; then
		local filtered=()
		for img in "${images[@]}"; do
			[[ $img != "$current" ]] && filtered+=("$img")
		done
		images=("${filtered[@]}")
	fi

	img="${images[RANDOM % ${#images[@]}]}"
	apply "$img"
	notify "Wallpaper" "$(basename "$img")"
}

cmd_restore() {
	# Used at login. Silent when there's nothing saved yet — a fresh install
	# with an empty wallpapers folder is a normal state, not an error.
	[[ -f $STATE_FILE ]] || exit 0

	local img
	img=$(<"$STATE_FILE")

	if [[ ! -f $img ]]; then
		# The saved image was deleted or moved. Fall back rather than fail.
		list_images | head -1 | while IFS= read -r f; do apply "$f"; done
		exit 0
	fi

	# hyprpaper may not have finished starting yet.
	for _ in {1..20}; do
		if hyprctl hyprpaper wallpaper ",$img,cover" >/dev/null 2>&1; then
			exit 0
		fi
		sleep 0.25
	done
	exit 0
}

case "${1:-pick}" in
pick) cmd_pick ;;
random) cmd_random ;;
restore) cmd_restore ;;
set) apply "${2:?usage: wallpaper.sh set PATH}" ;;
current) [[ -f $STATE_FILE ]] && cat "$STATE_FILE" || echo "(none)" ;;
*)
	echo "usage: wallpaper.sh {pick|random|restore|set PATH|current}" >&2
	exit 1
	;;
esac
