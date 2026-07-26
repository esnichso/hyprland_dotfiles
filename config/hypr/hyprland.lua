-- ~/.config/hypr/hyprland.lua
--
-- Entry point. Everything real lives in conf/ and is pulled in below.
--
-- Written against Hyprland 0.56 (Lua config). The old hyprlang `key = value`
-- syntax was deprecated in 0.55 and this version no longer reads it, so any
-- snippet you find online from before May 2026 will need translating.
--
-- The config reloads the moment you save. `hyprctl reload` forces it.

local modules = {
  "conf/looks",     -- colors, gaps, blur, animations
  "conf/monitors",  -- displays
  "conf/input",     -- keyboard, touchpad, gestures
  "conf/binds",     -- keybindings
  "conf/rules",     -- window / workspace / layer rules
  "conf/autostart", -- what starts with the session
}

-- Each require() runs in its own Lua scope, so a runtime error inside one file
-- does not stop the others loading. That protection does NOT extend to the
-- module *lookup* itself: a require() for a file that cannot be found throws in
-- this file and kills everything below it, which drops you into emergency mode
-- with no binds at all.
--
-- That is not just a typo guard. `git pull` rewrites files one at a time, and
-- Hyprland reloads the instant it sees a change — so a reload can land in the
-- window where a file has been removed but not yet written back, and take out
-- the whole config for a moment that has nothing to do with its contents.
--
-- pcall keeps the failure local: you lose one file, get told which, and
-- everything else still works.
for _, module in ipairs(modules) do
  local ok, err = pcall(require, module)

  if not ok then
    -- Goes to ~/.local/share/hyprland/hyprland.log
    print("[config] failed to load " .. module .. ": " .. tostring(err))

    hl.notification.create({
      text    = "Config: " .. module .. " failed to load.\nRun `hyprctl reload` — if it persists, check the log.",
      timeout = 10000,
      icon    = 3, -- error
    })
  end
end
