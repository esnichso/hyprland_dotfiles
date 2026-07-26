-- Displays.
--
-- Reference: docs/hyprland/Configuring_Basics_Monitors.md
-- Check what's actually connected with:  hyprctl monitors all

-- The ThinkPad's internal panel: 16", 2560x1600.
--
-- On scale: a scale must divide the resolution into whole logical pixels or
-- Hyprland warns and refuses it. That rules out the usual 1.5 here
-- (2560 / 1.5 = 1706.67). Valid options on this panel:
--
--   1.6  -> 1600x1000 logical   comfortable, matches ~150% on GNOME
--   1.25 -> 2048x1280 logical   smaller UI, much more room
--   1.0  -> 2560x1600 logical   native, very small text at 16"
--
-- Starting at 1.6. If everything feels oversized, try 1.25 — it's a one-word
-- edit and takes effect on save.
hl.monitor({
  output   = "eDP-1",
  mode     = "preferred", -- highest resolution + refresh rate the panel reports
  position = "0x0",
  scale    = 1.6,
})

-- Catch-all for anything you plug in later: use its preferred mode, place it to
-- the right of the laptop screen, let Hyprland pick a scale from the PPI.
-- Without this rule an unknown monitor gets no configuration at all.
hl.monitor({
  output   = "",
  mode     = "preferred",
  position = "auto-right",
  scale    = "auto",
})

-- Handy for later, when you know a specific external monitor:
--
-- hl.monitor({
--   output   = "DP-1",
--   mode     = "2560x1440@144",
--   position = "auto-right",
--   scale    = 1,
--   vrr      = 2,          -- adaptive sync, fullscreen only
-- })
--
-- Matching by description survives replugging into a different port:
--   hl.monitor({ output = "desc:Dell Inc. DELL U2723QE", ... })
-- Get the string from `hyprctl monitors` and drop the trailing "(DP-1)".
