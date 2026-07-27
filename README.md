# hypersetup

A hand-written Hyprland desktop for CachyOS on a ThinkPad E16 Gen 3. No forked
dotfiles — every line is written for this machine and commented so it can be
maintained rather than copied.

## Where to start

| File | What it is |
| --- | --- |
| [PACKAGES.md](PACKAGES.md) | What gets installed and why. Names and versions verified against live Arch/AUR APIs. |
| [SETUP.md](SETUP.md) | Step-by-step: build here → validate in a VM → install on metal → first-login checklist. |
| [KEYBINDS.md](KEYBINDS.md) | Every keybinding and gesture, in one page. |
| [PLAN.md](PLAN.md) | Fix lists from the VM rounds, and what each change was for. |
| [CLAUDE.md](CLAUDE.md) | How the repo works, the workflow, and the gotchas worth knowing before editing. |
| `config/` | The actual configuration, symlinked into `~/.config`. |
| `install/` | Package lists, `bootstrap.sh`, `link.sh`, `check.sh`, `doctor.sh`, `sddm.sh`, `set-theme.py`. |
| `themes/` | One TOML palette per theme — the single source of colour. |
| `sddm/` | The login screen theme. Not under `config/` — SDDM never reads a home directory. |
| `docs/hyprland/` | Snapshot of the official wiki (38 pages + upstream example config, 2026-07-26). |
| `docs/fastfetch/` | Upstream's JSON schema, so `check.sh` can validate the fastfetch configs offline. |

```
config/
├── hypr/
│   ├── hyprland.lua        entry point — requires the files below
│   ├── conf/
│   │   ├── theme.lua       the Catppuccin palette, in one place
│   │   ├── looks.lua       gaps, borders, blur, shadows, animations
│   │   ├── monitors.lua    displays and scaling
│   │   ├── input.lua       keyboard, touchpad, gestures
│   │   ├── binds.lua       keybindings
│   │   ├── rules.lua       window / workspace / layer rules
│   │   └── autostart.lua   what starts with the session
│   ├── hyprlock.conf       lock screen      (hyprlang, not Lua)
│   ├── hypridle.conf       dim/lock/suspend (hyprlang, not Lua)
│   └── hyprpaper.conf      wallpaper        (hyprlang, not Lua)
├── uwsm/
│   ├── env                 session-wide environment variables
│   └── env-hyprland        Hyprland-only variables (empty by default)
├── kitty/                  font, palette, background_opacity
├── gtk-3.0/, gtk-4.0/      GTK + libadwaita theming
├── qt5ct/, qt6ct/          Qt palette, so Dolphin matches
├── fish/                   shell config + functions/
├── starship.toml           prompt
├── fastfetch/              three layouts, picked by terminal width
├── waybar/                 config.jsonc + style.css
├── rofi/                   launcher + power menu themes
└── swaync/                 config.json + style.css + NOTES.md

sddm/hypersetup/
├── Main.qml                hand-written, contains no colour
├── metadata.desktop        tells SDDM which file to load
└── theme.conf              generated — the palette Main.qml reads
```

`kitty/` is now included — it sets the font, the Catppuccin palette and
`background_opacity`, which is what produces blur behind the terminal. If you
had kitty keybindings on Ubuntu worth keeping, paste them at the end of
`config/kitty/kitty.conf`; `link.sh` backs up whatever was there first.

`~/.config/btop` is still deliberately left alone.

## Colours

One palette file per theme in `themes/`; `install/set-theme.py` renders every
config from it.

```bash
./install/set-theme.py            # list themes
./install/set-theme.py mocha      # apply one
./install/set-theme.py --pick     # choose with rofi  (SUPER+ALT+T)
```

Colour used to be duplicated across 13 files as 341 hex literals. Now it is
generated two ways, depending on what each format supports:

| Mechanism | Used for |
| --- | --- |
| A generated file the real config imports | waybar/swaync CSS (`@import`), kitty (`include`), rofi (`@import`), fish (`source`), hyprlock (`source`) |
| A whole generated file | `kdeglobals` (KDE apps), `gtk-3.0/gtk.css`, `hypr/theme.env` (read by `scripts/theme.sh`), `sddm/hypersetup/theme.conf` — the format has no user half worth preserving |
| A marked region replaced in place | `starship.toml`, `waybar/config.jsonc`, `gtk-3.0/settings.ini`, `qt6ct.conf`, `qt5ct.conf` — no import mechanism exists |

Generated files say so in their header. Edit `themes/*.toml`, never them —
`check.sh` fails if they drift out of sync.

Six themes ship: `mocha`, `macchiato`, `frappe`, `latte`, `tokyo-night` and
`gruvbox`. The last two aren't Catppuccin, which is the point — the slot names
are generic, so any palette organised as "three backgrounds, three surfaces,
three muted foregrounds, three text shades, fourteen accents" drops straight
in. They have no packaged GTK theme, so GTK apps get a recoloured Adwaita
rather than a real theme; everything else is unaffected.

`[roles]` is the part worth knowing about: `accent`, `urgent`, `warning`,
`success` map semantic meaning onto palette entries, and the configs reference
the roles. Changing `accent = "mauve"` to `accent = "teal"` restyles the active
workspace, window borders, launcher selection, prompt arrow and sliders in one
edit.

## Before committing

```bash
./install/check.sh
```

Validates Lua, JSONC, GTK CSS, TOML, every theme, the rofi themes, the fastfetch
configs and the shell scripts, and looks for duplicate keybinds. Two of the
checks use the real parser rather than an approximation: GTK CSS goes through
GTK itself, because GTK rejects an entire stylesheet over one unknown
pseudo-class and the only symptom is an unstyled bar; the fastfetch configs go
through upstream's JSON schema, which catches a misspelled module or format
placeholder that plain JSON validation would wave through.

Both are optional dependencies and both **skip silently** if missing, so green
on a fresh machine does not mean checked: `python-gobject` for the CSS,
`python-jsonschema` for fastfetch.

## Checking a running session

`check.sh` validates files on the dev host. It cannot tell you whether audio,
screensharing or the clipboard actually work — for that, run this **inside the
desktop**:

```bash
./install/doctor.sh
```

It reports on the session, PipeWire, the portals (screenshare and file
pickers), clipboard watchers, the notification daemon, fonts, whether the GTK
theme it's been told to use is installed at all, and hardware video
acceleration. It changes nothing.

## The login screen

The theme is ours: `sddm/hypersetup/`. Blank background in the current
palette, big centred clock, session and power controls in the bottom corners.
No AUR package — an SDDM theme is just a directory with a `Main.qml` and a
`metadata.desktop`.

`Main.qml` is hand-written and contains **no colour at all**. SDDM exposes
every key of a theme's `theme.conf` on a global `config` object, so the palette
arrives the same way it does for the CSS and rofi: a generated file the
hand-written config reads. All six themes work, including Tokyo Night and
Gruvbox, which have no packaged SDDM theme anywhere.

```bash
./install/sddm.sh --dry-run   # show exactly what would be installed
./install/sddm.sh             # install and apply (asks for sudo)
./install/sddm.sh --show      # what's configured now
```

SDDM is the one part of this a theme switch cannot reach. It runs as the
`sddm` system user before you log in, so it never sees `~/.config`, and both
`/etc/sddm.conf.d/` and `/usr/share/sddm/themes/` are root-owned. Every other
file here is written without a password; this one needs one.

**Re-run it after switching themes.** `set-theme.py` regenerates
`sddm/hypersetup/theme.conf`, but getting that into `/usr/share` needs sudo,
so `SUPER+ALT+T` alone leaves the login screen on the old palette.

Preview without logging out — and note that SDDM falls back to its embedded
theme if ours fails to load, so a mistake here is ugly rather than locking:

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/hypersetup
```

## Decisions

| | Choice | Why |
| --- | --- | --- |
| Distro | CachyOS, full-disk | Optimised Arch with sane defaults, Btrfs snapshots for rollback. |
| Base | Minimal, no preset dotfiles | The config is ours from line one. |
| Compositor | Hyprland 0.56 | **Lua config** — 0.55 deprecated hyprlang and 0.56 is past the grace window. |
| Session | uwsm + SDDM | Proper systemd session; portals and user services depend on it. |
| Layout | Dwindle | Predictable binary splits, well documented, good on one 16" panel. |
| Bar | Waybar | JSONC + CSS. Readable, hand-writable, hard to break. |
| Keybinds | hjkl **and** arrows | Same actions on both, so muscle memory can catch up. |
| Terminal | kitty | Catppuccin palette and `background_opacity` for real blur behind text. |
| Look | Catppuccin Mocha, gaps, rounding, blur | Modern dark, moderate animations. |
| Fonts | Inter for UI, JetBrains Mono in the terminal | Proportional text reads better in a bar; mono only where alignment matters. |
| Shell | fish + starship | One TOML prompt config that survives a change of shell. |
| Qt theming | qt6ct + custom palette | No unpackaged Kvantum theme to fetch by hand. |

## The Lua thing

Hyprland 0.55 (May 2026) replaced hyprlang with Lua, and 0.56 is past the
compatibility window. This is not a cosmetic change:

```lua
-- old (hyprlang, dead):
--   windowrule = float, class:^(pavucontrol)$
--   bindm = ALT, mouse:272, movewindow

hl.windowrule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
```

Practical consequence: **essentially every Hyprland tutorial, video and dotfile
repo older than May 2026 is written in a syntax this version no longer reads.**
That is why `docs/hyprland/` exists — the config is written against the current
upstream wiki, not against remembered syntax.

## Hardware this is written for

Lenovo ThinkPad E16 Gen 3 · Intel Core Ultra 7 255H (Arrow Lake-H, **no
AVX-512** → CachyOS **v3** repos, not v4) · Intel Arc iGPU · single eDP-1 panel
at **2560×1600**, scaled 1.6 · German keyboard layout · 30 GB RAM.

## Status

- [x] Research, docs cached, hardware profiled
- [x] Package list and setup guide
- [x] Config written — Lua files parse clean, JSON validated
- [x] Validated in a VM (CachyOS guest, 2026-07-27)
- [ ] Installed on the ThinkPad
