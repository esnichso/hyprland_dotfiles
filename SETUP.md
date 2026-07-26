# Setup guide — Ubuntu today, CachyOS + Hyprland at the end

Four phases, in order. Nothing touches the real disk until **Phase 3**, and by then
the exact same config will already have booted in a VM.

| Phase | Where | Reversible? |
| --- | --- | --- |
| 0 · Build the config | here, on Ubuntu | yes — just files in this repo |
| 1 · Validate in a VM | here, on Ubuntu | yes — delete the VM |
| 2 · Back up and prepare | here, on Ubuntu | yes |
| 3 · Install on the ThinkPad | bare metal | **no — Ubuntu is erased** |
| 4 · First login and iterate | CachyOS | yes |

---

## Phase 0 — Build the config (on Ubuntu, now)

Nothing to install. The config is written here, reviewed by you, committed to git.

```bash
cd ~/HPI/projects/hypersetup
git init && git add -A && git commit -m "hyprland config: initial"
```

Version control from the start matters more than usual here: when a change breaks
your session you want `git diff` and `git checkout --` available from a TTY.

See [README.md](README.md) for the full layout. In short: `config/` holds what
gets symlinked into `~/.config` (hypr, uwsm, waybar, rofi, swaync), `install/`
holds the verified package lists plus `bootstrap.sh` and `link.sh`, and
`docs/hyprland/` is the cached upstream wiki.

`docs/hyprland/` is a snapshot of the official wiki taken 2026-07-26. It is there
because the online wiki is JavaScript-rendered and hard to grep, and because
almost everything written about Hyprland before May 2026 uses the dead hyprlang
syntax. Refresh it any time:

```bash
# see the loop in git history, or just re-run the fetch for a single page:
curl -sfL "https://raw.githubusercontent.com/hyprwm/hyprland-wiki/main/content/Configuring/Basics/Binds.md" \
  -o docs/hyprland/Configuring_Basics_Binds.md
```

## Phase 1 — Validate in a VM (on Ubuntu, before touching the disk)

The point is to find the mistakes that only appear on a real CachyOS system —
wrong package names, a service that isn't enabled, a Lua typo that kills the
session — while your working laptop is still your working laptop.

**1. Install virtualisation tooling**

```bash
sudo apt install qemu-system-x86 libvirt-daemon-system virt-manager ovmf
sudo usermod -aG libvirt,kvm "$USER"
# log out and back in for the group change to apply
```

**2. Download and verify the ISO**

```bash
mkdir -p ~/Downloads/cachyos && cd ~/Downloads/cachyos
# get the current desktop ISO + its .sha256 from https://cachyos.org/download/
sha256sum -c cachyos-desktop-linux-*.iso.sha256
```

Do not skip the checksum. A truncated ISO fails in confusing ways halfway through
partitioning.

**3. Create the VM in virt-manager**

Settings that actually matter:

| Setting | Value | Why |
| --- | --- | --- |
| Firmware | **UEFI** (OVMF) | Matches the ThinkPad; the installer behaves differently under BIOS. |
| Memory | 8192 MB | Comfortable; you have 30 GB. |
| CPUs | 6 | Leaves headroom for your host session. |
| Disk | 40 GB | Enough for the base plus our ~3 GB of packages. |
| Video | **virtio, 3D acceleration ON** | **Hyprland will not start without 3D acceleration in a VM.** |
| Display | Spice with OpenGL, or SDL/GTK with `gl=on` | Required for the above to actually reach the guest. |

**4. Install CachyOS in the VM**

Follow Phase 3's installer steps exactly as you will on metal, including selecting
**no desktop environment**.

**5. Get this repo into the VM**

Over git. Nothing is shared between the host and guest filesystems — the VM
just clones from a remote like any other machine would. You need a remote for
the metal install in Phase 3 anyway, so this is set up once and reused.

The repo is already initialised locally with a first commit. Create an **empty
private repository** on GitHub (or Codeberg, or wherever), then on the host:

```bash
cd ~/HPI/projects/hypersetup
git remote add origin git@github.com:<you>/hypersetup.git
git push -u origin main
```

Your `~/.ssh/id_ed25519` key already exists, so SSH works if that key is on
your account. If you'd rather not put the key in the VM, clone over HTTPS
instead — the repo holds no secrets, but keep it private regardless since it
describes your machine in detail.

In the guest:

```bash
sudo pacman -S --needed git
git clone https://github.com/<you>/hypersetup.git ~/hypersetup
```

**6. Bring up the config**

```bash
cd ~/hypersetup/install
./bootstrap.sh --dry-run     # read what it will do first
./bootstrap.sh
./link.sh
sudo reboot
```

**The iteration loop.** `link.sh` symlinks rather than copies, so `~/.config/hypr`
inside the VM points at the clone. That makes pulling a change a one-liner —
Hyprland reloads the moment the files change on disk:

```bash
# in the VM, after pushing a fix from the host
cd ~/hypersetup && git pull && ./install/link.sh && hyprctl reload
```

`link.sh` is in there because a pull that adds a *new* config directory has
nothing linking it into `~/.config` yet; it's a no-op when nothing is new.

You may see an "Emergency mode tripped" banner during the pull itself. Hyprland
reloads the moment a file changes, so it can catch git mid-checkout with a file
momentarily missing. The `hyprctl reload` at the end clears it, and the pcall
guard in `hyprland.lua` keeps the damage to a single module rather than the
whole config.

Waybar doesn't hot-reload as reliably; `SUPER+SHIFT+B` restarts it.

Then work through the Phase 4 checklist inside the VM. Expect a few failures —
that is the entire point of this phase. Fix them in the repo here, commit, push,
pull in the VM. Don't edit inside the VM: it's the throwaway half of this pair,
and changes made there are lost when you delete it.

**Known VM caveats** (do not chase these; they will not reproduce on metal):
animations are choppy, brightness keys do nothing (no backlight device), battery
module shows nothing, and VA-API acceleration is unavailable.

## Phase 2 — Back up (on Ubuntu, before the wipe)

Ubuntu is being erased. Copy to an external drive or another machine — **not** to
another partition on the same disk.

```bash
DEST=/media/$USER/backup    # adjust
mkdir -p "$DEST"

# Credentials and keys — the irreplaceable part
cp -a ~/.ssh ~/.gnupg "$DEST/"

# Your work
cp -a ~/HPI "$DEST/"

# Dotfiles worth keeping (kitty and btop configs carry straight over)
cp -a ~/.config/kitty ~/.config/btop ~/.config/git ~/.gitconfig "$DEST/" 2>/dev/null

# Application data you would miss
cp -a ~/.config/obsidian ~/.config/anytype ~/.config/JetBrains "$DEST/" 2>/dev/null
cp -a ~/.mozilla ~/.config/chromium ~/.config/google-chrome "$DEST/" 2>/dev/null

# For reference when rebuilding: what you had installed
dpkg --get-selections > "$DEST/ubuntu-packages.txt"
snap list > "$DEST/ubuntu-snaps.txt"
nmcli -s connection show > "$DEST/wifi-networks.txt"   # includes saved passwords
```

Verify the backup by reading files back off the drive before you continue. A
backup you have not tested is a hope, not a backup.

Also worth having: a second USB stick with a Ubuntu live image, so a failed
install still leaves you with a way to browse the web and read this guide.

## Phase 3 — Install on the ThinkPad

**1. Write the ISO to USB**

```bash
lsblk                                    # identify the stick — get this right
sudo dd if=cachyos-desktop-linux-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

**2. BIOS settings** (F1 at the Lenovo splash)

- Secure Boot: **disabled** — required by the CachyOS installer in UEFI mode.
- CSM / Legacy boot: **disabled** — you want a pure UEFI install.
- Legacy USB Support: **Auto**.

**3. Boot the USB** (F12 for the boot menu) and click **Launch Installer**.

**4. Installer steps**

1. Language, region/timezone, keyboard layout.
2. **Manual partitioning.** CachyOS explicitly warns that "Install alongside" and
   "Replace partition" are unreliable — do it by hand even for a full wipe.
3. Boot manager: **Limine** (CachyOS's default, and it integrates with Btrfs
   snapshots). Partitions:
   - `/boot` — FAT32, **at least 4096 MiB**, flag `boot`
   - `/` — Btrfs, remaining space
4. Filesystem: **Btrfs**. This is the one choice I would argue for. CachyOS sets up
   snapshots with it, which means a broken update or a broken config is a rollback
   from the boot menu rather than a reinstall.
5. Desktop environment: **none**. This is the whole point — no `-settings` package
   lands in `/etc/skel`, so your user is created with an empty `~/.config` and
   nothing of CachyOS's own Hyprland dotfiles is ever seeded into it.
6. Packages: take the defaults; our own list comes later.
7. Set username and password.
8. Review the summary carefully, then install.

With no desktop selected you boot into a **plain TTY** — no login screen, no
graphical session. That is expected. Log in as your user and continue below;
SDDM and Hyprland arrive with our package list.

**5. First boot**

```bash
sudo pacman -Syu
```

Check that the CachyOS repos in `/etc/pacman.conf` are the **v3** variants. Your
Core Ultra 7 255H has no AVX-512, so v4 packages would not run:

```bash
grep -oE '^\[cachyos[a-z0-9-]*\]' /etc/pacman.conf
/lib/ld-linux-x86-64.so.2 --help | grep -A3 'Subdirectories'   # v3 supported, v4 not
```

**6. Install our stack**

Same remote you set up in Phase 1 — and by now it also holds every fix the VM
run turned up. **Push any outstanding commits before you wipe Ubuntu**; this
machine is about to stop existing.

```bash
sudo pacman -S --needed git
git clone https://github.com/<you>/hypersetup.git ~/hypersetup
cd ~/hypersetup/install
./bootstrap.sh
./link.sh
sudo reboot
```

Belt and braces: drop a copy of the repo on the same USB stick as the Phase 2
backup. If the remote is unreachable from a fresh install — no Wi-Fi driver, no
network yet — you'd otherwise be stuck with no config and no way to fetch it.

At the SDDM login screen pick **Hyprland (uwsm-managed)**.

## Phase 4 — First login checklist

Work down the list. Anything that fails, tell me and I'll fix it in the repo.

**Session**
- [ ] Hyprland starts, wallpaper visible, bar visible
- [ ] `SUPER + Q` opens kitty
- [ ] `SUPER + R` opens rofi
- [ ] `hyprctl version` reports **0.56 or newer**
- [ ] `hyprctl monitors` shows `eDP-1` at native resolution and refresh rate

**Hardware**
- [ ] Brightness keys work (`brightnessctl` device present)
- [ ] Volume keys work and swayosd shows a popup
- [ ] Sound actually plays (`sof-firmware` is doing its job)
- [ ] Battery percentage in the bar; `upower -i $(upower -e | grep BAT)` agrees
- [ ] Wi-Fi connects; Bluetooth pairs
- [ ] Touchpad: two-finger scroll, tap-to-click, gestures
- [ ] Lid close suspends; reopening resumes to the lock screen
- [ ] `vainfo` lists Intel entrypoints (hardware video decode alive)

**Desktop plumbing**
- [ ] Screenshot keybind captures and opens satty
- [ ] Clipboard history via rofi
- [ ] A notification appears (`notify-send hello`)
- [ ] A file picker opens in Firefox/Chromium (portal + `xdg-desktop-portal-gtk`)
- [ ] Screenshare works in a browser meeting (portal + PipeWire)
- [ ] A password prompt appears for something privileged (hyprpolkitagent)
- [ ] USB stick automounts (udiskie)
- [ ] `hyprlock` locks and unlocks; idle timeout locks on its own

> Test hyprlock by running it **from a terminal** the first time, not from the
> keybind: `hyprlock --verbose`. If it dies you see the error, instead of being
> stranded on the "lockscreen app died" screen. Recover from that with a TTY
> (`Ctrl+Alt+F3`) and `hyprctl --instance 0 eval 'hl.clear_crashed_lockscreen()'`.

## When something breaks

Hyprland gives you emergency binds even with a broken config: **SUPER+Q** terminal,
**SUPER+R** run, **SUPER+M** exit.

```bash
# Compositor log
cat ~/.local/share/hyprland/hyprland.log

# Session units
journalctl --user -b -u hyprland-session.target
systemctl --user status xdg-desktop-portal-hyprland

# Config errors: Lua syntax errors block reload and pop a message
hyprctl reload

# Find a window's class/title for a rule that isn't matching
hyprctl clients

# Find the keysym a key actually sends
wev
```

Config is reloaded the instant you save it. If a change makes the session
unusable, switch to a TTY with **Ctrl+Alt+F2** and `git checkout` the file.

Because `require()` isolates each file into its own Lua scope, an error in
`conf/binds.lua` does not stop `conf/monitors.lua` from loading — you lose one
piece of the config, not the whole session.
