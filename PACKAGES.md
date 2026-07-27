# Package list — CachyOS + Hyprland on ThinkPad E16 Gen 3

Every package below was checked against the live Arch and AUR APIs on **2026-07-26**.
Repo and version are recorded so you can spot drift later. CachyOS mirrors `extra`
into `cachyos-extra-v3` with the same package names, so `pacman -S <name>` works
identically — you just get the optimised build.

**Target hardware:** Lenovo ThinkPad E16 Gen 3 · Intel Core Ultra 7 255H (Arrow Lake-H)
· Intel Arc iGPU · single eDP-1 panel · 30 GB RAM.

> **Microarchitecture level:** this CPU supports `x86-64-v3` but **not** `x86-64-v4`
> (Arrow Lake dropped AVX-512 — verified on your machine: `avx2`, `avx_vnni`, no `avx512*`).
> Let CachyOS auto-detect, and confirm it picked the **v3** repos, not v4.

---

## 1. Core session — required

Without these Hyprland either won't start or will be subtly broken (no screenshare,
no file pickers, no password prompts, freezing apps).

| Package | Repo | Version | Why |
| --- | --- | --- | --- |
| `hyprland` | extra | 0.56.0 | The compositor. 0.56 is **Lua-only config** — see note below. |
| `uwsm` | extra | 0.26.6 | Wraps Hyprland in proper systemd units: env, XDG autostart, clean shutdown. Portals want this. |
| `libnewt` | extra | 0.52.25 | uwsm's session picker TUI. |
| `xdg-desktop-portal-hyprland` | extra | 1.4.0 | Screensharing, global shortcuts, screenshot API. |
| `xdg-desktop-portal-gtk` | extra | 1.15.3 | **Required alongside XDPH** — XDPH has no file picker of its own. |
| `qt5-wayland` | extra | 5.15.19 | Qt apps run native Wayland instead of XWayland. |
| `qt6-wayland` | extra | 6.11.1 | Same; XDPH's share picker crashes without it. |
| `polkit` | extra | 127 | Privilege escalation framework. |
| `hyprpolkitagent` | extra | 0.1.3 | The GUI that actually asks for your password. Nothing prompts without an agent. |
| `hyprland-guiutils` | extra | 0.2.2 | Hyprland's own dialogs (version popups, error toasts). Successor to `hyprland-qtutils`, which no longer exists. |
| `xorg-xwayland` | extra | 24.1.13 | X11 app compatibility. |
| `pipewire` | extra | 1.6.8 | Audio server. |
| `pipewire-alsa` | extra | 1.6.8 | ALSA compatibility. |
| `pipewire-pulse` | extra | 1.6.8 | PulseAudio compatibility — most apps speak this. |
| `pipewire-jack` | extra | 1.6.8 | JACK compatibility. |
| `wireplumber` | extra | 0.5.15 | PipeWire session manager. **Not** `pipewire-media-session` (deprecated). |
| `sddm` | extra | 0.21.0 | Display manager. ≥0.20 avoids the 90s-shutdown bug; the Hyprland wiki rates it "works flawlessly". |
| `catppuccin-sddm-theme-*` | AUR | 1.1.2 | Login screen. One package per flavour, each shipping all 14 accent variants. Applied by `install/sddm.sh`. |
| `xdg-user-dirs` | extra | 0.20 | Creates ~/Downloads, ~/Pictures etc. that other tools assume exist. |
| `gnome-keyring` | extra | 50.0 | Secret storage — SSH keys, app logins. |
| `libsecret` | core | 0.21.7 | Client library for the above. |

> **Config format:** 0.55 moved config to Lua (`~/.config/hypr/hyprland.lua`) and 0.56
> is past the hyprlang grace window. Every tutorial and dotfile repo older than
> May 2026 is written in the dead syntax. Our config is Lua from line one.

## 2. Desktop shell — the parts a DE would have given you

| Package | Repo | Version | Why |
| --- | --- | --- | --- |
| `waybar` | extra | 0.15.0 | Status bar. JSONC + CSS, so every module is hand-written and readable. |
| `rofi` | extra | 2.0.0 | App launcher / power menu / clipboard picker. **Note:** `rofi-wayland` is gone — upstream `rofi` has been Wayland-native since 2025. |
| `swaync` | extra | 0.12.6 | Notification daemon **and** a slide-out notification centre with a Waybar toggle. Many apps (Discord) freeze with no daemon running at all. |
| `hyprlock` | extra | 0.9.6 | Lock screen. |
| `hypridle` | extra | 0.1.8 | Idle daemon — dims, locks, suspends. Essential on a laptop. |
| `hyprpaper` | extra | 0.8.4 | Wallpaper daemon, first-party, IPC-controllable. |
| `hyprshutdown` | extra | 0.1.1 | First-party logout/reboot/shutdown dialog. Replaces the AUR-only `wlogout`. |
| `swayosd` | extra | 0.3.1 | On-screen popups for volume/brightness/caps-lock. The thing you miss immediately coming from GNOME. |

## 3. Laptop hardware — ThinkPad + Arrow Lake specifics

| Package | Repo | Version | Why |
| --- | --- | --- | --- |
| `mesa` | extra | 26.1.5 | Graphics drivers. |
| `vulkan-intel` | extra | 26.1.5 | Vulkan on the Arc iGPU. |
| `intel-media-driver` | extra | 26.1.5 | VA-API hardware video decode — matters a lot for battery while watching video. |
| `libva-utils` | extra | 2.24.0 | `vainfo`, to verify the above actually works. |
| `sof-firmware` | extra | 2025.12.2 | **Do not skip.** Modern ThinkPad audio is silent without SOF firmware. |
| `brightnessctl` | extra | 0.5.1 | Backlight control for the Fn keys. |
| `power-profiles-daemon` | extra | 0.30 | Power/balanced/performance switching, with a Waybar module. Conflicts with `tlp` — pick one. |
| `upower` | extra | 1.91.3 | Battery state for the bar and hypridle. |
| `networkmanager` | extra | 1.58.0 | Networking (CachyOS default). |
| `network-manager-applet` | extra | 1.36.0 | Provides `nm-connection-editor` for Wi-Fi/VPN dialogs. |
| `bluez` | extra | 5.87 | Bluetooth stack. |
| `bluez-utils` | extra | 5.87 | `bluetoothctl`. |
| `blueman` | extra | 2.4.6 | Bluetooth GUI. |

**Optional, hardware-dependent:**

| Package | Repo | Version | Why |
| --- | --- | --- | --- |
| `thermald` | extra | 2.5.12 | Intel thermal management. CachyOS recommends it for power saving on Intel. |
| `fprintd` | extra | 1.94.5 | Fingerprint reader — only if your E16 has one (check `lsusb` for a Goodix/Synaptics sensor). |

## 4. Utilities — the small tools the keybinds call

| Package | Repo | Version | Why |
| --- | --- | --- | --- |
| `grim` | extra | 1.5.0 | Screenshot capture. |
| `slurp` | extra | 1.5.0 | Region selection. |
| `satty` | extra | 0.21.1 | Modern annotation UI for screenshots (swappy successor). |
| `wl-clipboard` | extra | 2.3.0 | `wl-copy` / `wl-paste`. |
| `cliphist` | extra | 0.7.0 | Clipboard history, browsable through rofi. |
| `wl-clip-persist` | extra | 0.5.0 | Keeps clipboard contents after the source app closes — Wayland drops them otherwise. |
| `wf-recorder` | extra | 0.6.0 | Screen recording. |
| `playerctl` | extra | 2.4.1 | Media keys + Waybar now-playing. |
| `pamixer` | extra | 1.6 | CLI volume control for keybinds. |
| `pavucontrol` | extra | 6.2 | Audio GUI — per-app volume, device switching. |
| `hyprpicker` | extra | 0.4.7 | Colour picker. |
| `hyprsunset` | extra | 0.4.0 | Night-light / blue-light filter. |
| `thunar` | extra | 4.20.9 | File manager. Light and GTK-native. |
| `thunar-volman` | extra | 4.20.0 | Removable device handling in Thunar. |
| `tumbler` | extra | 4.20.1 | Thumbnails. |
| `ffmpegthumbnailer` | extra | 2.3.0 | Video thumbnails. |
| `gvfs` | extra | 1.60.1 | Trash, MTP, network mounts. |
| `udiskie` | extra | 2.6.2 | Auto-mounts USB drives (no DE to do it for you). |
| `wev` | extra | 1.1.0 | Prints keysyms — how you debug a keybind that won't fire. |

## 5. Fonts and theming

| Package | Repo | Version | Why |
| --- | --- | --- | --- |
| `ttf-jetbrains-mono-nerd` | extra | 3.4.0 | Terminal font, with the Nerd Font icon glyphs the bar falls back to. |
| `inter-font` | extra | 4.1 | Proportional UI font for the bar, launcher, notifications and GTK/Qt apps. Designed for interfaces; one of the most widely used UI faces there is. |
| `ttf-nerd-fonts-symbols` | extra | 3.4.0 | Icon fallback for everything else. |
| `noto-fonts` | extra | 2026.07.01 | Base sans-serif. Without one you get literal squares. |
| `noto-fonts-emoji` | extra | 2.051 | Colour emoji. |
| `noto-fonts-cjk` | extra | 20240730 | CJK coverage. |
| `otf-font-awesome` | extra | 7.3.1 | Waybar icon fallback. (`ttf-font-awesome` does not exist — common typo in old guides.) |
| `nwg-look` | extra | 1.1.1 | GTK theme/icon/font settings GUI. |
| `papirus-icon-theme` | extra | 20250501 | Icon theme with good Catppuccin folder variants. |
| `qt6ct` | extra | 0.11 | Qt6 appearance control. **Does not reach KDE apps** — see the note below. |
| `qt5ct` | extra | 1.9 | Qt5 appearance control. |
| `libva-utils` | extra | 2.24.0 | `vainfo`, the only way to confirm hardware video decode is actually being used. |

**Shell tooling.** Every one of these replaces a coreutil with a better
version of it; `config/fish/config.fish` wires them up and degrades cleanly if
any is missing.

| Package | Repo | Version | Why |
| --- | --- | --- | --- |
| `fzf` | extra | 0.74.1 | Fuzzy finder. Ships its own fish integration (`fzf --fish`) since 0.48 — Ctrl+R over history, Ctrl+T for files, Alt+C to cd, no plugin manager. |
| `zoxide` | extra | 0.10.0 | `z proj` jumps to the directory you use most. `cd` is left alone deliberately. |
| `eza` | extra | 0.23.5 | `ls` with git status and a tree mode. |
| `bat` | extra | 0.26.1 | `less` with syntax highlighting; also used as `MANPAGER`. |
| `fd` | extra | 10.4.2 | Fast find that respects `.gitignore` — makes fzf's Ctrl+T useful inside a repo. |
| `ripgrep` | extra | 15.2.0 | Fast grep. |

**rofi plugins.**

| Package | Repo | Version | Why |
| --- | --- | --- | --- |
| `rofi-calc` | extra | 2.5.1 | Calculator mode via libqalculate (`SUPER+ALT+C`). Rebuilt against rofi 2.0. Passed with `-modi calc` on the keybind rather than listed in `config.rasi`: rofi warns on every launch about modes it can't find. |
| `rofimoji` | extra | 6.7.0 | Emoji and Nerd Font glyph picker (`SUPER+ALT+E`). |

### Why Dolphin ignored all of this

`qt6ct` themes Qt applications, but **KDE Frameworks applications build their
palette from `KColorScheme`, which reads `~/.config/kdeglobals`** — not from
the Qt platform theme. Nothing had ever written a `kdeglobals`, so Dolphin,
Ark and Okular fell back to Breeze Light on an otherwise dark desktop while
`pavucontrol` and every other Qt app followed the theme correctly.

`install/set-theme.py` now generates `config/kdeglobals` from the palette,
which costs no packages. If a KDE app still looks wrong after that, the
established escalation is:

```bash
paru -S qt6ct-kde     # conflicts with qt6ct; replaces it
```

It is `qt6ct` patched to apply the KDE integration bits as well. It is AUR
(0.11-7, actively maintained) and it can fall out of sync with a Qt update, at
which point it needs rebuilding — which is why it isn't the default here.

**AUR** (CachyOS ships `paru`; `pacman` won't find these):

| Package | AUR version | Why |
| --- | --- | --- |
| `catppuccin-gtk-theme-mocha` | 1.0.3-1 | GTK side of the Mocha palette. Installs `/usr/share/themes/catppuccin-mocha-<accent>-standard+default` — the directory name `gtk_theme` in `themes/mocha.toml` has to match exactly. **If this is missing, GTK falls back to Adwaita silently**, honours the dark preference, and gives you a dark grey desktop that is very nearly right; `install/doctor.sh` checks for it. |
| `catppuccin-gtk-theme-frappe` / `-macchiato` / `-latte` | 1.0.3 | The other flavours, for the matching themes. Optional — those themes fall back to a recoloured Adwaita without them. |
| `gtk-engine-murrine` | 0.98.2-5 | Required by most GTK2/3 themes; missing it silently breaks theming. |
| `bibata-cursor-theme-bin` | 2.0.7-1 | Cursor theme that actually looks right at 1× and 2× scale. **The `-bin` variant deliberately** — the source package builds the cursors with `python-clickgen`, dragging in Pillow, numpy and BLAS/LAPACK (~20 packages that stay installed). `-bin` is the same release, prebuilt, zero dependencies. |

## 6. Applications

| Package | Repo | Version | Why |
| --- | --- | --- | --- |
| `fish` | extra | 4.8.1 | Shell. |
| `starship` | extra | 1.26.0 | Prompt — one TOML file, works in any shell if you ever switch. |
| `kitty` | extra | 0.48.1 | Terminal. |
| `btop` | extra | 1.4.7 | System monitor — your existing config carries over too. |
| `fastfetch` | extra | 2.66.0 | System info. Three layouts in `config/fastfetch/`; the fish function picks by terminal width, because fastfetch itself has none. |
| `mpv` | extra | 0.41.0 | Video player. |
| `imv` | extra | 5.0.1 | Wayland-native image viewer. |

Browser, editor and the rest of your daily software are deliberately not listed —
tell me what you want and I'll fold them in.

---

## Deliberately not included

| Not installing | Reason |
| --- | --- |
| `cachyos-hyprland-settings` / `cachyos-hypr-noctalia` | This is exactly the "someone else's config" you said you didn't want. It also seeds `/etc/skel`, so a fresh user silently inherits their dotfiles. |
| `waybar` alternatives (Quickshell, HyprPanel, AGS) | You chose Waybar. Swappable later — nothing else in the config depends on it. |
| `dunst` / `mako` | Fine daemons, but no notification centre panel. `swaync` covers both roles. |
| `tlp` | Conflicts with `power-profiles-daemon`. Worth revisiting if battery life disappoints. |
| `nwg-displays` | GUI monitor config — but it writes the **old hyprlang** syntax, which 0.56 no longer reads. Would corrupt our setup. Single internal display makes it unnecessary anyway. |
| `swappy` | Superseded by `satty`. |
| `kvantum` | Would give richer Qt widget rendering, but the Catppuccin Kvantum theme isn't packaged for Arch — it must be fetched from GitHub by hand. `qt6ct`'s Fusion style with a custom palette (`config/qt6ct/colors/`) themes Qt apps completely with nothing downloaded. |
| `hyprqt6engine` | Would theme Qt6 apps via Hyprland's own toolkit, but it's at 0.1.0 and AUR-only. `qt6ct` with a custom palette lives in the official repos and needs nothing downloaded. |
| `yay` | CachyOS ships `paru`. One AUR helper is enough. |
| `nm-applet`'s autostart | `network-manager-applet` stays installed — `nm-connection-editor` comes from it — but its tray icon is suppressed by `config/autostart/nm-applet.desktop`. It duplicated Waybar's network module, with different behaviour on click. |
| `wtype` | Only needed to make `rofimoji` *type* rather than copy. Typing depends on the focused app accepting synthetic key events, which Electron apps often don't; copying always works. |

## Rough footprint

Sections 1–6 minus optionals come to roughly 90 packages. On top of a minimal
CachyOS base expect **~2.5–3.5 GB** including fonts and Qt/GTK theming, and a
first-login memory footprint around **600–900 MB** — versus ~1.6 GB for your
current GNOME session.
