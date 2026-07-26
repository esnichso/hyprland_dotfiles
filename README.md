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
| [PLAN.md](PLAN.md) | Round-2 fix list from the VM run, and what each change was for. |
| `config/` | The actual configuration, symlinked into `~/.config`. |
| `install/` | Package lists, `bootstrap.sh`, `link.sh`, `check.sh`. |
| `docs/hyprland/` | Snapshot of the official wiki (38 pages + upstream example config, 2026-07-26). |

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
├── fish/                   shell config
├── starship.toml           prompt
├── waybar/                 config.jsonc + style.css
├── rofi/                   launcher + power menu themes
└── swaync/                 config.json + style.css + NOTES.md
```

`kitty/` is now included — it sets the font, the Catppuccin palette and
`background_opacity`, which is what produces blur behind the terminal. If you
had kitty keybindings on Ubuntu worth keeping, paste them at the end of
`config/kitty/kitty.conf`; `link.sh` backs up whatever was there first.

`~/.config/btop` is still deliberately left alone.

## Before committing

```bash
./install/check.sh
```

Validates Lua, JSONC, GTK CSS, TOML and the shell scripts, and looks for
duplicate keybinds. The CSS check uses GTK's own parser — worth having, because
GTK rejects an entire stylesheet over one unknown pseudo-class and the only
symptom is an unstyled bar.

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
