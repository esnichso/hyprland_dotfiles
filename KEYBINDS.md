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
| `SUPER` + `M` | Power menu (hyprshutdown) |
| `SUPER` + `L` | Lock the screen |

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
| `SUPER` + `H` `J` `K` `Ö` | Move focus left / down / up / right |
| `SUPER` + arrows | Same |
| `SUPER` + `SHIFT` + `H J K L` / arrows | Move the window |
| `SUPER` + `CTRL` + `H J K L` / arrows | Resize, hold to continue |
| `SUPER` + `ALT` + `R` | Resize mode — then arrows or hjkl, `Esc` to leave |
| `SUPER` + drag with left mouse | Move window from anywhere inside it |
| `SUPER` + drag with right mouse | Resize window from anywhere inside it |

> Focus-right sits on `Ö` rather than `L`, because `SUPER`+`L` locks the screen.
> On the German layout `Ö` is the key immediately right of `L`, so the hjkl row
> stays physically contiguous. Arrow keys are unaffected.

## Workspaces

| Keys | Action |
| --- | --- |
| `SUPER` + `1`–`0` | Go to workspace 1–10 |
| `SUPER` + `SHIFT` + `1`–`0` | Send window to workspace 1–10 |
| `SUPER` + `,` / `.` | Previous / next used workspace |
| `SUPER` + scroll | Same |
| `SUPER` + `S` | Toggle the scratchpad |
| `SUPER` + `SHIFT` + `S` | Send window to the scratchpad |

## Screenshots and clipboard

| Keys | Action |
| --- | --- |
| `Print` | Select a region → annotate in satty |
| `SHIFT` + `Print` | Whole screen → annotate in satty |
| `SUPER` + `Print` | Select a region → straight to clipboard |
| `SUPER` + `SHIFT` + `V` | Clipboard history |
| `SUPER` + `SHIFT` + `C` | Colour picker → hex to clipboard |

In satty: `Ctrl`+`C` copies, `Ctrl`+`S` saves to `~/Pictures/Screenshots`.

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

`R` and `M` match this config on purpose. `Q` does not — here it closes a
window, since that's the far more frequent action. If the config is broken,
`SUPER`+`Q` reverts to opening a terminal, which is what you need at that point.

Stuck in a submap with no working keys? Switch to a TTY with `Ctrl`+`Alt`+`F2`:

```bash
hyprctl dispatch 'hl.dsp.submap("reset")'
```
