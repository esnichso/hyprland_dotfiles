#!/usr/bin/env bash
# Installs the Hyprland stack on a fresh CachyOS system.
# Idempotent: safe to re-run after editing the package lists.
#
#   ./bootstrap.sh              # core packages + services
#   ./bootstrap.sh --optional   # also the hardware-dependent extras
#   ./bootstrap.sh --dry-run    # print what would happen, change nothing

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
WITH_OPTIONAL=0

for arg in "$@"; do
	case "$arg" in
	--dry-run) DRY_RUN=1 ;;
	--optional) WITH_OPTIONAL=1 ;;
	*)
		echo "unknown flag: $arg" >&2
		exit 1
		;;
	esac
done

say() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
run() {
	if ((DRY_RUN)); then
		printf '   [dry-run] %s\n' "$*"
	else
		"$@"
	fi
}

# Strip comments and blank lines from a package list.
pkglist() { grep -vE '^\s*(#|$)' "$1" | tr -d '\r'; }

if [[ ! -f /etc/arch-release ]]; then
	echo "This script expects an Arch-based system (CachyOS). Aborting." >&2
	exit 1
fi

if [[ $EUID -eq 0 ]]; then
	echo "Run this as your normal user, not root. It calls sudo where needed." >&2
	exit 1
fi

say "Checking which repositories CachyOS selected"
# Arrow Lake supports x86-64-v3 but not v4 (no AVX-512). v4 repos would be wrong.
#
# Match only *active* section headers: pacman.conf ships commented-out v4 entries
# for reference, and a looser pattern flags those as if they were enabled.
if grep -qE '^[[:space:]]*\[cachyos[a-z0-9-]*-v4\]' /etc/pacman.conf 2>/dev/null; then
	echo "   WARNING: v4 repositories are enabled, but this CPU has no AVX-512."
	echo "   Run 'sudo cachyos-rate-mirrors' and pick v3 before continuing."
fi
echo "   Active CachyOS repositories:"
grep -oE '^[[:space:]]*\[cachyos[a-z0-9-]*\]' /etc/pacman.conf 2>/dev/null | tr -d ' \t' | sed 's/^/     /' || true

say "Updating the system first (never install onto a partial upgrade)"
run sudo pacman -Syu

say "Installing core packages"
mapfile -t core < <(pkglist "$HERE/packages-core.txt")
run sudo pacman -S --needed "${core[@]}"

if ((WITH_OPTIONAL)); then
	say "Installing optional packages"
	mapfile -t optional < <(pkglist "$HERE/packages-optional.txt")
	run sudo pacman -S --needed "${optional[@]}"
fi

say "Installing AUR packages"
# paru lives in CachyOS's own repository, so pacman can install it. Without an
# AUR helper the GTK theme, cursor theme and murrine engine are all missing,
# which leaves GTK apps looking untidy next to everything else.
if ! command -v paru >/dev/null 2>&1; then
	echo "   paru not installed — installing it from the CachyOS repo first."
	run sudo pacman -S --needed paru
fi

if ((DRY_RUN)) || command -v paru >/dev/null 2>&1; then
	mapfile -t aur < <(pkglist "$HERE/packages-aur.txt")
	run paru -S --needed "${aur[@]}"
else
	echo "   Still no paru — skipping AUR packages."
	echo "   Install one by hand, then re-run this script to pick them up:"
	echo "     sudo pacman -S paru      # or: yay, from the AUR"
fi

say "Enabling system services"
# NetworkManager and bluetooth are usually on already; --now is harmless if so.
for svc in sddm NetworkManager bluetooth power-profiles-daemon; do
	if systemctl list-unit-files "$svc.service" >/dev/null 2>&1; then
		run sudo systemctl enable "$svc.service"
	fi
done
# Started separately: enabling sddm mid-session would not switch you over anyway.
run sudo systemctl start NetworkManager.service bluetooth.service power-profiles-daemon.service

say "Creating XDG user directories"
run xdg-user-dirs-update

say "Creating directories the config expects"
# Screenshots land here (see the Print keybinds); hyprpaper only starts if
# there is at least one image in wallpapers/.
run mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Pictures/wallpapers"

say "Done"
cat <<'EOF'

   Next steps:
     1. ./link.sh              symlink the config into ~/.config
     2. ~/.config/hypr/scripts/theme.sh
                               apply GTK theme settings that live in gsettings
     3. reboot
     4. at the SDDM login screen pick the "Hyprland (uwsm-managed)" session

   If Hyprland fails to start, switch to a TTY with Ctrl+Alt+F2 and check:
     journalctl --user -b -u hyprland-session.target
     cat ~/.local/share/hyprland/hyprland.log
EOF
