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
| `ttf-jetbrains-mono-nerd` | extra | 3.4.0 | Terminal + bar font, with icon glyphs baked in. |
| `ttf-nerd-fonts-symbols` | extra | 3.4.0 | Icon fallback for everything else. |
| `noto-fonts` | extra | 2026.07.01 | Base sans-serif. Without one you get literal squares. |
| `noto-fonts-emoji` | extra | 2.051 | Colour emoji. |
| `noto-fonts-cjk` | extra | 20240730 | CJK coverage. |
| `otf-font-awesome` | extra | 7.3.1 | Waybar icon fallback. (`ttf-font-awesome` does not exist — common typo in old guides.) |
| `nwg-look` | extra | 1.1.1 | GTK theme/icon/font settings GUI. |
| `papirus-icon-theme` | extra | 20250501 | Icon theme with good Catppuccin folder variants. |
| `qt6ct` | extra | 0.11 | Qt6 appearance control. |
| `qt5ct` | extra | 1.9 | Qt5 appearance control. |
| `kvantum` | extra | 1.1.8 | Qt widget theming engine. |

**AUR** (CachyOS ships `paru`; `pacman` won't find these):

| Package | AUR version | Why |
| --- | --- | --- |
| `catppuccin-gtk-theme-mocha` | 1.0.3-1 | GTK side of the Mocha palette. |
| `gtk-engine-murrine` | 0.98.2-5 | Required by most GTK2/3 themes; missing it silently breaks theming. |
| `bibata-cursor-theme` | 2.0.7-1 | Cursor theme that actually looks right at 1× and 2× scale. |

## 6. Applications

| Package | Repo | Version | Why |
| --- | --- | --- | --- |
| `kitty` | extra | 0.48.1 | Terminal — your existing `~/.config/kitty` carries over unchanged. |
| `btop` | extra | 1.4.7 | System monitor — your existing config carries over too. |
| `fastfetch` | extra | 2.66.0 | System info. |
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
| `hyprqt6engine` | Would theme Qt6 apps via Hyprland's own toolkit, but it's at 0.1.0 and AUR-only. `qt6ct` + `kvantum` is the established path and lives in the official repos. |
| `yay` | CachyOS ships `paru`. One AUR helper is enough. |

## Rough footprint

Sections 1–6 minus optionals come to roughly 90 packages. On top of a minimal
CachyOS base expect **~2.5–3.5 GB** including fonts and Qt/GTK theming, and a
first-login memory footprint around **600–900 MB** — versus ~1.6 GB for your
current GNOME session.
