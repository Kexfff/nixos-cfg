# Desktop responsiveness: zram, CachyOS-inspired sysctls, ananicy process priorities.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.performance;
in
{
  options.my.performance = {
    zram = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Compressed swap in RAM (zstd). Usually better than a swap partition on desktops.";
      };
      memoryPercent = lib.mkOption {
        type = lib.types.int;
        default = 50;
      };
    };

    ananicy.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "ananicy-cpp with the CachyOS rule set: auto-nice games, compilers, browsers.";
    };

    sysctl.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "CachyOS-style kernel sysctl tuning.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.zram.enable {
      zramSwap = {
        enable = true;
        algorithm = "zstd";
        inherit (cfg.zram) memoryPercent;
        priority = 100;
      };
      boot.kernel.sysctl = {
        "vm.swappiness" = 100; # zram is cheap — swap early, keep the page cache warm
        "vm.page-cluster" = 0; # no read-ahead for zram
      };
    })

    (lib.mkIf cfg.ananicy.enable {
      services.ananicy = {
        enable = true;
        package = pkgs.ananicy-cpp;
        rulesProvider = pkgs.ananicy-rules-cachyos;
      };
    })

    (lib.mkIf cfg.sysctl.enable {
      boot.kernel.sysctl = {
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_bytes" = 268435456;
        "vm.dirty_background_bytes" = 67108864;
        "vm.max_map_count" = 2147483642; # Steam/Proton, DaVinci Resolve, …
        "kernel.nmi_watchdog" = 0;
        "kernel.split_lock_mitigate" = 0; # some games stutter badly with the mitigation
        "net.core.netdev_max_backlog" = 4096;
        "fs.file-max" = 2097152;
      };
    })
  ];
}
