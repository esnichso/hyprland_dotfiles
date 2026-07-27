# Keybindings

Everything bound anywhere in this desktop: the compositor, the terminal, the
shell, the launcher, the lock screen and the screenshot tool.

`SUPER` is the Windows key. **Caps Lock is Escape** (`input.lua`, `caps:escape`)
— the original Escape still works too.

Every directional action is bound to **both** hjkl and the arrow keys — use
arrows while hjkl sinks in, then delete the arrow lines from
`config/hypr/conf/binds.lua`.

Where each layer's live list comes from:

| Layer | Command |
| --- | --- |
| Hyprland | `hyprctl binds` |
| kitty | `Ctrl`+`Shift`+`F6` (dumps the running config, mappings included) |
| fish | `bind` |
| rofi | `rofi -show drun -dump-config` |

---

# Desktop (Hyprland)

## Launching

| Keys | Action |
| --- | --- |
| `SUPER` + `Return` | Terminal (kitty) |
| `SUPER` + `R` | Application launcher (rofi) |
| `SUPER` + `E` | File manager (thunar) |
| `SUPER` + `M` | Power menu — lock / logout / suspend / reboot / shutdown |
| `SUPER` + `Escape` | Lock the screen |
| `XF86Favorites` | Application launcher — the star key some ThinkPads have |

## Windows

| Keys | Action |
| --- | --- |
| `SUPER` + `Q` | Close window |
| `SUPER` + `SHIFT` + `Q` | Force kill (when an app stops responding) |
| `SUPER` + `V` | Toggle floating |
| `SUPER` + `F` | Fullscreen |
| `SUPER` + `SHIFT` + `F` | Maximise — keeps the bar and gaps |
| `SUPER` + `C` | Centre a floating window |
| `SUPER` + `T` | Flip the split direction |
| `SUPER` + `P` | Pseudotile |
| `SUPER` + `SHIFT` + `P` | Pin above all workspaces |
| `SUPER` + `Tab` | Next window on this workspace |
| `SUPER` + `SHIFT` + `Tab` | Previous window on this workspace |
| `SUPER` + `` ` `` | Jump to last or urgent window |

## Groups (tabs)

| Keys | Action |
| --- | --- |
| `SUPER` + `G` | Group / ungroup — stacks windows into one tabbed slot |
| `SUPER` + `SHIFT` + `G` | Move window out of the group |
| `SUPER` + `[` / `]` | Previous / next tab |

> **On the German layout `[` and `]` are `AltGr`+`8` / `AltGr`+`9`**, and
> `` ` `` is a dead key on `Shift`+`´`. All three binds use the keysym, so
> they technically work, but they are awkward one-handed. If you use groups
> often, remap them in `binds.lua` — `SUPER`+`Y`/`X` or the `<`/`>` key next
> to left Shift are all free.

## Focus, move, resize

| Keys | Action |
| --- | --- |
| `SUPER` + `H` `J` `K` `L` | Move focus left / down / up / right |
| `SUPER` + arrows | Same |
| `SUPER` + `SHIFT` + `H J K L` / arrows | Move the window |
| `SUPER` + `CTRL` + `H J K L` / arrows | Resize, hold to continue |
| `SUPER` + `ALT` + `R` | Resize mode — then arrows or hjkl, `Esc` or `Return` to leave |
| `SUPER` + drag with left mouse | Move window from anywhere inside it |
| `SUPER` + drag with right mouse | Resize window from anywhere inside it |

> `hjkl` is unbroken — the lock bind moved to `SUPER`+`Escape` so `L` stays
> where vim muscle memory expects it. Since Caps Lock is Escape, locking is a
> home-row reach.

## Workspaces

| Keys | Action |
| --- | --- |
| `SUPER` + `1`–`0` | Go to workspace 1–10 |
| `SUPER` + `SHIFT` + `1`–`0` | Send window to workspace 1–10 |
| `SUPER` + `,` / `.` | Previous / next **used** workspace — skips empty ones |
| `SUPER` + scroll | Same |
| `SUPER` + `S` | Toggle the scratchpad |
| `SUPER` + `ALT` + `S` | Send window to the scratchpad |

The bar always shows workspaces 1–3, dimmed when empty. Anything beyond 3
appears when it has a window and disappears when it empties.

## Screenshots

This keyboard has no Print key, so the primary binds are on `SUPER`+`SHIFT`.
The `Print` variants still work if you dock a keyboard that has one.

| Keys | Action |
| --- | --- |
| `SUPER` + `SHIFT` + `S` | Select a region → annotate in satty |
| `SUPER` + `SHIFT` + `D` | Whole screen → annotate in satty |
| `SUPER` + `SHIFT` + `A` | Select a region → straight to clipboard, no UI |
| `SUPER` + `SHIFT` + `C` | Colour picker → hex to clipboard |
| `Print` | Region → satty |
| `SHIFT` + `Print` | Whole screen → satty |
| `SUPER` + `Print` | Region → clipboard |

## Clipboard, emoji, calculator

| Keys | Action |
| --- | --- |
| `SUPER` + `SHIFT` + `V` | Clipboard history — everything you've copied |
| `SUPER` + `ALT` + `V` | Clear the clipboard history |
| `SUPER` + `ALT` + `E` | Emoji picker → copies to clipboard |
| `SUPER` + `ALT` + `C` | Calculator — type an expression, Return copies the result |

The clipboard history is recorded by `cliphist`, started from `autostart.lua`.
It survives closing the app you copied from, which plain Wayland does not:
`wl-clip-persist` holds the contents. It also persists across reboots, so
**clear it after copying a password** — that's what `SUPER`+`ALT`+`V` is for.

The emoji picker copies rather than types. Typing needs synthetic key events,
which Electron apps frequently ignore; pasting always works.

## Notifications and session

| Keys | Action |
| --- | --- |
| `SUPER` + `N` | Notification centre |
| `SUPER` + `SHIFT` + `N` | Do not disturb |
| `SUPER` + `SHIFT` + `R` | Reload the Hyprland config |
| `SUPER` + `SHIFT` + `B` | Restart the bar |
| `SUPER` + `SHIFT` + `X` | Toggle blur — the biggest single battery saving |

## Wallpaper and theme

| Keys | Action |
| --- | --- |
| `SUPER` + `W` | Pick a wallpaper — rofi grid of thumbnails |
| `SUPER` + `SHIFT` + `W` | Jump to a random one |
| `SUPER` + `ALT` + `T` | Change the colour theme |

## Hardware keys

Volume, brightness, mute and media keys all work as labelled. They keep working
**while the screen is locked**, so you can mute a meeting without unlocking.
Volume and brightness show an on-screen popup and repeat when held.

| Key | Action |
| --- | --- |
| `XF86AudioRaiseVolume` / `LowerVolume` | Volume, with OSD |
| `XF86AudioMute` | Mute output |
| `XF86AudioMicMute` | Mute microphone |
| `XF86MonBrightnessUp` / `Down` | Backlight, with OSD |
| `XF86AudioPlay` / `Pause` | Play / pause (anything MPRIS-aware) |
| `XF86AudioNext` / `Prev` | Track forward / back |

## Trackpad gestures

| Gesture | Action |
| --- | --- |
| 3 fingers left / right | Move between workspaces, following your fingers |
| 3 fingers up | Fullscreen the focused window |
| 4 fingers down | Toggle the scratchpad |
| 2-finger pinch | Zoom the screen around the cursor |

Tap with 1 / 2 / 3 fingers is left / right / middle click. Scrolling is natural
(content follows your fingers), and the pad is disabled while you type.

## Emergency binds

Hyprland hardcodes three binds that work even if the config fails to load:

| Keys | Action |
| --- | --- |
| `SUPER` + `Q` | Terminal |
| `SUPER` + `R` | Launcher |
| `SUPER` + `M` | Exit Hyprland |

Note `SUPER`+`M` here means Hyprland's built-in *exit*, not the power menu —
that only applies when the config has failed to load.

`R` and `M` match this config on purpose. `Q` does not — here it closes a
window, since that's the far more frequent action. If the config is broken,
`SUPER`+`Q` reverts to opening a terminal, which is what you need at that point.

Stuck in a submap with no working keys? Switch to a TTY with `Ctrl`+`Alt`+`F2`:

```bash
hyprctl dispatch 'hl.dsp.submap("reset")'
```

---

# Terminal (kitty)

`config/kitty/kitty.conf` sets **appearance only** — every binding below is
kitty's own default. `kitty_mod` is `Ctrl`+`Shift`, written out here.

None of these collide with the desktop binds: Hyprland uses `SUPER`
throughout, kitty uses `Ctrl`+`Shift`.

## Clipboard and selection

| Keys | Action |
| --- | --- |
| `Ctrl`+`Shift`+`C` | Copy to clipboard |
| `Ctrl`+`Shift`+`V` | Paste from clipboard |
| `Ctrl`+`Shift`+`S` | Paste from primary selection |
| `Shift`+`Insert` | Paste from primary selection |
| `Ctrl`+`Shift`+`O` | Pass the selection to a program |

## Scrollback

| Keys | Action |
| --- | --- |
| `Ctrl`+`Shift`+`↑` / `↓` | Scroll one line |
| `Ctrl`+`Shift`+`K` / `J` | Scroll one line |
| `Ctrl`+`Shift`+`PageUp` / `PageDown` | Scroll one page |
| `Ctrl`+`Shift`+`Home` / `End` | Scroll to top / bottom |
| `Ctrl`+`Shift`+`Z` / `X` | Jump to previous / next shell prompt |
| `Ctrl`+`Shift`+`H` | Open the whole scrollback in a pager |
| `Ctrl`+`Shift`+`G` | Open the last command's output in a pager |
| `Ctrl`+`Shift`+`/` | Search the scrollback in a pager |

The prompt-jumping and last-command bindings need kitty's shell integration,
which is on by default and works with fish out of the box.

## Windows (splits inside one kitty)

| Keys | Action |
| --- | --- |
| `Ctrl`+`Shift`+`Return` | New window |
| `Ctrl`+`Shift`+`N` | New OS window |
| `Ctrl`+`Shift`+`W` | Close window |
| `Ctrl`+`Shift`+`]` / `[` | Next / previous window |
| `Ctrl`+`Shift`+`F` / `B` | Move window forward / backward |
| `Ctrl`+`Shift`+`` ` `` | Move window to the top |
| `Ctrl`+`Shift`+`R` | Start resizing the window |
| `Ctrl`+`Shift`+`1`–`0` | Jump to window 1–10 |
| `Ctrl`+`Shift`+`F7` | Visually select and focus a window |
| `Ctrl`+`Shift`+`F8` | Visually swap two windows |

> Hyprland already tiles, so these are mostly redundant here — but they're
> worth knowing when you're inside one full-screen kitty.

## Tabs

| Keys | Action |
| --- | --- |
| `Ctrl`+`Shift`+`T` | New tab |
| `Ctrl`+`Shift`+`Q` | Close tab |
| `Ctrl`+`Shift`+`→` / `←` | Next / previous tab |
| `Ctrl`+`Tab` / `Ctrl`+`Shift`+`Tab` | Next / previous tab |
| `Ctrl`+`Shift`+`.` / `,` | Move tab forward / backward |
| `Ctrl`+`Shift`+`Alt`+`T` | Set tab title |
| `Ctrl`+`Shift`+`L` | Next layout |

## Font size

| Keys | Action |
| --- | --- |
| `Ctrl`+`Shift`+`+` / `=` | Larger |
| `Ctrl`+`Shift`+`-` | Smaller |
| `Ctrl`+`Shift`+`Backspace` | Back to 11pt |

## Transparency

These work because `dynamic_background_opacity yes` is set in `kitty.conf`.
Press `Ctrl`+`Shift`+`A`, release, then the second key.

| Keys | Action |
| --- | --- |
| `Ctrl`+`Shift`+`A` then `M` | More opaque |
| `Ctrl`+`Shift`+`A` then `L` | More transparent |
| `Ctrl`+`Shift`+`A` then `1` | Fully opaque |
| `Ctrl`+`Shift`+`A` then `D` | Back to the configured 0.85 |

## Picking text out of the screen

`Ctrl`+`Shift`+`P`, release, then the second key. Every one of these overlays
the screen with hint labels; type a label to pick it.

| Keys | Action |
| --- | --- |
| `Ctrl`+`Shift`+`E` | Pick a URL and open it |
| `Ctrl`+`Shift`+`P` then `F` | Insert a path from the screen |
| `Ctrl`+`Shift`+`P` then `Shift`+`F` | Open a path from the screen |
| `Ctrl`+`Shift`+`P` then `C` | Insert a chosen file |
| `Ctrl`+`Shift`+`P` then `D` | Insert a chosen directory |
| `Ctrl`+`Shift`+`P` then `L` | Insert a whole line |
| `Ctrl`+`Shift`+`P` then `W` | Insert a word |
| `Ctrl`+`Shift`+`P` then `H` | Insert a hash (git SHAs) |
| `Ctrl`+`Shift`+`P` then `N` | Open a file at the line number shown |
| `Ctrl`+`Shift`+`P` then `Y` | Open a hyperlink |

`Ctrl`+`Shift`+`P` then `H` on a git log is the fastest way to grab a commit
hash without touching the mouse.

## Miscellaneous

| Keys | Action |
| --- | --- |
| `Ctrl`+`Shift`+`U` | Unicode input — search by character name |
| `Ctrl`+`Shift`+`F11` | Toggle fullscreen |
| `Ctrl`+`Shift`+`F10` | Toggle maximised |
| `Ctrl`+`Shift`+`Delete` | Reset the terminal |
| `Ctrl`+`Shift`+`Escape` | kitty's own command shell |
| `Ctrl`+`Shift`+`F1` | kitty documentation |
| `Ctrl`+`Shift`+`F2` | Edit `kitty.conf` |
| `Ctrl`+`Shift`+`F3` | Command palette — search every action by name |
| `Ctrl`+`Shift`+`F5` | Reload `kitty.conf` |
| `Ctrl`+`Shift`+`F6` | Dump the running config, mappings included |

> There is no `kitty --debug-config` command line flag. `Ctrl`+`Shift`+`F6`
> is how you inspect the running configuration.

---

# Shell (fish)

fish's defaults, plus the tools wired up in `config/fish/config.fish`. All
integrations are guarded by `type -q`, so a missing tool costs you the binding
and nothing else.

## Completion and history

| Keys | Action |
| --- | --- |
| `Tab` | Complete the current token |
| `Shift`+`Tab` | Complete, and open the pager in search mode |
| `↑` / `↓` | Search history for commands containing what you've typed |
| `Alt`+`↑` / `Alt`+`↓` | Search history for the *token* under the cursor |
| `→` or `Ctrl`+`F` | Accept the whole autosuggestion |
| `Alt`+`→` or `Alt`+`F` | Accept one word of the autosuggestion |

## fzf

From `fzf --fish`, which fzf has shipped itself since 0.48 — no plugin manager
involved. `fd` feeds the file walk, so `.gitignore` is respected and `.git` is
skipped.

| Keys | Action |
| --- | --- |
| `Ctrl`+`R` | Fuzzy search shell history |
| `Ctrl`+`T` | Fuzzy-pick a file path and insert it |
| `Alt`+`C` | Fuzzy-pick a directory and cd into it |

## Editing

| Keys | Action |
| --- | --- |
| `Ctrl`+`C` | Interrupt what's running |
| `Ctrl`+`D` | Delete right, or exit fish on an empty line |
| `Ctrl`+`U` | Cut from the start of the line to the cursor |
| `Ctrl`+`K` | Cut from the cursor to the end of the line |
| `Ctrl`+`W` | Cut the previous path component |
| `Ctrl`+`L` | Repaint the screen, keeping scrollback |
| `Alt`+`E` or `Alt`+`V` | Edit the command line in `$EDITOR` |
| `Alt`+`S` | Prepend `sudo` |

## Asking questions without losing the line

| Keys | Action |
| --- | --- |
| `Alt`+`L` | List the current directory |
| `Alt`+`D` | List directory history (or cut the next word) |
| `Alt`+`P` | Append `&| less;` to the job under the cursor |
| `Alt`+`W` | One-line description of the command under the cursor |
| `Alt`+`H` | Open the man page for the command under the cursor |

## Commands worth knowing

| Command | What it is |
| --- | --- |
| `ls` `ll` `la` `lt` | eza — directories first, git status, `lt` is a two-level tree |
| `z <part-of-a-path>` | zoxide — jump to the matching directory you use most |
| `zi` | zoxide, interactive |
| `bat file` | cat with syntax highlighting; also the `MANPAGER` |
| `gs gd ga gc gp gl` | git status / diff / add / commit / push / log |
| `pi pr pu ps-` | pacman install / remove / update / search |
| `hr hc hm` | `hyprctl` reload / clients / monitors |
| `..` `...` | Up one or two directories |

`cd` is deliberately left alone — a `cd` that guesses is surprising in scripts
and over SSH. Use `z` when you want the guessing.

---

# Launcher (rofi)

Applies to the app launcher, the power menu, the theme picker, the wallpaper
grid, the clipboard history, the emoji picker and the calculator — they are all
rofi.

| Keys | Action |
| --- | --- |
| Type | Filter, fuzzy |
| `↑` / `↓` or `Ctrl`+`P` / `Ctrl`+`N` | Move the selection |
| `Return` or `Ctrl`+`J` / `Ctrl`+`M` | Launch / accept |
| `Shift`+`Return` | Accept alternately — for `drun`, run in a terminal |
| `Escape` or `SUPER`+`R` | Cancel |
| `Ctrl`+`G` or `Ctrl`+`[` | Cancel |
| `Shift`+`→` or `Ctrl`+`Tab` | Next mode |
| `Shift`+`←` or `Ctrl`+`Shift`+`Tab` | Previous mode |
| `Ctrl`+`K` | Delete from the cursor to the end of the input |
| `Shift`+`Delete` | Delete the selected entry from history |

`SUPER`+`R` closing the launcher is set by `kb-cancel` in `config.rasi`, so the
key that opened it also closes it.

> rofi also ships `kb-select-1`…`kb-select-10` on `SUPER`+`1`…`0`, to jump
> straight to the nth entry. **They never fire here** — Hyprland grabs
> `SUPER`+number for workspace switching before rofi sees it. Rebind them in
> `config.rasi` if you want them; `Alt`+number is free.

---

# Lock screen (hyprlock)

Type your password and press `Return`. There's no other UI.

- Any keypress wakes the display and shows the input field.
- `Escape` clears what you've typed.
- Volume, brightness and media keys keep working while locked — that's the
  `locked = true` flag on those binds.

If hyprlock ever fails to start and leaves you locked out with no lock screen,
switch to a TTY with `Ctrl`+`Alt`+`F2` and run:

```bash
hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'
```

---

# Screenshot annotator (satty)

| Keys | Action |
| --- | --- |
| `Ctrl`+`C` | Copy the annotated image to the clipboard |
| `Ctrl`+`S` | Save to `~/Pictures/Screenshots` |
| `Ctrl`+`Z` | Undo |
| `Escape` | Discard and close |

Tools (arrow, rectangle, text, blur, highlight) are on the toolbar; the
current tool follows the mouse.

---

# Wallpapers

Drop images into `~/Pictures/wallpapers/`. `SUPER`+`W` opens a grid of
thumbnails; pick one and it is applied immediately and remembered across
reboots. **Nothing ever changes on its own.**

From the shell:

```bash
~/.config/hypr/scripts/wallpaper.sh pick        # rofi grid
~/.config/hypr/scripts/wallpaper.sh random
~/.config/hypr/scripts/wallpaper.sh set ~/pic.jpg
~/.config/hypr/scripts/wallpaper.sh current
```

The choice lives in `~/.local/state/hypr/wallpaper`, not in the repo, so
changing wallpaper never leaves you with a dirty git tree.

# Colours

`SUPER`+`ALT`+`T` picks a theme and reloads everything live. From the shell:

```bash
./install/set-theme.py            # list
./install/set-theme.py latte      # apply
```

One palette file per theme in `themes/`. Editing `accent` there restyles the
active workspace, window borders, launcher selection, prompt and sliders
together — see the Colours section of README.md.

Six themes ship: `mocha`, `macchiato`, `frappe` and `latte` (Catppuccin, dark
to light), plus `tokyo-night` and `gruvbox`.

Two things do **not** change live, whatever the picker does:

- **Running GTK apps.** GTK reads its theme name once, at startup. Restart the
  app, or log out.
- **Running Qt and KDE apps.** Same reason.

Everything else — the bar, rofi, notifications, kitty, the lock screen, fish —
updates without a restart.
