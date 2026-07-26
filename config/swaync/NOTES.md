# swaync notes

`config.json` deliberately contains **no comments**. swaync parses it with a
strict JSON parser that rejects `//` — a single comment stops the daemon from
starting, and you lose notifications with no obvious cause. The explanations
that would otherwise be inline live here instead.

| Setting | Why this value |
| --- | --- |
| `control-center-margin-top: 54` | Clears the bar: 38px height + 8px top margin + 8px breathing room, so popups never overlap Waybar. |
| `timeout: 8` / `timeout-low: 4` | Long enough to read, short enough not to linger. |
| `timeout-critical: 0` | Never auto-dismiss. Critical notifications are the ones you must not miss — that's the whole point of the priority. |
| `layer: "overlay"` | Draws above fullscreen windows. Use `"top"` instead if you'd rather notifications stay out of the way during video. |
| `backlight.device: "intel_backlight"` | The Arrow Lake iGPU's backlight device. Verify with `ls /sys/class/backlight/` — if it's named something else the slider silently does nothing. |
| `widgets` order | Title and do-not-disturb at the top, then media controls, then sliders, then the notification list. |

Toggle the centre with **SUPER+N**, do-not-disturb with **SUPER+SHIFT+N**.

Check it's alive:

```bash
notify-send "Test" "If you can see this, swaync is running"
swaync-client -R   # reload config
swaync-client -rs  # reload css
```
