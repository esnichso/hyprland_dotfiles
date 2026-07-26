#!/usr/bin/env bash
# Pick a colour theme with rofi, apply it, and reload everything that can be
# reloaded without logging out. Bound to SUPER+ALT+T.
#
# Finds the repo by resolving its own real path: this script lives at
# <repo>/config/hypr/scripts/, and ~/.config/hypr is a symlink to
# <repo>/config/hypr — so realpath gets us back to the repo wherever it was
# cloned, without hardcoding a path that differs between machines.

set -euo pipefail

SELF="$(realpath "${BASH_SOURCE[0]}")"
REPO="$(cd "$(dirname "$SELF")/../../.." && pwd)"
SET_THEME="$REPO/install/set-theme.py"

[[ -x $SET_THEME ]] || {
	notify-send "Theme" "Not found: $SET_THEME"
	exit 1
}

"$SET_THEME" --pick || exit 0

# Reload each component in place. Nothing here needs a logout.
hyprctl reload >/dev/null 2>&1 || true

pkill -x waybar 2>/dev/null || true
setsid waybar >/dev/null 2>&1 &

swaync-client -rs >/dev/null 2>&1 || true   # reload swaync css

# kitty re-reads its config on SIGUSR1 — every running instance picks up the
# new colours without being restarted.
pkill -USR1 -x kitty 2>/dev/null || true

"$(dirname "$SELF")/theme.sh" >/dev/null 2>&1 || true

notify-send -t 3000 "Theme" "Applied $(cat "${XDG_STATE_HOME:-$HOME/.local/state}/hypr/theme" 2>/dev/null || echo '?')"
