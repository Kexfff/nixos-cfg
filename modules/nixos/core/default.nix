{
  imports = [
    ./nix.nix # Lix, flakes, caches, garbage collection
    ./boot.nix # Limine, CachyOS kernel, sched_ext, Plymouth
    ./filesystem.nix # Btrfs mount tuning + scrub (no snapshots)
    ./performance.nix # zram, sysctl, ananicy
    ./locale.nix
    ./networking.nix
    ./users.nix # primary user + Home Manager wiring
    ./security.nix
    ./packages.nix # baseline CLI tools
  ];
}
