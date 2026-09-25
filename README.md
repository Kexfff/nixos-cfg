# ❄️ nixos-config

Modular NixOS flake for two machines, built around a switch-based module tree.

| Component      | Choice                                                                    |
| -------------- | ------------------------------------------------------------------------- |
| Nix            | **Lix** (from nixpkgs), flakes only, no channels                          |
| Bootloader     | **Limine** (UEFI, optional Secure Boot via sbctl)                         |
| Filesystem     | **Btrfs** (zstd, noatime, monthly scrub) — *no* snapshot tooling          |
| Kernel         | **CachyOS** (chaotic-nyx, binary cached) + `sched_ext` (`scx_lavd`)       |
| Desktop        | **KDE Plasma 6** on Wayland, SDDM, plasma-manager for declarative settings|
| Users          | **Home Manager** as a NixOS module                                        |
| GC             | `nh clean all` weekly (keeps 5 generations / 7 days) + store optimisation |
| Hosts          | `desktop` (AMD CPU + NVIDIA) · `laptop` (Intel CPU + iGPU)                |

## Layout

```
flake.nix                 inputs + nixosConfigurations (one line per host)
lib/                      mkHost helper
hosts/<name>/             per-machine switches + hardware-configuration.nix
modules/nixos/            shared NixOS modules, all gated by `my.*` options
  core/                   nix (Lix, GC), boot (Limine, kernel), btrfs, users, …
  hardware/               cpu, gpu, laptop, audio, bluetooth
  desktop/                plasma, fonts
  programs/               gaming, development, virtualisation, nix-tools
  services/               printing, ssh, flatpak, tailscale
modules/home/             shared Home Manager modules (read osConfig.my.*)
users/<name>/             personal Home Manager extras (auto-imported)
overlays/  pkgs/          overlays and custom packages
```

A host file is nothing but switches:

```nix
my = {
  hardware = { cpu = "amd"; gpu = "nvidia"; };
  desktop.plasma.enable = true;
  gaming.enable = true;
  development = { enable = true; languages = [ "rust" "python" ]; };
};
```

## Apply to an installed system

1. **Get the repo** (flakes only see files tracked by git):

   ```bash
   sudo mv /etc/nixos /etc/nixos.bak
   sudo git clone <your-fork> /etc/nixos && sudo chown -R "$USER" /etc/nixos
   cd /etc/nixos
   ```

2. **Bring in your hardware config** (the placeholder refuses to build):

   ```bash
   cp /etc/nixos.bak/hardware-configuration.nix hosts/desktop/   # or hosts/laptop/
   ```

3. **Edit the switches** in `hosts/desktop/default.nix` (or `laptop`):
   `my.user.*`, `my.locale.*`, `my.hardware.nvidia.open`, `filesystem.btrfs.mountpoints`
   and **`system.stateVersion`** (copy it from `/etc/nixos.bak/configuration.nix`).
   Rename `users/user/` to match `my.user.name`.

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
   changes — a clean reboot is the safest path. The first evaluation writes `flake.lock`;
   commit it (`git add flake.lock`) so future builds are reproducible.

5. From now on:

   ```bash
   nh os switch        # rebuild (NH_FLAKE points at /etc/nixos)
   nh os boot          # rebuild, activate on next boot
   nix flake update    # bump inputs, then `nh os switch`
   nh clean all        # manual GC (also runs weekly)
   ```

### Secure Boot (optional)

```bash
sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft     # with firmware in Setup Mode
# then set my.boot.limine.secureBoot = true; and rebuild
```

## Adding a machine

```bash
mkdir hosts/htpc && cp hosts/desktop/default.nix hosts/htpc/
sudo nixos-generate-config --show-hardware-config > hosts/htpc/hardware-configuration.nix
# flake.nix:  htpc = mylib.mkHost { hostname = "htpc"; };
```

## Credits

- Cursor themes (in `assets/cursors/`):
  - **Layan** — https://github.com/vinceliuice/Layan-cursors
  - **NieR** — https://github.com/Beinsezii/NieR-Cursors
  - **Qogir** — https://github.com/vinceliuice/Qogir-icon-theme
  - **Vimix** — https://github.com/vinceliuice/Vimix-cursors

## Notes

- **NVIDIA + CachyOS kernel**: the default `my.hardware.nvidia.driver = "cachyos"` uses
  chaotic's pre-built `nvidia_cachyos`, matching the Clang/LTO kernel. Switch to
  `"latest"`/`"beta"` if you use a non-CachyOS kernel.
- **Out-of-tree modules** (xone, xpadneo, …) may not build against the Clang kernel;
  use `my.boot.kernel = "cachyos-gcc"` in that case.
- **No `inputs.nixpkgs.follows` on `chaotic`** — it would invalidate the binary cache.
- **Secrets**: `my.user.hashedPasswordFile` accepts a path from sops-nix / agenix.
- **Btrfs**: `compress=zstd,noatime` are merged into the generated mount options;
  scrub runs monthly. Docker uses overlay2 on purpose (its btrfs driver snapshots).
