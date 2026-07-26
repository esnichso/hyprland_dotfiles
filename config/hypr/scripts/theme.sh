#!/usr/bin/env bash
# Apply the theme settings that live outside config files.
#
# Some GTK applications read ~/.config/gtk-3.0/settings.ini; others read the
# same values from gsettings (dconf). There is no way to set both from one
# place, so this script writes the gsettings half.
#
# Run once after install. Safe to re-run — it only sets values.

set -euo pipefail

GTK_THEME="catppuccin-mocha-mauve-standard+default"
ICON_THEME="Papirus-Dark"
CURSOR_THEME="Bibata-Modern-Classic"
CURSOR_SIZE=24
FONT="Rubik 11"
MONO_FONT="JetBrainsMono Nerd Font 11"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

say "Setting GTK appearance via gsettings"
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME"
gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE"
gsettings set org.gnome.desktop.interface font-name "$FONT"
gsettings set org.gnome.desktop.interface monospace-font-name "$MONO_FONT"

# Tells libadwaita apps to use their dark variant. Without this they render
# light regardless of the colours in gtk-4.0/gtk.css.
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

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
   back in, to see the change.

   If GTK apps still look wrong, check the theme is actually installed:
     ls ~/.themes /usr/share/themes | grep -i catppuccin
     ls /usr/share/icons | grep -iE 'papirus|bibata'

   Qt apps (Dolphin, etc.) read ~/.config/qt6ct instead — no script needed,
   but QT_QPA_PLATFORMTHEME=qt6ct must be set, which uwsm/env does.
EOF
