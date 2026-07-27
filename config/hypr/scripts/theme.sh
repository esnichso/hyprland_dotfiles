#!/usr/bin/env bash
# Apply the parts of a theme that don't live in a config file.
#
# Some GTK applications read ~/.config/gtk-3.0/settings.ini; others read the
# same values from gsettings (dconf), and under a portal-based session the
# gsettings copy is usually the one that wins. There is no single place to set
# both, so this script writes the gsettings half.
#
# Values come from ~/.config/hypr/theme.env, which install/set-theme.py
# generates. They used to be hardcoded here, which meant switching to a
# different theme rewrote thirteen files and then told gsettings to carry on
# using the old one — the switch looked like it had done nothing.
#
# Run once after install, and again after any theme change (the theme picker
# on SUPER+ALT+T does it for you). Safe to re-run.

set -euo pipefail

ENV_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/theme.env"

if [[ ! -r $ENV_FILE ]]; then
	echo "No $ENV_FILE — run install/set-theme.py <theme> first." >&2
	exit 1
fi

# shellcheck source=/dev/null
. "$ENV_FILE"

CURSOR_THEME="Bibata-Modern-Classic"
CURSOR_SIZE=24
FONT="Inter 11"
MONO_FONT="JetBrainsMono Nerd Font 11"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

say "Applying $THEME_LABEL via gsettings"
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME_NAME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE"
gsettings set org.gnome.desktop.interface font-name "$FONT"
gsettings set org.gnome.desktop.interface monospace-font-name "$MONO_FONT"

# Tells libadwaita apps which variant to use. Without this they render light
# regardless of the colours in gtk-4.0/gtk.css.
if [[ $THEME_DARK == 1 ]]; then
	gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
else
	gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
fi

# Warn rather than fail: a missing GTK theme is the most common reason apps
# look "almost right". GTK falls back to Adwaita silently, honours the dark
# preference, and hands you a dark grey desktop that isn't your palette.
if [[ -n $GTK_THEME_NAME ]] &&
	! [[ -d "/usr/share/themes/$GTK_THEME_NAME" || -d "$HOME/.themes/$GTK_THEME_NAME" ]]; then
	printf '\033[1;33m==>\033[0m GTK theme "%s" is not installed.\n' "$GTK_THEME_NAME"
	printf '    GTK is falling back to Adwaita. Install it with:\n'
	printf '      paru -S catppuccin-gtk-theme-%s\n' "$THEME_NAME"
	printf '    The generated gtk-3.0/gtk.css still recolours Adwaita, so this\n'
	printf '    is a downgrade rather than a breakage.\n'
fi

if [[ -n $ICON_THEME_NAME ]] &&
	! [[ -d "/usr/share/icons/$ICON_THEME_NAME" || -d "$HOME/.icons/$ICON_THEME_NAME" ]]; then
	printf '\033[1;33m==>\033[0m Icon theme "%s" is not installed (papirus-icon-theme).\n' "$ICON_THEME_NAME"
fi

say "Setting the X11 cursor for XWayland apps"
# XWayland reads the cursor from this file rather than from gsettings.
mkdir -p "$HOME/.icons/default"
cat >"$HOME/.icons/default/index.theme" <<EOF
[Icon Theme]
Inherits=$CURSOR_THEME
EOF

say "Done"
cat <<'EOF'

   Already-running apps keep their old theme — restart them, or log out and
   back in, to see the change. GTK reads its theme name once, at startup.

   Qt apps read ~/.config/qt6ct; KDE apps (Dolphin, Ark, Okular) read
   ~/.config/kdeglobals. Both are written by install/set-theme.py.
EOF
