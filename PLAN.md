# Round 2 — fixes and rework

Everything reported after the VM run, grouped by what it needs from you.

| | Issue | Cause | Needs you? |
| --- | --- | --- | --- |
| 1 | `SUPER+M` logs out instead of showing a menu | My mistake — wrong tool | pick a style |
| 2 | `Ö` for focus-right leaves a gap at `L` | My mistake — bad call | no |
| 3 | Screenshot binds need a Print key you don't have | My mistake — assumed | no |
| 4 | Battery missing from the bar | VM has no battery | verify on metal |
| 5 | Grey squircle top-left does nothing | Workspace dots, unclear design | folded into bar rework |
| 6 | Network click opens a giant TUI | My mistake — unfloated | no |
| 7 | Dolphin and Qt apps ignore the theme | Never configured | no |
| 8 | Bar rework | — | yes |
| 9 | Font change | — | yes |
| 10 | Fish prompt | — | yes |
| 11 | No blur on the terminal | Wrong mechanism | no |
| 12 | No blur on notifications | Namespace + too opaque | no |
| 13 | Single window opens borderless | Deliberate, you dislike it | no |
| 14 | How to change wallpapers | Undocumented | no |

---

## A. My mistakes — fixing these regardless

### 1. `SUPER+M` — power menu

`hyprshutdown` is **not** a menu. Per its docs it is "a graceful shutdown
utility… opens a GUI and gracefully asks apps to exit, then quits Hyprland."
The action is chosen at invocation:

```sh
hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'
hyprshutdown -t 'Restarting...'    --post-cmd 'reboot'
```

I read the package name and assumed a chooser. It logged you out because that
is what it does.

**Fix:** a small rofi power menu — Lock / Logout / Suspend / Reboot / Shutdown —
that calls `hyprshutdown` with the right `--post-cmd` per entry. No new
packages, themed to match the launcher, and it still gets the graceful app
shutdown that makes `hyprshutdown` worth using over `dispatch exit`.

Also worth knowing: the logout screen you land on is SDDM, and it *is* the same
one you see at boot. `SUPER+L` shows hyprlock instead, which locks the running
session rather than ending it.

### 2. `hjklö` — put focus-right back on `L`

You're right and my reasoning was backwards. I moved focus-right to `Ö` to keep
`SUPER+L` free for the lock screen, which leaves a hole in the middle of the
row. Standard vim navigation matters more than where the lock bind sits.

**Fix:** `SUPER+H/J/K/L` for focus, `Ö` unbound. Lock moves to **`SUPER+Escape`** —
away from anything you press by accident, and easy to reach since Caps Lock is
already Escape.

### 3. Screenshots without a Print key

**Fix:**

| New | Action |
| --- | --- |
| `SUPER+SHIFT+S` | Region → annotate in satty |
| `SUPER+SHIFT+D` | Whole screen → annotate |
| `SUPER+SHIFT+A` | Region → straight to clipboard |

`SUPER+SHIFT+S` is muscle memory from Windows and Windows-adjacent tools. The
existing `Print` binds stay as well — harmless, and they work if you ever dock
an external keyboard.

The scratchpad move bind currently on `SUPER+SHIFT+S` relocates to
`SUPER+SHIFT+X`.

### 6. Network click

`nmtui` is a full-screen terminal UI and I launched it tiled, so it swallowed
the screen.

**Fix:** launch it as a floating 900×600 window with its own class, matched by a
window rule. `nm-connection-editor` is already installed if you'd rather have a
proper GUI — say so and I'll switch the click target instead.

### 11. Blur on the terminal

Two different things got confused. I set a **window rule** opacity of
`0.94 / 0.88` on kitty, which fades the *entire window including the text*.
What you want is kitty's own `background_opacity`, which makes only the
background translucent and leaves glyphs fully opaque — that's what looks good
over blur.

**Fix:** drop the window-rule opacity for kitty, set `background_opacity 0.85`
in kitty's config. This means adding `config/kitty/` to the repo, which
currently stays out of the way so your Ubuntu config carries over — I'll write
a minimal one that only sets appearance and leave your keybindings alone.

### 12. Blur on notifications

Two causes. The layer rule matches `^swaync-(control-center|notification-window)$`,
which I wrote from memory rather than from `hyprctl layers`; and even if it
matched, swaync's CSS is at 92% opacity, so there's almost nothing for the blur
to show through.

**Fix:** confirm the real namespaces with `hyprctl layers` in the running
session, correct the rule, and drop swaync's background alpha to ~0.75.

### 13. Single window opens borderless

Deliberate — "smart gaps", which strips gaps, border and rounding when a
workspace holds exactly one tiled window, to reclaim screen space on a laptop.
You prefer the frame.

**Fix:** remove the four smart-gaps rules from `rules.lua`. One window then
looks like any other. Easy to restore if you change your mind.

---

## B. Missing configuration

### 7. Qt and GTK theming

The packages are installed but nothing is *configured*, so Dolphin, pavucontrol
and friends still use default Breeze/Adwaita. Needed:

- `config/gtk-3.0/settings.ini` — Catppuccin Mocha theme, Papirus icons, Bibata
  cursor, font
- `config/gtk-4.0/` — libadwaita apps ignore GTK themes, so this needs the
  Catppuccin CSS import route instead
- `config/qt6ct/qt6ct.conf` + `config/qt5ct/qt5ct.conf` — point Qt at Kvantum,
  set font and icon theme
- `config/Kvantum/kvantum.kvconfig` — select a Catppuccin Kvantum theme
- `gsettings` values, since some GTK apps read those rather than the ini

Dolphin is a KDE app; it will follow qt6ct once Kvantum is pointed at the right
theme. Note we did **not** install the KDE platform integration, so a few
KDE-specific bits may still look plain — tell me if any specific app still
looks wrong after this.

### 10. Fish prompt

You already use fish. Options in the questions below. Whichever you pick gets a
Catppuccin-matched config committed to the repo, plus `fish` and any prompt
package added to the package list.

### 14. Wallpapers

Already wired, just undocumented:

```bash
# drop images in this folder — hyprpaper rotates every 15 minutes, randomly
~/Pictures/wallpapers/

# change immediately, no restart
hyprctl hyprpaper wallpaper ",~/Pictures/wallpapers/foo.jpg,cover"
```

Edit `config/hypr/hyprpaper.conf` to change the rotation interval, turn off
rotation (point `path` at a single file), or set per-monitor wallpapers.

**Fix:** add a `SUPER+W` keybind that jumps to a random wallpaper immediately,
and document all of this in `KEYBINDS.md`.

---

## C. Needs your input

**8. Bar rework** and **9. Font** — see the questions.

The grey squircle top-left is the `hyprland/workspaces` module: I gave it dot
icons rather than numbers, so a single workspace renders as one grey dot with
nothing to distinguish it. It *is* clickable, there's just only one of them.
Numbers instead of dots fixes the confusion, and the rework covers the rest.

---

## D. Verify on real hardware

**4. Battery** — Waybar's battery module hides itself when there's no battery
device, and a VM has none. Should appear on the ThinkPad. Confirm with:

```bash
ls /sys/class/power_supply/     # expect BAT0 and AC
upower -i $(upower -e | grep BAT)
```

If it's still missing on metal, the module needs an explicit `"bat": "BAT0"`.

---

## Order of work

1. Answer the questions below.
2. I fix everything in section A and B — one commit per area, so anything you
   dislike is a clean revert.
3. You pull in the VM, check it over.
4. Then Phase 2/3: back up and install on the ThinkPad.

Nothing here blocks the metal install — it's all config, and it all travels
through git. If you'd rather get onto real hardware first and fix the rest
there, that works too, and the battery question answers itself.


---

## Round 3 — rofi theming (2026-07-27)

Three bugs, all in the same area:

1. `launcher.rasi` still carried a hardcoded Catppuccin palette and no
   `@import "colors"`. My edit script's regex was anchored with `^` but
   without `re.M`, so it matched nothing — and printed success anyway. The
   launcher therefore resolved palette names locally but not the new
   shorthands (`bg`, `bg-alt`, `fg`), which is exactly the set rofi
   complained about.
2. A comment inside the `*` block of the generated `colors.rasi` made rofi
   discard every declaration after it. That is why the wallpaper picker fell
   back to rofi's stock light theme: its `@bg-a` and friends never resolved.
3. Two more in-block comments in `launcher.rasi` and `wallpaper.rasi`, found
   by the checker written for #2.

`install/check-rofi.py` now enforces both rules: no comments inside blocks,
and every `@variable` defined in the generated palette.
