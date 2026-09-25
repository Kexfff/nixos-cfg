# Entry point for all shared NixOS modules.
#
# Every feature is gated behind an option under `my.*`, so a host file is just a
# list of switches — see hosts/desktop/default.nix for the full menu.
#
#   core/      Nix (Lix, GC, caches), boot (Limine, CachyOS kernel), btrfs,
#              performance, locale, networking, users + Home Manager, security
#   hardware/  CPU (amd/intel), GPU (nvidia/amd/intel), laptop, audio, bluetooth
#   desktop/   KDE Plasma 6 + fonts
#   programs/  gaming, development, virtualisation, nix quality-of-life tools
#   services/  printing, ssh, flatpak, tailscale
{
  imports = [
    ./core
    ./hardware
    ./desktop
    ./programs
    ./services
  ];
}
