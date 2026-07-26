#!/usr/bin/env bash
# Symlinks every directory in ../config into ~/.config.
#
# Anything already at the destination is moved to ~/.config-backup-<timestamp>/
# rather than deleted, so this is always reversible.
#
#   ./link.sh            link everything
#   ./link.sh --dry-run  show what would happen
#   ./link.sh --unlink   remove our symlinks (does not restore backups)

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$(cd "$HERE/.." && pwd)/config"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
UNLINK=0
for arg in "$@"; do
	case "$arg" in
	--dry-run) DRY_RUN=1 ;;
	--unlink) UNLINK=1 ;;
	*)
		echo "unknown flag: $arg" >&2
		exit 1
		;;
	esac
done

run() {
	if ((DRY_RUN)); then
		printf '   [dry-run] %s\n' "$*"
	else
		"$@"
	fi
}

if [[ ! -d $SRC ]]; then
	echo "No config directory at $SRC — nothing to link." >&2
	exit 1
fi

if ((UNLINK)); then
	for path in "$SRC"/*; do
		name="$(basename "$path")"
		target="$DEST/$name"
		if [[ -L $target && "$(readlink -f "$target")" == "$(readlink -f "$path")" ]]; then
			echo "   unlinking $target"
			run rm "$target"
		fi
	done
	echo "Done. Backups in ~/.config-backup-* were left untouched."
	exit 0
fi

run mkdir -p "$DEST"

for path in "$SRC"/*; do
	[[ -e $path ]] || continue
	name="$(basename "$path")"
	target="$DEST/$name"

	# Already pointing at us: nothing to do.
	if [[ -L $target && "$(readlink -f "$target")" == "$(readlink -f "$path")" ]]; then
		echo "   ok        $name"
		continue
	fi

	if [[ -e $target || -L $target ]]; then
		echo "   backup    $name -> $BACKUP/$name"
		run mkdir -p "$BACKUP"
		run mv "$target" "$BACKUP/$name"
	fi

	echo "   link      $name"
	run ln -s "$path" "$target"
done

echo
echo "Linked into $DEST"
[[ -d $BACKUP ]] && echo "Previous files preserved in $BACKUP"
echo "Reload a running session with: hyprctl reload"
