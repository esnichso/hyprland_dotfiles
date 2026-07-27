#!/usr/bin/env bash
# Check that the parts of the desktop you can't see are actually running.
#
# install/check.sh validates the *files* on the dev host. This one runs inside
# the live session and asks whether the things those files configure — audio,
# screensharing, the clipboard, the portals, the fonts — are working.
#
#   ./install/doctor.sh
#
# Nothing here changes anything. Every line is a question and an answer.
# Read it top to bottom; the summary at the end counts the failures.

# Deliberately NOT pipefail.
#
# Almost every check here is `something | grep -q`. grep -q exits the moment
# it matches, the writer gets SIGPIPE and exits 141, and under pipefail the
# pipeline reports 141 — so a *successful* match reads as a failure. It only
# bites when the writer produces more than a pipe buffer, which is why
# `fc-list | grep -q` reported every font missing while `busctl | grep -q`
# looked fine.
set -u

GREEN=$'\033[32m' YELLOW=$'\033[33m' RED=$'\033[31m'
BOLD=$'\033[1m' DIM=$'\033[2m' RESET=$'\033[0m'

fails=0
warns=0

section() { printf '\n%s%s%s\n' "$BOLD" "$1" "$RESET"; }
ok() { printf '  %sOK%s    %s\n' "$GREEN" "$RESET" "$1"; }
warn() {
	printf '  %sWARN%s  %s\n' "$YELLOW" "$RESET" "$1"
	[[ ${2:-} ]] && printf '        %s%s%s\n' "$DIM" "$2" "$RESET"
	warns=$((warns + 1))
}
bad() {
	printf '  %sFAIL%s  %s\n' "$RED" "$RESET" "$1"
	[[ ${2:-} ]] && printf '        %s%s%s\n' "$DIM" "$2" "$RESET"
	fails=$((fails + 1))
}
note() { printf '        %s%s%s\n' "$DIM" "$1" "$RESET"; }

have() { command -v "$1" >/dev/null 2>&1; }
running() { pgrep -x "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------- session

section "Session"

if [[ -z ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
	bad "Not inside a Hyprland session" \
		"Run this from a terminal in the desktop, not a TTY or SSH."
else
	ok "Hyprland $(hyprctl version -j 2>/dev/null | grep -oP '"tag":\s*"\K[^"]+' || echo '(version unknown)')"
fi

for var in XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_RUNTIME_DIR; do
	if [[ -n ${!var:-} ]]; then
		ok "$var=${!var}"
	else
		bad "$var is unset" "Portals and systemd user services depend on it."
	fi
done

if systemctl --user is-active --quiet wayland-wm@hyprland.service 2>/dev/null ||
	systemctl --user is-active --quiet 'wayland-wm@*.service' 2>/dev/null; then
	ok "Started through uwsm"
else
	warn "Not started through uwsm (or the unit is named differently)" \
		"Check with: systemctl --user list-units 'wayland-wm@*'"
	note "Without uwsm, ~/.config/uwsm/env is never read — cursor theme,"
	note "QT_QPA_PLATFORMTHEME and LIBVA_DRIVER_NAME would all be unset."
fi

# ------------------------------------------------------------------ audio

section "Audio"

if running pipewire; then
	ok "pipewire running"
else
	bad "pipewire is not running" "systemctl --user status pipewire"
fi

if running wireplumber; then
	ok "wireplumber running (session manager)"
else
	bad "wireplumber is not running" \
		"Without it PipeWire has no policy and no device shows up."
fi

if running pipewire-pulse; then
	ok "pipewire-pulse running (PulseAudio compatibility)"
else
	warn "pipewire-pulse is not running" \
		"pavucontrol and most apps talk Pulse, not native PipeWire."
fi

if have wpctl; then
	sink=$(wpctl status 2>/dev/null | sed -n '/Sinks:/,/^ *$/p' | grep -m1 '\*' || true)
	src=$(wpctl status 2>/dev/null | sed -n '/Sources:/,/^ *$/p' | grep -m1 '\*' || true)
	[[ -n $sink ]] && ok "Default output:$(echo "$sink" | sed 's/[│├─*]//g')" ||
		bad "No default audio output" "wpctl status"
	[[ -n $src ]] && ok "Default input:$(echo "$src" | sed 's/[│├─*]//g')" ||
		warn "No default audio input" "Expected in a VM without a microphone."
	vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo "?")
	note "Volume: $vol   (mute toggle: wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle)"
else
	bad "wpctl missing" "Install wireplumber."
fi

running swayosd-server && ok "swayosd-server running (volume/brightness popups)" ||
	warn "swayosd-server is not running" "Volume keys will work without an on-screen display."

# ---------------------------------------------------------------- portals

section "Portals (screenshare, file pickers, global shortcuts)"

# Portals are D-Bus activated. They are not running until something asks for
# one, so "is the process alive" answers the wrong question — a portal that
# has never been needed is idle, not broken. Asking on D-Bus is both the real
# test and what an application would do, so that comes first and is what the
# verdict is based on.
if have busctl; then
	iface=$(busctl --user introspect org.freedesktop.portal.Desktop \
		/org/freedesktop/portal/desktop 2>/dev/null)
	if [[ -z $iface ]]; then
		bad "xdg-desktop-portal does not answer on D-Bus" \
			"Screensharing and GTK file dialogs will silently do nothing."
	else
		ok "xdg-desktop-portal answers on D-Bus"
		if grep -q 'org.freedesktop.portal.ScreenCast' <<<"$iface"; then
			ok "ScreenCast interface exported (screensharing)"
			note "Real test: share a window in a browser — the picker should appear."
		else
			bad "ScreenCast interface is not exported" \
				"The portal is up but has no screencast backend."
		fi
		if grep -q 'org.freedesktop.portal.FileChooser' <<<"$iface"; then
			ok "FileChooser interface exported (open/save dialogs)"
		else
			bad "FileChooser interface is not exported" \
				"xdg-desktop-portal-gtk provides this; XDPH has no file picker."
		fi
	fi
else
	warn "busctl not available" "Cannot test the portals properly."
fi

# Informational only, for the same reason: idle is a normal state here.
for p in xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk; do
	running "$p" && note "$p is running" || note "$p is idle (starts on demand)"
done

if [[ -r ~/.config/xdg-desktop-portal/hyprland-portals.conf ||
	-r /usr/share/xdg-desktop-portal/hyprland-portals.conf ]]; then
	ok "Portal backend preference file present"
else
	warn "No hyprland-portals.conf" \
		"Usually fine; add one if the wrong backend answers a request."
fi

# -------------------------------------------------------------- clipboard

section "Clipboard"

if running cliphist; then
	ok "cliphist watchers running"
else
	# The watcher is `wl-paste`, cliphist only runs per event.
	if pgrep -f 'wl-paste .*cliphist' >/dev/null; then
		ok "cliphist watchers running (via wl-paste)"
	else
		bad "Nothing is recording the clipboard" \
			"Expected two wl-paste --watch processes from autostart.lua."
	fi
fi

running wl-clip-persist && ok "wl-clip-persist running (clipboard survives app exit)" ||
	warn "wl-clip-persist is not running" \
		"Copying then closing the source app will lose the clipboard."

if have cliphist; then
	count=$(cliphist list 2>/dev/null | wc -l)
	note "History holds $count entries   (SUPER+SHIFT+V to browse)"
fi

# ---------------------------------------------------------- notifications

section "Notifications and bar"

running swaync && ok "swaync running" || bad "swaync is not running" \
	"Some apps block waiting for a notification daemon."
running waybar && ok "waybar running" || bad "waybar is not running" "waybar -l debug"
running hypridle && ok "hypridle running (idle, dim, lock)" ||
	warn "hypridle is not running" "The screen will never lock or sleep by itself."
running hyprpaper && ok "hyprpaper running" || warn "hyprpaper is not running" \
	"No wallpaper. Start it and re-run scripts/wallpaper.sh restore."

if pgrep -f hyprpolkitagent >/dev/null; then
	ok "Polkit agent running"
else
	bad "No polkit agent" "Nothing can prompt you for a password."
fi

# --------------------------------------------------------------- theming

section "Theming"

env_file="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/theme.env"
if [[ -r $env_file ]]; then
	# shellcheck source=/dev/null
	. "$env_file"
	ok "Theme: $THEME_LABEL"

	if [[ -d /usr/share/themes/$GTK_THEME_NAME || -d $HOME/.themes/$GTK_THEME_NAME ]]; then
		ok "GTK theme installed: $GTK_THEME_NAME"
	else
		bad "GTK theme '$GTK_THEME_NAME' is not installed" \
			"GTK falls back to Adwaita silently. This is the usual reason apps look nearly right."
	fi

	if [[ -d /usr/share/icons/$ICON_THEME_NAME || -d $HOME/.icons/$ICON_THEME_NAME ]]; then
		ok "Icon theme installed: $ICON_THEME_NAME"
	else
		bad "Icon theme '$ICON_THEME_NAME' is not installed" "pacman -S papirus-icon-theme"
	fi

	if have gsettings; then
		live=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
		if [[ $live == "$GTK_THEME_NAME" ]]; then
			ok "gsettings agrees with the theme"
		else
			bad "gsettings says '$live', theme says '$GTK_THEME_NAME'" \
				"Run ~/.config/hypr/scripts/theme.sh"
		fi
	fi
else
	bad "No $env_file" "Run install/set-theme.py <theme>"
fi

[[ -e ${XDG_CONFIG_HOME:-$HOME/.config}/kdeglobals ]] &&
	ok "kdeglobals present (Dolphin, Ark, Okular read this)" ||
	bad "No kdeglobals" "KDE apps will use Breeze Light. Run install/link.sh."

[[ ${QT_QPA_PLATFORMTHEME:-} == qt6ct ]] && ok "QT_QPA_PLATFORMTHEME=qt6ct" ||
	bad "QT_QPA_PLATFORMTHEME is '${QT_QPA_PLATFORMTHEME:-unset}'" \
		"Qt apps will ignore ~/.config/qt6ct."

if pacman -Q qt6ct-kde >/dev/null 2>&1; then
	ok "qt6ct-kde installed (the variant that reaches KDE apps)"
elif pacman -Q qt6ct >/dev/null 2>&1; then
	warn "plain qt6ct installed" \
		"Themes Qt apps but not KDE ones. If Dolphin still looks wrong: paru -S qt6ct-kde"
fi

# ----------------------------------------------------------------- fonts

section "Fonts"

# Listed once and matched in memory, rather than re-running fc-list per font.
installed_fonts=$(fc-list 2>/dev/null)
if [[ -z $installed_fonts ]]; then
	bad "fc-list returned nothing" "fontconfig is broken or not installed."
else
	for font in "Inter" "JetBrainsMono Nerd Font" "Noto Color Emoji" "Font Awesome"; do
		if grep -qi -- "$font" <<<"$installed_fonts"; then
			ok "$font"
		else
			bad "$font is missing" "Glyphs will fall back to boxes in the bar or menus."
		fi
	done
fi

# -------------------------------------------------------------- hardware

section "Hardware"

if [[ -d /sys/class/power_supply/BAT0 ]]; then
	cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
	ok "Battery BAT0 present (${cap}%) — the Waybar battery module will show"
else
	warn "No BAT0" "Expected in a VM. On the ThinkPad this means the module stays hidden."
fi

if have vainfo; then
	if vainfo 2>/dev/null | grep -q 'VAProfile'; then
		ok "VA-API hardware video acceleration available ($(vainfo 2>/dev/null | grep -m1 'Driver version' | cut -d: -f2- | xargs))"
	else
		warn "vainfo reports no profiles" "No hardware video decode. Expected in a VM."
	fi
else
	warn "vainfo not installed" "pacman -S libva-utils to check video acceleration."
fi

# ------------------------------------------------------------- optionals

section "Optional tools"

for pair in "rofimoji:emoji picker (SUPER+ALT+E)" \
	"rofi-calc:calculator (SUPER+ALT+C)" \
	"fzf:fish history and file search" \
	"zoxide:smart cd" \
	"eza:ls replacement" \
	"bat:pager and syntax highlighting"; do
	pkg=${pair%%:*}
	what=${pair#*:}
	if pacman -Q "$pkg" >/dev/null 2>&1; then
		ok "$pkg — $what"
	else
		warn "$pkg not installed — $what unavailable" "pacman -S $pkg"
	fi
done

# --------------------------------------------------------------- summary

printf '\n'
if ((fails == 0 && warns == 0)); then
	printf '%sEverything checked out.%s\n' "$GREEN" "$RESET"
elif ((fails == 0)); then
	printf '%s%d warning(s), nothing broken.%s\n' "$YELLOW" "$warns" "$RESET"
else
	printf '%s%d failure(s)%s and %d warning(s).\n' "$RED" "$fails" "$RESET" "$warns"
fi
exit $((fails > 0 ? 1 : 0))
