# Desktop responsiveness: zram, CachyOS-inspired sysctls, ananicy process priorities.
{ pkgs, ... }:
{
  # Compressed swap in RAM
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  # ananicy-cpp with the CachyOS rule set: auto-nice games, compilers, browsers
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
    rulesProvider = pkgs.ananicy-rules-cachyos;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 100; # zram is cheap — swap early, keep the page cache warm
    "vm.page-cluster" = 0; # no read-ahead for zram
    "vm.vfs_cache_pressure" = 50;
    "vm.dirty_bytes" = 268435456;
    "vm.dirty_background_bytes" = 67108864;
    "vm.max_map_count" = 2147483642; # Steam/Proton, DaVinci Resolve, …
    "kernel.nmi_watchdog" = 0;
    "kernel.split_lock_mitigate" = 0; # some games stutter badly with the mitigation
    "net.core.netdev_max_backlog" = 4096;
    "fs.file-max" = 2097152;
  };
}
