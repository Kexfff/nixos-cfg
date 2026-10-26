# Bootloader (Limine), kernel (CachyOS via chaotic-nyx), sched_ext, Plymouth.
{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [ inputs.chaotic.nixosModules.default ]; # CachyOS kernels, binary cache, overlay

  boot = {
    # chaotic-nyx builds, binary-cached. Other flavours (override in a host):
    #   pkgs.linuxPackages_cachyos-gcc         GCC-built, if an out-of-tree module won't build
    #   pkgs.linuxPackages_cachyos-lto-znver4  Zen 4 / Zen 5 only
    #   pkgs.linuxPackages_cachyos-lts / pkgs.linuxPackages_latest
    kernelPackages = lib.mkDefault pkgs.linuxPackages_cachyos;

    loader = {
      limine = {
        enable = true;
        efiSupport = true;
        enableEditor = true; # edit kernel parameters from the boot menu (rescue)
        maxGenerations = 15; # boot-menu entries (GC decides what exists on disk)
        style.wallpapers = [ ../../assets/limine/limine_wallpaper.jpg ];
        # Secure Boot: `sudo sbctl create-keys && sudo sbctl enroll-keys --microsoft`
        # (firmware in Setup Mode), then set this to true and add pkgs.sbctl.
        secureBoot.enable = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 3;
      # make sure nothing else claims the ESP
      systemd-boot.enable = lib.mkForce false;
      grub.enable = lib.mkForce false;
    };

    # systemd in stage 1: faster, and required for a good Plymouth experience
    initrd.systemd.enable = true;
    tmp.cleanOnBoot = true;

    # Graphical splash + quiet kernel output
    plymouth.enable = true;
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };

  # sched_ext: CachyOS-style user-space CPU scheduling. Check: systemctl status scx
  #   scx_lavd    — latency-first; what CachyOS ships for gaming
  #   scx_bpfland — interactive desktop workloads, gentle on battery
  #   scx_rusty   — general purpose / many-core
  services.scx = {
    enable = true;
    scheduler = lib.mkDefault "scx_lavd";
  };
}
