#!/usr/bin/env bash
# Power menu — bound to SUPER+M.
#
# hyprshutdown is not a menu: it's a graceful-exit tool that asks apps to close
# properly before quitting Hyprland, with the action chosen at invocation via
# --post-cmd. This wraps it in a rofi chooser so one keybind covers everything.
#
# Using hyprshutdown rather than `hyprctl dispatch exit` matters: exit kills
# clients outright, so unsaved work is lost and apps that write state on quit
# don't get the chance.

set -euo pipefail

lock="󰌾   Lock"
logout="󰗽   Logout"
suspend="󰤄   Suspend"
reboot="󰜉   Reboot"
poweroff="⏻   Shutdown"

chosen=$(printf '%s\n' "$lock" "$logout" "$suspend" "$reboot" "$poweroff" |
	rofi -dmenu -i \
		-p "Power" \
		-theme powermenu \
		-no-custom \
		-selected-row 0)

case "$chosen" in
"$lock")
	# Via logind so hypridle and anything else watching session state agree.
	loginctl lock-session
	;;
"$logout")
	hyprshutdown -t 'Logging out…'
	;;
"$suspend")
	systemctl suspend
	;;
"$reboot")
	hyprshutdown -t 'Restarting…' --post-cmd 'systemctl reboot'
	;;
"$poweroff")
	hyprshutdown -t 'Shutting down…' --post-cmd 'systemctl poweroff'
	;;
*)
	# Escape pressed, or rofi dismissed. Do nothing.
	exit 0
	;;
esac
