-- Keyboard, mouse, touchpad and trackpad gestures.
--
-- Reference: docs/hyprland/Configuring_Basics_Variables.md (Input section)
--            docs/hyprland/Configuring_Advanced_and_Cool_Gestures.md

hl.config({
  input = {
    -- German layout, matching the ThinkPad's physical keyboard and your
    -- current Ubuntu setting.
    kb_layout  = "de",
    kb_variant = "",
    kb_model   = "",
    kb_rules   = "",

    -- Caps Lock is a huge key in the best position on the keyboard and does
    -- nothing useful. This makes it a second Escape.
    -- Other options worth knowing:
    --   "ctrl:nocaps"      Caps Lock becomes Ctrl
    --   "compose:menu"     Menu key becomes Compose, for ¯\_(ツ)_/¯
    -- Full list: grep caps /usr/share/X11/xkb/rules/base.lst
    kb_options = "caps:escape",

    -- Focus follows the mouse. 1 = focus whatever the cursor is over.
    -- Set to 0 if you'd rather focus only on click.
    follow_mouse = 1,
    -- Don't change focus for tiny cursor jitters near a window edge.
    follow_mouse_threshold = 2.0,

    -- When you close a window, focus the most recently used one rather than
    -- whatever happens to be adjacent. Much less disorienting.
    focus_on_close = 2,

    -- Faster key repeat than the default 25/600 — noticeable when holding
    -- backspace or navigating with arrows.
    repeat_rate  = 40,
    repeat_delay = 400,

    -- 0 = libinput's default acceleration, unmodified. Only change this if the
    -- pointer feels wrong; the range is -1.0 to 1.0.
    sensitivity = 0.0,

    touchpad = {
      -- Content follows your fingers, like a phone or macOS.
      natural_scroll = true,

      -- Tap with 1/2/3 fingers = left/right/middle click.
      tap_to_click  = true,
      clickfinger_behavior = true,

      -- Stops the cursor jumping when your palm brushes the pad mid-sentence.
      disable_while_typing = true,

      -- Tap-and-drag: tap, then immediately touch and move to drag.
      tap_and_drag = true,
      drag_lock    = 1,

      -- The touchpad on this machine is large; slightly damp the scroll so a
      -- full swipe doesn't fly down the page.
      scroll_factor = 0.8,
    },
  },
})

-- Trackpad gestures. These are 1:1 — the workspace follows your fingers as you
-- move, rather than firing once you cross a threshold.
--
-- Reference: docs/hyprland/Configuring_Advanced_and_Cool_Gestures.md

-- Three fingers left/right: move between workspaces. The single most useful
-- gesture on a laptop.
hl.gesture({
  fingers   = 3,
  direction = "horizontal",
  action    = "workspace",
})

-- Three fingers up: fullscreen the focused window. Down un-does it.
hl.gesture({
  fingers   = 3,
  direction = "up",
  action    = "fullscreen",
})

-- Four fingers down: show the scratchpad (see binds.lua, SUPER+S).
hl.gesture({
  fingers        = 4,
  direction      = "down",
  action         = "special",
  workspace_name = "scratch",
})

-- Pinch to zoom the whole screen around the cursor. "live" tracks the pinch
-- continuously instead of snapping to a fixed zoom level.
--
-- Heads up: the upstream wiki is inconsistent about this action's name — the
-- reference table says `cursor_zoom`, the examples underneath say `cursorZoom`.
-- Using the table's spelling. If pinch-to-zoom does nothing, try the other one;
-- a wrong action name fails silently rather than erroring.
hl.gesture({
  fingers    = 2,
  direction  = "pinch",
  action     = "cursor_zoom",
  zoom_level = 1,
  mode       = "live",
})

hl.config({
  gestures = {
    -- Distance your fingers travel for a full workspace switch.
    workspace_swipe_distance = 400,
    -- How far you must swipe before it commits rather than springing back.
    workspace_swipe_cancel_ratio = 0.4,
    -- Don't create a new workspace by swiping past the last one — too easy to
    -- do by accident.
    workspace_swipe_create_new = false,
  },
})

-- Per-device tweaks go here. Find exact device names with `hyprctl devices`:
--
-- hl.device({
--   name           = "elan-touchpad",
--   natural_scroll = false,
-- })
