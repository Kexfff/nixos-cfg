# ❄️ nixos-config

NixOS flake for two machines. No custom option layer: a module is turned on by
importing it, and everything inside is plain NixOS / Home Manager options you can
look up on [search.nixos.org](https://search.nixos.org/options).

| Component      | Choice                                                                    |
| -------------- | ------------------------------------------------------------------------- |
| Nix            | **Lix** (from nixpkgs), flakes only, no channels                          |
| Bootloader     | **Limine** (UEFI, optional Secure Boot via sbctl)                         |
| Filesystem     | **Btrfs** (zstd, noatime, monthly scrub) — *no* snapshot tooling          |
| Kernel         | **CachyOS** (chaotic-nyx, binary cached) + `sched_ext`                    |
| Desktop        | **KDE Plasma 6** on Wayland, SDDM + qylock theme, plasma-manager          |
| Second session | **niri** + [DM-Shell](https://github.com/Kexfff/DM-Shell) + [DM Manager](https://github.com/Kexfff/dm-manager) (laptop) |
| Users          | **Home Manager** as a NixOS module                                        |
| GC             | `nh clean all` weekly (keeps 5 generations / 7 days) + store optimisation |
| Hosts          | `desktop` (AMD CPU + NVIDIA) · `laptop` (Intel CPU + iGPU)                |

## Layout

```
flake.nix               inputs + the two hosts
hosts/<name>/           which modules this machine imports + machine-only settings
modules/core/           always imported: nix, boot, btrfs, performance, locale, audio, …
modules/hardware/       amd-cpu, intel-cpu, nvidia, intel-gpu, laptop
modules/desktop/        plasma, qylock, dm-shell (niri + dmsh + DM Manager)
modules/*.nix           gaming, development, docker, podman, libvirt, printing, flatpak, ssh, tailscale
users/kexfff/           the account (default.nix) + Home Manager (home.nix, shell, git, editors, fastfetch)
pkgs/                   custom packages → pkgs.<name>
assets/                 wallpaper, fastfetch logo, cursor themes
```

## Everyday changes

| I want to…                         | Edit                                                        |
| ---------------------------------- | ----------------------------------------------------------- |
| install an app for myself          | `home.packages` in `users/kexfff/home.nix`                  |
| install a system tool everywhere   | `modules/core/packages.nix`                                 |
| install something on one machine   | `environment.systemPackages` in `hosts/<name>/default.nix`  |
| turn a feature on/off for a machine | add/remove its line in `imports` of `hosts/<name>/default.nix` |
| change a feature everywhere        | the feature's file in `modules/`                            |
| add a new feature                  | new `modules/<thing>.nix`, then import it in the hosts      |

Shared modules set things hosts commonly change with `lib.mkDefault` (kernel,
sched_ext scheduler, nh flake path, NVIDIA open modules), so a host overrides them
with a plain assignment, e.g. `services.scx.scheduler = "scx_bpfland";`.
Feature modules that also need Home Manager settings (plasma, gaming, development)
add them via `home-manager.sharedModules`, so a feature stays in one file.

```bash
nh os switch        # rebuild + activate (NH_FLAKE points at ~/nixos-cfg)
nh os boot          # rebuild, activate on next boot
nix flake update    # bump inputs, then `nh os switch`
nh clean all        # manual GC (also runs weekly)
nix fmt             # format the repo
```

## Install on a machine

1. **Get the repo** into `~/nixos-cfg` (flakes only see files tracked by git):

   ```bash
   git clone <this-repo> ~/nixos-cfg && cd ~/nixos-cfg
   ```

   Elsewhere? Set `programs.nh.flake = "/path";` in the host file.

2. **Bring in the hardware config** (the desktop placeholder refuses to build):

   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/desktop/hardware-configuration.nix
   ```

   It must declare btrfs mounts for `/`, `/home` and `/nix` (see `modules/core/btrfs.nix`).

3. **Set `system.stateVersion`** in the host file to the release you installed
   (copy it from `/etc/nixos/configuration.nix`).

4. **First build** — pass the chaotic cache explicitly so you don't compile the kernel
   (afterwards the module keeps it configured):

   ```bash
   git add -A
   sudo nixos-rebuild boot --flake .#desktop \
     --option extra-substituters "https://nyx-cache.chaotic.cx/" \
     --option extra-trusted-public-keys "nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk="
   sudo reboot
   ```

   `boot` instead of `switch` because the bootloader changes to Limine and the kernel
   changes — a clean reboot is the safest path.

### Secure Boot (optional)

```bash
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft     # with firmware in Setup Mode
# then set boot.loader.limine.secureBoot.enable = true in modules/core/boot.nix
```

## Adding a machine

```bash
mkdir hosts/htpc && cp hosts/desktop/default.nix hosts/htpc/
sudo nixos-generate-config --show-hardware-config > hosts/htpc/hardware-configuration.nix
# flake.nix:  htpc = mkHost "htpc";
```

## Credits

- Cursor themes (in `assets/cursors/`, install with `assets/install_cursors.sh`):
  - **Layan** — https://github.com/vinceliuice/Layan-cursors
  - **NieR** — https://github.com/Beinsezii/NieR-Cursors
  - **Qogir** — https://github.com/vinceliuice/Qogir-icon-theme
  - **Vimix** — https://github.com/vinceliuice/Vimix-cursors

## Notes

- **NVIDIA + CachyOS kernel**: `modules/hardware/nvidia.nix` uses chaotic's pre-built
  `nvidia_cachyos`, matching the Clang/LTO kernel. On a non-CachyOS kernel switch to
  `config.boot.kernelPackages.nvidiaPackages.latest`.
- **Out-of-tree modules** (xone, xpadneo, …) may not build against the Clang kernel;
  use `boot.kernelPackages = pkgs.linuxPackages_cachyos-gcc;` in that case.
- **No `inputs.nixpkgs.follows` on `chaotic`** — it would invalidate the binary cache.
- **Secrets**: `users.users.<name>.hashedPasswordFile` accepts a path from sops-nix / agenix.
- **Btrfs**: `compress=zstd,noatime` are merged into the generated mount options;
  scrub runs monthly. Docker uses overlay2 on purpose (its btrfs driver snapshots).
