# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A NixOS flake (Lix, Limine, Btrfs, CachyOS kernel via chaotic-nyx, KDE Plasma 6, Home Manager as a NixOS module) for one user (`kexfff`) on two hosts: `laptop` (Intel + iGPU) and `desktop` (AMD + NVIDIA). `laptop` is the installed machine. `desktop` still has a placeholder `hardware-configuration.nix` and a guessed `system.stateVersion`.

The user may be working from a non-NixOS machine without `nix`. Check before running build commands. If it's missing, say so; don't claim anything was evaluated. Testing is planned in a VM.

## Commands

```bash
nix develop                                   # dev shell: nh, nom, nvd, nixd, nixfmt, statix, deadnix (or direnv via .envrc)
nix fmt                                       # format the repo (nixfmt, RFC 166 style)
statix check . && deadnix .                   # lint
nix flake check                               # evaluate all outputs
nix eval .#nixosConfigurations.laptop.config.system.build.toplevel.drvPath   # quick eval of one host
nix build .#nixosConfigurations.laptop.config.system.build.toplevel          # full build without activating
nvd diff ./result-old ./result                # compare two builds (use after refactors: should be ~identical)
sudo nixos-rebuild switch --flake .#laptop    # or `nh os switch` (NH_FLAKE defaults to ~/nixos-cfg)
```

Flakes only see git-tracked files, so `git add` any new file before evaluating, or the build fails with "path does not exist".

## Architecture

The design is intentionally flat. **Don't reintroduce a custom option layer** (`my.*`, `mkEnableOption` switches, enum-driven lookup tables). The user asked for this simplification because that layer made the config hard to navigate.

- **Importing a module turns it on.** `hosts/<name>/default.nix` is an `imports` list (`../../modules/core` plus the features it wants) plus machine-only settings. Feature modules contain plain NixOS options with no `enable` gate.
- **`flake.nix` `mkHost`** builds `hosts/<hostname>` + `users/${username}` and passes `inputs` and `username` as `specialArgs`. Modules that need the user name (group membership) take `username` as an argument.
- **External flake modules are imported where they're used**, not centrally: chaotic in `core/boot.nix`, nix-index-database in `core/nix.nix`, home-manager in `users/kexfff/default.nix`, nix-flatpak in `flatpak.nix`, dmsh + dm-manager in `desktop/dm-desktop.nix`, plasma-manager (HM) in `desktop/plasma.nix`.
- **One feature = one file, including its Home Manager part.** Feature modules add user-level config through `home-manager.sharedModules` (MangoHud in `gaming.nix`, plasma-manager settings in `desktop/plasma.nix`, direnv in `development.nix`).
- **Personal Home Manager config** (apps, shell, git identity, editors, fastfetch) lives in `users/kexfff/`, entered via `home.nix`. It's identical on both hosts.
- **Host overrides:** shared modules use `lib.mkDefault` for values hosts commonly change (kernel, `services.scx.scheduler`, `programs.nh.flake`, `hardware.nvidia.open`). Hosts override them with a plain assignment. Add `mkDefault` to a shared value before overriding it in a host, rather than using `mkForce`.
- **Custom packages:** `pkgs/default.nix` (`pkgs: { … }`) is overlaid as `pkgs.<name>` in `core/nix.nix` and exposed as `packages.x86_64-linux.<name>`.

## Constraints and gotchas

- **Never add `inputs.nixpkgs.follows` to `chaotic` or `llm-agents`.** It invalidates their binary caches: the CachyOS kernel would compile locally, and llm-agents packages would miss `cache.numtide.com`.
- `hardware-configuration.nix` files are generated per machine. Don't hand-edit them. `core/btrfs.nix` adds `compress=zstd,noatime` to `/`, `/home` and `/nix`, so every host must declare those mounts.
- Don't change `system.stateVersion` (HM's `home.stateVersion` follows it).
- `nvidia.nix` uses `pkgs.nvidia_cachyos`, which only matches a CachyOS kernel. Out-of-tree modules (xone, xpadneo) may need `pkgs.linuxPackages_cachyos-gcc`.
- HM backs up conflicting dotfiles as `*.hm-bak` instead of failing.
- `desktop/dm-desktop.nix` is a second session next to Plasma: niri + the user's own DM-Shell (dmsh) and DM Manager. Its configs live in `dotfiles/` (taken from github:Kexfff/dm-desktop, now maintained here, not there) and are linked with `mkOutOfStoreSymlink` to the checkout at `programs.nh.flake`, so edits apply without a rebuild; the checkout must really be at that path. `dotfiles/dmsh/config.kdl` and `dotfiles/swayidle/config` are only starter copies: an activation script copies them to `~/.config` once and never links them, because DM Manager edits them in place. `niri/dmsh.kdl` is generated from `dmsh niri`; `niri/dm-manager.kdl` is DM Manager's and stays unmanaged. These projects are young and may change.
