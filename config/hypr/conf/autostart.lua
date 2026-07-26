-- What starts with the session.
--
-- Reference: docs/hyprland/Configuring_Basics_Autostart.md
--            docs/hyprland/Useful_Utilities_Systemd-start.md
--
-- These run once, on `hyprland.start`. They do NOT re-run when the config
-- reloads, so editing this file and saving won't spawn duplicate bars.
--
-- Alternative worth knowing: waybar, hyprpaper, hypridle and swaync all ship
-- systemd user units. Under uwsm you can hand them to systemd instead, which
-- gets you automatic restarts if one crashes:
--
--   systemctl --user enable --now waybar.service hyprpaper.service \
--                                 hypridle.service swaync.service
--
-- If you do that, comment out the matching lines below so they don't start
-- twice. Starting here is simpler to debug while the config is still moving,
-- which is why it's the default.

hl.on("hyprland.start", function()
  -- Authentication agent. Without this, nothing that needs a password can ask
  -- you for one — mounting a drive, installing a package from a GUI, etc.
  hl.exec_cmd("systemctl --user start hyprpolkitagent.service")

  -- Notification daemon. Some apps (Discord notably) hang waiting for one.
  hl.exec_cmd("swaync")

  -- Status bar.
  hl.exec_cmd("waybar")

  -- On-screen display for volume, brightness and caps lock.
  hl.exec_cmd("swayosd-server")

  -- Idle management: dim, lock, sleep. See hypridle.conf.
  hl.exec_cmd("hypridle")

  -- Wallpaper daemon. Safe to start unconditionally now that hyprpaper.conf
  -- declares no wallpaper of its own — with nothing to load it cannot fail on
  -- a missing file.
  hl.exec_cmd("hyprpaper")

  -- Re-apply whichever wallpaper you last chose. Waits for hyprpaper to accept
  -- IPC, and exits quietly if you have not picked one yet.
  hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/wallpaper.sh restore")

  -- Clipboard history. Two pieces: cliphist records, wl-clip-persist keeps
  -- clipboard contents alive after the app you copied from closes (Wayland
  -- drops them otherwise, which is a genuinely surprising default).
  hl.exec_cmd("wl-paste --type text  --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("wl-clip-persist --clipboard regular")

  -- Automount USB drives and phones, with a tray icon.
  hl.exec_cmd("udiskie --tray")

  -- Blue light filter after sunset. 4000K is a mild, non-orange warmth;
  -- drop toward 3000 if you want it stronger.
  hl.exec_cmd("hyprsunset --temperature 4000")

  -- Make sure D-Bus and systemd know about the session's environment. Without
  -- this the portal can start with a half-populated environment and file
  -- pickers or screenshare silently fail.
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
end)

-- Clean shutdown. Hyprland tears down its clients abruptly otherwise, which
-- occasionally leaves a stale lock or a wedged tray icon behind.
hl.on("hyprland.shutdown", function()
  os.execute("pkill hyprsunset; pkill -x waybar; sleep 0.1")
end)
