# The base every host gets. Hosts import this directory plus whichever
# feature modules from ../ they want.
{
  imports = [
    ./nix.nix # Lix, flakes, caches, GC (nh), nix tooling
    ./boot.nix # Limine, CachyOS kernel, sched_ext, Plymouth
    ./btrfs.nix # mount options, scrub, TRIM (no snapshots)
    ./performance.nix # zram, sysctl, ananicy
    ./locale.nix
    ./networking.nix
    ./security.nix
    ./audio.nix # PipeWire
    ./bluetooth.nix
    ./fonts.nix
    ./packages.nix # baseline CLI tools
  ];
}
