# Keybindings

`SUPER` is the Windows key. Every directional action is bound to **both** hjkl
and the arrow keys — use arrows while hjkl sinks in, then delete the arrow lines
from `config/hypr/conf/binds.lua`.

Live list of everything currently bound, with descriptions: `hyprctl binds`.

## Launching

| Keys | Action |
| --- | --- |
| `SUPER` + `Return` | Terminal (kitty) |
| `SUPER` + `R` | Application launcher (rofi) |
| `SUPER` + `E` | File manager (thunar) |
| `SUPER` + `M` | Power menu — lock / logout / suspend / reboot / shutdown |
| `SUPER` + `Escape` | Lock the screen |
| `SUPER` + `W` | Random wallpaper |

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
| `SUPER` + `` ` `` | Jump to last or urgent window |

## Groups (tabs)

| Keys | Action |
| --- | --- |
| `SUPER` + `G` | Group / ungroup — stacks windows into one tabbed slot |
| `SUPER` + `SHIFT` + `G` | Move window out of the group |
| `SUPER` + `[` / `]` | Previous / next tab |

## Focus, move, resize

| Keys | Action |
| --- | --- |
| `SUPER` + `H` `J` `K` `L` | Move focus left / down / up / right |
| `SUPER` + arrows | Same |
| `SUPER` + `SHIFT` + `H J K L` / arrows | Move the window |
| `SUPER` + `CTRL` + `H J K L` / arrows | Resize, hold to continue |
| `SUPER` + `ALT` + `R` | Resize mode — then arrows or hjkl, `Esc` to leave |
| `SUPER` + drag with left mouse | Move window from anywhere inside it |
| `SUPER` + drag with right mouse | Resize window from anywhere inside it |

>  `hjkl` is unbroken — the lock bind moved to `SUPER`+`Escape` so `L` stays
> where vim muscle memory expects it. Since Caps Lock is remapped to Escape,
> locking is a home-row reach.

## Workspaces

| Keys | Action |
| --- | --- |
| `SUPER` + `1`–`0` | Go to workspace 1–10 |
| `SUPER` + `SHIFT` + `1`–`0` | Send window to workspace 1–10 |
| `SUPER` + `,` / `.` | Previous / next used workspace |
| `SUPER` + scroll | Same |
| `SUPER` + `S` | Toggle the scratchpad |
| `SUPER` + `ALT` + `S` | Send window to the scratchpad |

## Screenshots and clipboard

This keyboard has no Print key, so the primary binds are on `SUPER`+`SHIFT`.
The `Print` variants still work if you dock a keyboard that has one.

| Keys | Action |
| --- | --- |
| `SUPER` + `SHIFT` + `S` | Select a region → annotate in satty |
| `SUPER` + `SHIFT` + `D` | Whole screen → annotate in satty |
| `SUPER` + `SHIFT` + `A` | Select a region → straight to clipboard |
| `SUPER` + `SHIFT` + `C` | Colour picker → hex to clipboard |

In satty: `Ctrl`+`C` copies, `Ctrl`+`S` saves to `~/Pictures/Screenshots`.

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

## Hardware keys

Volume, brightness, mute and media keys all work as labelled, and keep working
**while the screen is locked** so you can mute a meeting without unlocking.
Volume and brightness show an on-screen popup and repeat when held.

## Trackpad gestures

| Gesture | Action |
| --- | --- |
| 3 fingers left / right | Move between workspaces, following your fingers |
| 3 fingers up | Fullscreen the focused window |
| 4 fingers down | Toggle the scratchpad |
| 2-finger pinch | Zoom the screen around the cursor |

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

## Wallpapers

Drop images into `~/Pictures/wallpapers/`. `SUPER+W` opens a grid of
thumbnails; pick one and it is applied immediately and remembered across
reboots. Nothing ever changes on its own.

| Keys | Action |
| --- | --- |
| `SUPER` + `W` | Pick a wallpaper — rofi grid of thumbnails |
| `SUPER` + `SHIFT` + `W` | Jump to a random one |
| `SUPER` + `ALT` + `T` | Change the colour theme |

From the shell:

```bash
~/.config/hypr/scripts/wallpaper.sh pick        # rofi grid
~/.config/hypr/scripts/wallpaper.sh random
~/.config/hypr/scripts/wallpaper.sh set ~/pic.jpg
~/.config/hypr/scripts/wallpaper.sh current
```

The choice lives in `~/.local/state/hypr/wallpaper`, not in the repo, so
changing wallpaper never leaves you with a dirty git tree.

## Colours

`SUPER+ALT+T` picks a theme and reloads everything live. From the shell:

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
