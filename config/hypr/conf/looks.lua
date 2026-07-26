-- Look and feel: gaps, borders, rounding, blur, shadows, animations.
--
-- Reference: docs/hyprland/Configuring_Basics_Variables.md
--            docs/hyprland/Configuring_Advanced_and_Cool_Animations.md

local c = require("conf/theme")

hl.config({
  general = {
    -- Gaps are in *logical* pixels, so they scale with the display. On a
    -- 2560x1600 panel at scale 1.6 these read as fairly generous.
    gaps_in  = 5,
    gaps_out = 12,

    border_size = 2,

    col = {
      -- A gradient reads as a subtle highlight on the focused window rather
      -- than a hard outline. 45 degrees runs bottom-left to top-right.
      active_border   = { colors = { c.mauve_a, c.blue_a }, angle = 45 },
      inactive_border = c.surface_a,
    },

    -- Drag window edges *and the gaps between them* to resize. Much nicer than
    -- hunting for a 2px border.
    resize_on_border        = true,
    extend_border_grab_area = 15,

    -- Floating windows snap to each other and to screen edges.
    snap = {
      enabled     = true,
      window_gap  = 10,
      monitor_gap = 10,
    },

    layout = "dwindle",
  },

  decoration = {
    rounding = 10,
    -- 2.0 is a true circle; higher values approach a squircle. 2.0 matches the
    -- corner radius of Waybar and rofi below, so everything looks related.
    rounding_power = 2.0,

    -- Slight transparency on unfocused windows makes the focused one obvious
    -- without needing to look at the border. Kept mild so text stays readable.
    active_opacity   = 1.0,
    inactive_opacity = 0.94,

    blur = {
      enabled = true,
      -- size x passes is the real cost. 6/2 looks essentially identical to
      -- 8/3 on this panel and costs noticeably less battery.
      size   = 6,
      passes = 2,

      -- Deliberately OFF (which is also upstream's default).
      --
      -- xray makes floating windows ignore tiled windows in their blur, which
      -- is cheaper — but it also means a translucent floating window composites
      -- against the wallpaper layer instead of the window actually behind it.
      -- A floating terminal over a browser then renders as a flat rectangle of
      -- wallpaper colour and looks completely opaque.
      --
      -- Turn it back on only if floating blur costs too much performance, and
      -- accept that see-through stops working for floating windows.
      xray = false,

      -- Blur right-click menus and popups too, otherwise they look pasted on.
      popups            = true,
      popups_ignorealpha = 0.2,

      vibrancy           = 0.1696,
      vibrancy_darkness  = 0.0,
      noise              = 0.0117,
      brightness         = 0.9,
      contrast           = 0.95,

      new_optimizations = true,
    },

    shadow = {
      enabled      = true,
      range        = 20,
      render_power = 3,
      color        = c.shadow,
      -- Slightly downward, like a real light source above the screen.
      offset       = { 0, 4 },
      scale        = 0.97,
    },
  },

  animations = {
    enabled = true,
  },
})

-- Curves. `bezier` takes the two control points of a cubic Bézier; `spring`
-- takes physical parameters (higher stiffness = faster, higher dampening = less
-- bounce). Springs feel more natural for window motion, Béziers for fades.
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },   { 0.32, 1 } } })
hl.curve("easeOutCubic",   { type = "bezier", points = { { 0.33, 1 },   { 0.68, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },  { 0.75, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },      { 1, 1 } } })
hl.curve("snappy",         { type = "spring", mass = 1, stiffness = 250, dampening = 24 })

-- Speed is in deciseconds: speed = 4 means 400ms. Everything here is tuned to
-- feel quick rather than showy — animations you notice once and then stop
-- seeing. Raise the numbers if you want them more languid.
hl.animation({ leaf = "global",        enabled = true, speed = 6,    bezier = "easeOutQuint" })
hl.animation({ leaf = "border",        enabled = true, speed = 4,    bezier = "easeOutCubic" })

hl.animation({ leaf = "windows",       enabled = true, speed = 4,    spring = "snappy" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 3.5,  spring = "snappy",      style = "popin 90%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2,    bezier = "easeOutCubic", style = "popin 90%" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 3.5,  spring = "snappy" })

hl.animation({ leaf = "fade",          enabled = true, speed = 2.5,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.7,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.5,  bezier = "almostLinear" })

-- Layers are the bar, launcher and notifications. Fading them in is less
-- distracting than sliding, since they appear at fixed screen edges.
hl.animation({ leaf = "layers",        enabled = true, speed = 3,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 3,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })

hl.animation({ leaf = "workspaces",    enabled = true, speed = 4,    spring = "snappy",       style = "slidefade 15%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, spring = "snappy",       style = "slidevert" })

-- Dwindle: every new window splits the focused one in half, alternating
-- horizontal/vertical based on the shape of the space it's splitting.
hl.config({
  dwindle = {
    -- Without this the split direction silently flips as windows resize, which
    -- makes the layout feel unpredictable. You almost certainly want it on.
    preserve_split = true,
    -- New window goes where the focused window is, not where the mouse is.
    use_active_for_splits = true,
    -- Resize direction depends on which corner the mouse is nearest.
    smart_resizing = true,
  },
})

hl.config({
  misc = {
    -- No anime mascot on the empty desktop; use a flat colour instead. This is
    -- what you see before hyprpaper has a wallpaper to show.
    disable_hyprland_logo   = true,
    disable_splash_rendering = true,
    force_default_wallpaper  = 0,
    background_color         = "rgb(11111b)",

    font_family = "JetBrainsMono Nerd Font",

    -- Don't let a background app steal focus mid-typing.
    focus_on_activate = false,

    -- New windows open on the workspace they were launched from, even if you
    -- switch away while the app is starting.
    initial_workspace_tracking = 1,

    -- Adaptive sync. 2 = fullscreen only, which avoids flicker in normal
    -- desktop use while still helping video and games.
    vrr = 2,

    -- If the lock screen crashes, allow a new one to take over instead of
    -- stranding you on the "lockscreen app died" screen with no way back
    -- except a TTY. Off by default upstream; there is no good reason for it
    -- to be off on a machine you actually use.
    allow_session_lock_restore = true,
  },

  ecosystem = {
    -- No "you updated Hyprland" popup on every release.
    no_update_news = true,
  },

  cursor = {
    -- Hide the pointer after 5s of not moving it. On a laptop you're mostly on
    -- the keyboard and a parked cursor over text is just noise.
    inactive_timeout = 5,
    hide_on_key_press = true,
  },
})
