-- ~/.config/hypr/hyprland.lua
--
-- Entry point. Everything real lives in conf/ and is pulled in below.
--
-- Written against Hyprland 0.56 (Lua config). The old hyprlang `key = value`
-- syntax was deprecated in 0.55 and this version no longer reads it, so any
-- snippet you find online from before May 2026 will need translating.
--
-- The config reloads the moment you save. `hyprctl reload` forces it.
--
-- Each require() runs in its own Lua scope: an error in one file does NOT stop
-- the others from loading. That is why this is split up rather than one big
-- file — a typo in binds.lua still leaves you with a working display and mouse.

require("conf/looks")     -- colors, gaps, blur, animations
require("conf/monitors")  -- displays
require("conf/input")     -- keyboard, touchpad, gestures
require("conf/binds")     -- keybindings
require("conf/rules")     -- window / workspace / layer rules
require("conf/autostart") -- what starts with the session
