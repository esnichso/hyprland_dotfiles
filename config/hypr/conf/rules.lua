-- Window, workspace and layer rules.
--
-- Reference: docs/hyprland/Configuring_Basics_Window-Rules.md
--            docs/hyprland/Configuring_Basics_Workspace-Rules.md
--
-- Rules match on window class and title. To find out what a given window calls
-- itself, open it and run:  hyprctl clients
--
-- Order matters: rules apply top to bottom and the LAST match wins. Named rules
-- are all evaluated before anonymous ones.

local c = require("conf/theme")

--------------------------------------------------------------------------
-- Global behaviour
--------------------------------------------------------------------------

-- Ignore apps that ask to maximise themselves on launch. Without this, things
-- like LibreOffice and some Electron apps fight your layout.
hl.window_rule({
  name           = "suppress-maximize",
  match          = { class = ".*" },
  suppress_event = "maximize",
})

-- Known XWayland quirk: some drag operations create an invisible, classless,
-- titleless floating window that steals focus. This keeps focus where it was.
hl.window_rule({
  name  = "fix-xwayland-drags",
  match = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
})

--------------------------------------------------------------------------
-- Dialogs and utilities that should float
--------------------------------------------------------------------------

-- System dialogs: small, centred, not worth tiling.
hl.window_rule({
  match  = { class = "^(pavucontrol|org.pulseaudio.pavucontrol)$" },
  float  = true,
  size   = { 900, 620 },
  center = true,
})

hl.window_rule({
  match  = { class = "^(blueman-manager|\\.blueman-manager-wrapped)$" },
  float  = true,
  size   = { 800, 560 },
  center = true,
})

hl.window_rule({
  match  = { class = "^(nm-connection-editor)$" },
  float  = true,
  size   = { 800, 600 },
  center = true,
})

-- Terminal UIs launched from the bar. Without this, nmtui opens tiled and
-- takes over the whole screen, which is what made clicking the network module
-- feel like a mistake. Waybar launches it with --class so it can be matched.
hl.window_rule({
  match  = { class = "^(tui-float)$" },
  float  = true,
  size   = { 900, 620 },
  center = true,
})

hl.window_rule({
  match  = { class = "^(nwg-look|qt6ct|qt5ct|kvantummanager)$" },
  float  = true,
  center = true,
})

-- Hyprland's own dialogs and the screenshare picker.
hl.window_rule({
  match  = { class = "^(hyprland-share-picker|hyprshutdown|hyprpolkitagent)$" },
  float  = true,
  center = true,
})

-- Authentication prompts must never lose focus mid-typing.
hl.window_rule({
  match        = { class = "^(polkit-|hyprpolkitagent)(.*)$" },
  float        = true,
  center       = true,
  stay_focused = true,
})
hl.window_rule({
  match        = { class = "^(pinentry-)(.*)$" },
  float        = true,
  center       = true,
  stay_focused = true,
})

-- File pickers, generic "Open File" / "Save As" dialogs across toolkits.
hl.window_rule({
  match  = { title = "^(Open|Open File|Open Folder|Save|Save As|Save File|Datei öffnen|Speichern unter)(.*)$" },
  float  = true,
  size   = { 1000, 680 },
  center = true,
})

-- Progress dialogs and modals in general.
hl.window_rule({
  match  = { modal = true },
  float  = true,
  center = true,
  -- Dim the parent so the modal is obviously in front.
  dim_around = true,
})

--------------------------------------------------------------------------
-- Media
--------------------------------------------------------------------------

-- Picture-in-picture: float it, pin it above every workspace, park it in the
-- bottom-right corner. Works for Firefox and Chromium.
hl.window_rule({
  name  = "picture-in-picture",
  match = { title = "^(Picture-in-Picture|Bild-im-Bild)$" },
  float = true,
  pin   = true,
  size  = { 640, 360 },
  move  = { "monitor_w-660", "monitor_h-400" },
})

-- Video and games shouldn't be dimmed, blurred, or allowed to sleep the screen.
hl.window_rule({
  match        = { class = "^(mpv|imv)$" },
  float        = false,
  idle_inhibit = "focus",
  no_blur      = true,
  no_dim       = true,
})

-- Full-screen video in a browser keeps the screen awake too.
hl.window_rule({
  match        = { fullscreen = true },
  idle_inhibit = "fullscreen",
})

--------------------------------------------------------------------------
-- Appearance
--------------------------------------------------------------------------

-- No opacity rule for kitty on purpose.
--
-- A window-rule opacity fades the whole window, text included, which makes a
-- terminal look washed out. kitty's own `background_opacity` (see
-- config/kitty/kitty.conf) makes only the background translucent and leaves
-- glyphs fully opaque — that is what reads well over blur.

-- Never make these transparent — transparency on an image viewer or design tool
-- is actively misleading.
hl.window_rule({
  match   = { class = "^(mpv|imv|GIMP|Inkscape|org.inkscape.Inkscape)$" },
  opacity = "1.0 override 1.0 override",
  opaque  = true,
})

-- Floating windows get a slightly stronger border so they read as detached.
hl.window_rule({
  match        = { float = true },
  border_size  = 2,
  rounding     = 12,
  border_color = { colors = { c.accent_alt, c.accent }, angle = 45 },
})

--------------------------------------------------------------------------
-- Workspace rules
--------------------------------------------------------------------------

-- "Smart gaps" removed on purpose.
--
-- It used to strip the gaps, border and rounding whenever a workspace held a
-- single tiled window, to reclaim screen space. That is why one terminal on an
-- empty workspace looked almost fullscreen. A single window now gets the same
-- frame as any other, which is easier to read and more consistent.
--
-- To bring it back, restore these four rules:
--
--   hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
--   hl.workspace_rule({ workspace = "f[1]s[false]",   gaps_out = 0, gaps_in = 0 })
--   hl.window_rule({ name = "smart-gaps-single",
--     match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0, rounding = 0 })
--   hl.window_rule({ name = "smart-gaps-fullscreen",
--     match = { float = false, workspace = "f[1]s[false]" },   border_size = 0, rounding = 0 })

-- The scratchpad renders slightly inset so it visibly floats over the desktop.
hl.workspace_rule({
  workspace = "special:scratch",
  gaps_out  = 40,
  gaps_in   = 8,
  -- Opens a terminal the first time you toggle it, so it's never empty.
  on_created_empty = "kitty",
})

--------------------------------------------------------------------------
-- Layer rules
--------------------------------------------------------------------------
--
-- Layers are the things that aren't windows: the bar, the launcher, the
-- notification centre, the wallpaper. Find namespaces with: hyprctl layers

-- Blur behind the bar and the launcher. `ignore_alpha` stops fully transparent
-- pixels from being blurred, which is what keeps rounded corners clean.
hl.layer_rule({ match = { namespace = "^waybar$" }, blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ match = { namespace = "^rofi$" },   blur = true, ignore_alpha = 0.3 })

-- Deliberately a prefix match rather than an exact list: swaync uses several
-- namespaces (control-center, notification-window, and more depending on
-- version) and an exact pattern that misses one silently leaves it unblurred.
--
-- Blur only shows through if the surface is actually translucent — swaync's
-- own CSS backgrounds are set around 0.75 alpha for exactly this reason.
hl.layer_rule({
  match        = { namespace = "^swaync-.*" },
  blur         = true,
  blur_popups  = true,
  ignore_alpha = 0.2,
})

-- The volume/brightness OSD pops up constantly; animating it is distracting.
hl.layer_rule({ match = { namespace = "^swayosd$" }, blur = true, no_anim = true })

-- The region-select overlay must appear instantly, with no fade.
hl.layer_rule({ match = { namespace = "^selection$" }, no_anim = true })
