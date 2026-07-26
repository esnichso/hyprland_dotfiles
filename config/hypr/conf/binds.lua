-- Keybindings.
--
-- Reference: docs/hyprland/Configuring_Basics_Binds.md
--            docs/hyprland/Configuring_Basics_Dispatchers.md
--
-- Every action is bound to BOTH hjkl and the arrow keys, so you can lean on
-- arrows while hjkl becomes automatic. Delete the arrow lines once it has.
--
-- Note on SUPER+Q/R/M: Hyprland hardcodes emergency binds for these three
-- (terminal / launcher / exit) that take over if this file fails to load. R and
-- M below match that behaviour deliberately. Q does not — it closes the window,
-- because that is what you'll want a hundred times a day. If the config ever
-- breaks badly, SUPER+Q still gets you a terminal.

local mod = "SUPER"

local terminal    = "kitty"
local fileManager = "thunar"
local launcher    = "rofi -show drun"
local browser     = "xdg-open https://" -- replaced once you pick a browser

-- Small helper so a bind reads as one line instead of three.
local function bind(keys, action, flags)
  hl.bind(mod .. " + " .. keys, action, flags)
end

--------------------------------------------------------------------------
-- Applications
--------------------------------------------------------------------------

bind("Return", hl.dsp.exec_cmd(terminal),    { description = "Terminal" })
bind("E",      hl.dsp.exec_cmd(fileManager), { description = "File manager" })
bind("R",      hl.dsp.exec_cmd(launcher),    { description = "Application launcher" })

-- Power menu: logout / reboot / shutdown, first-party Hyprland dialog.
bind("M", hl.dsp.exec_cmd("hyprshutdown"), { description = "Power menu" })

-- Lock. Goes through logind rather than calling hyprlock directly, so hypridle
-- and anything else listening for the session-lock signal stay in sync.
bind("L", hl.dsp.exec_cmd("loginctl lock-session"), { description = "Lock screen" })

--------------------------------------------------------------------------
-- Window management
--------------------------------------------------------------------------

bind("Q", hl.dsp.window.close(),                    { description = "Close window" })
bind("SHIFT + Q", hl.dsp.window.kill(),             { description = "Force kill window" })
bind("V", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating" })
bind("F", hl.dsp.window.fullscreen({ mode = "fullscreen" }), { description = "Fullscreen" })
bind("SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Maximise (keeps gaps and bar)" })
bind("C", hl.dsp.window.center(),                   { description = "Centre floating window" })
bind("P", hl.dsp.window.pseudo(),                   { description = "Pseudotile" })
bind("T", hl.dsp.layout("togglesplit"),             { description = "Flip split direction" })
bind("SHIFT + P", hl.dsp.window.pin(),              { description = "Pin above all workspaces" })

-- Tabbed containers: group windows so they share one slot in the layout.
bind("G", hl.dsp.group.toggle(),                       { description = "Toggle group (tabs)" })
bind("SHIFT + G", hl.dsp.window.move({ out_of_group = true }), { description = "Leave group" })
bind("bracketleft",  hl.dsp.group.prev(),              { description = "Previous tab in group" })
bind("bracketright", hl.dsp.group.next(),              { description = "Next tab in group" })

--------------------------------------------------------------------------
-- Focus, move, resize
--------------------------------------------------------------------------

-- vim keys first, arrows bound to the same actions underneath.
local directions = {
  { key = "H", arrow = "left",  dir = "left" },
  { key = "J", arrow = "down",  dir = "down" },
  { key = "K", arrow = "up",    dir = "up" },
  { key = "L", arrow = "right", dir = "right" },
}

-- Resize steps, in pixels, per keypress.
local resize_step = 60
local resize_delta = {
  left  = { x = -resize_step, y = 0 },
  right = { x = resize_step,  y = 0 },
  up    = { x = 0, y = -resize_step },
  down  = { x = 0, y = resize_step },
}

for _, d in ipairs(directions) do
  -- SUPER + hjkl / arrows: move focus.
  -- SUPER+L is the lock bind above, so focus-right lives on the arrow key and
  -- on SUPER+odiaeresis (the key right of L on a German keyboard).
  if d.key ~= "L" then
    bind(d.key, hl.dsp.focus({ direction = d.dir }), { description = "Focus " .. d.dir })
  end
  bind(d.arrow, hl.dsp.focus({ direction = d.dir }), { description = "Focus " .. d.dir })

  -- SUPER + SHIFT + hjkl / arrows: move the window itself.
  bind("SHIFT + " .. d.key,   hl.dsp.window.move({ direction = d.dir }), { description = "Move window " .. d.dir })
  bind("SHIFT + " .. d.arrow, hl.dsp.window.move({ direction = d.dir }), { description = "Move window " .. d.dir })

  -- SUPER + CTRL + hjkl / arrows: resize, repeating while held.
  local delta = resize_delta[d.dir]
  bind("CTRL + " .. d.key,   hl.dsp.window.resize({ x = delta.x, y = delta.y, relative = true }), { repeating = true, description = "Resize " .. d.dir })
  bind("CTRL + " .. d.arrow, hl.dsp.window.resize({ x = delta.x, y = delta.y, relative = true }), { repeating = true, description = "Resize " .. d.dir })
end

-- Focus right on hjkl. On the German layout the key right of L is ö.
bind("odiaeresis", hl.dsp.focus({ direction = "right" }), { description = "Focus right (hjkl)" })

-- Cycle windows on the current workspace, ignoring layout position.
bind("Tab", hl.dsp.window.cycle_next(),                  { description = "Next window" })
bind("SHIFT + Tab", hl.dsp.window.cycle_next({ next = false }), { description = "Previous window" })

-- Jump back to the last focused window, or one that's demanding attention.
bind("grave", hl.dsp.focus({ urgent_or_last = true }), { description = "Last / urgent window" })

--------------------------------------------------------------------------
-- Workspaces
--------------------------------------------------------------------------

-- SUPER + 1..0 to switch, SUPER + SHIFT + 1..0 to send the window there.
for i = 1, 10 do
  local key = i % 10 -- workspace 10 sits on the 0 key
  bind(tostring(key),           hl.dsp.focus({ workspace = i }),        { description = "Workspace " .. i })
  bind("SHIFT + " .. key,       hl.dsp.window.move({ workspace = i }),  { description = "Send to workspace " .. i })
end

-- Next / previous *existing* workspace. `e+1` skips empty ones.
bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind("mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
bind("period", hl.dsp.focus({ workspace = "e+1" }), { description = "Next workspace" })
bind("comma",  hl.dsp.focus({ workspace = "e-1" }), { description = "Previous workspace" })

-- Scratchpad: a workspace that floats above whatever you're doing. Put a
-- terminal or notes app here and toggle it in and out.
bind("S",         hl.dsp.workspace.toggle_special("scratch"),         { description = "Toggle scratchpad" })
bind("SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }), { description = "Send to scratchpad" })

--------------------------------------------------------------------------
-- Mouse
--------------------------------------------------------------------------

-- Hold SUPER and drag anywhere in a window to move or resize it — no need to
-- aim at a border.
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------------------------------------------------
-- Screenshots
--------------------------------------------------------------------------

-- Print            select a region, annotate in satty
-- SHIFT + Print    whole screen, annotate in satty
-- SUPER + Print    select a region straight to the clipboard, no UI
--
-- In satty: Ctrl+C copies, Ctrl+S saves to ~/Pictures/Screenshots.
local satty = 'satty -f - --copy-command wl-copy --early-exit '
  .. '--output-filename "$HOME/Pictures/Screenshots/%Y%m%d-%H%M%S.png"'

hl.bind("Print",         hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | ' .. satty), { description = "Screenshot region" })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("grim - | " .. satty),                  { description = "Screenshot screen" })
bind("Print",            hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'),   { description = "Screenshot region to clipboard" })

-- Colour picker: click anywhere, hex lands in the clipboard.
bind("SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Pick a colour" })

--------------------------------------------------------------------------
-- Clipboard and notifications
--------------------------------------------------------------------------

-- Clipboard history through rofi. cliphist stores it, wl-copy puts the choice
-- back on the clipboard.
bind("SHIFT + V",
  hl.dsp.exec_cmd('cliphist list | rofi -dmenu -display-columns 2 -p "Clipboard" | cliphist decode | wl-copy'),
  { description = "Clipboard history" })

-- Notification centre panel.
bind("N", hl.dsp.exec_cmd("swaync-client -t -sw"), { description = "Notification centre" })
bind("SHIFT + N", hl.dsp.exec_cmd("swaync-client -d -sw"), { description = "Toggle do-not-disturb" })

--------------------------------------------------------------------------
-- Hardware keys
--------------------------------------------------------------------------
--
-- `locked = true` keeps these working while the screen is locked — you should
-- be able to mute a meeting without unlocking. `repeating = true` lets you hold
-- the key to ramp volume or brightness.
--
-- swayosd-client draws the on-screen popup and performs the change. If the
-- popups don't appear, check that swayosd-server is running (see autostart.lua)
-- and fall back to the direct commands listed underneath each bind.

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("swayosd-client --output-volume raise"),      { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("swayosd-client --output-volume lower"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),  { locked = true })
-- Fallback without OSD:
--   wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
--   wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
--   wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
--   wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { locked = true, repeating = true })
-- Fallback without OSD:
--   brightnessctl -e4 -n2 set 5%+
--   brightnessctl -e4 -n2 set 5%-

-- Media keys, via playerctl. Work with anything MPRIS-aware: browsers, mpv,
-- Spotify.
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- ThinkPads put a calculator/star key up there on some models; harmless if the
-- key doesn't exist on yours.
hl.bind("XF86Favorites", hl.dsp.exec_cmd(launcher))

--------------------------------------------------------------------------
-- Session utilities
--------------------------------------------------------------------------

-- Reload the config by hand. It also reloads automatically on save; this is for
-- when you've edited something outside your editor, or want to be sure.
bind("SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"), { description = "Reload config" })

-- Restart Waybar. Useful while you're editing its config, which does not
-- hot-reload as reliably as Hyprland's.
bind("SHIFT + B", hl.dsp.exec_cmd("pkill waybar; sleep 0.2; waybar"), { description = "Restart the bar" })

-- Toggle blur. The single biggest GPU cost in this config — turn it off when
-- you want the battery to last.
bind("SHIFT + X", function()
  local blur = hl.get_config("decoration.blur.enabled")
  hl.config({ decoration = { blur = { enabled = not blur } } })
  hl.notification.create({
    text    = blur and "Blur off" or "Blur on",
    timeout = 1500,
    icon    = "ok",
  })
end, { description = "Toggle blur" })

--------------------------------------------------------------------------
-- Resize mode
--------------------------------------------------------------------------
--
-- SUPER + ALT + R enters a mode where the arrow keys resize continuously,
-- rather than holding three modifiers. Escape or Return leaves it.
-- If you ever get stuck in a submap: hyprctl dispatch 'hl.dsp.submap("reset")'

bind("ALT + R", hl.dsp.submap("resize"), { description = "Resize mode" })

hl.define_submap("resize", function()
  hl.bind("right", hl.dsp.window.resize({ x = 60,  y = 0,   relative = true }), { repeating = true })
  hl.bind("left",  hl.dsp.window.resize({ x = -60, y = 0,   relative = true }), { repeating = true })
  hl.bind("up",    hl.dsp.window.resize({ x = 0,   y = -60, relative = true }), { repeating = true })
  hl.bind("down",  hl.dsp.window.resize({ x = 0,   y = 60,  relative = true }), { repeating = true })

  hl.bind("L", hl.dsp.window.resize({ x = 60,  y = 0,   relative = true }), { repeating = true })
  hl.bind("H", hl.dsp.window.resize({ x = -60, y = 0,   relative = true }), { repeating = true })
  hl.bind("K", hl.dsp.window.resize({ x = 0,   y = -60, relative = true }), { repeating = true })
  hl.bind("J", hl.dsp.window.resize({ x = 0,   y = 60,  relative = true }), { repeating = true })

  hl.bind("escape", hl.dsp.submap("reset"))
  hl.bind("Return", hl.dsp.submap("reset"))
end)
