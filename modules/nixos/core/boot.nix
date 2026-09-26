# Bootloader (Limine), kernel (CachyOS via chaotic-nyx), sched_ext, Plymouth.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.boot;

  kernels = {
    # chaotic-nyx builds — binary-cached, kconfig-identical to upstream CachyOS
    cachyos = pkgs.linuxPackages_cachyos; # default flavour (BORE, Clang + LTO)
    cachyos-gcc = pkgs.linuxPackages_cachyos-gcc; # same, GCC-built (if an out-of-tree module misbehaves)
    cachyos-lts = pkgs.linuxPackages_cachyos-lts;
    cachyos-znver4 = pkgs.linuxPackages_cachyos-lto-znver4; # Zen 4 / Zen 5 only
    # plain nixpkgs kernels
    zen = pkgs.linuxPackages_zen;
    latest = pkgs.linuxPackages_latest;
    default = pkgs.linuxPackages;
  };
in
{
  options.my.boot = {
    kernel = lib.mkOption {
      type = lib.types.enum (builtins.attrNames kernels);
      default = "cachyos";
      description = "Kernel flavour to boot.";
    };

    scx = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Run a sched_ext user-space CPU scheduler (needs a 6.12+ kernel with sched_ext, e.g. CachyOS).";
      };
      scheduler = lib.mkOption {
        type = lib.types.str;
        default = "scx_lavd";
        example = "scx_bpfland";
        description = ''
          scx_lavd    — latency-first; what CachyOS ships for gaming.
          scx_bpfland — interactive desktop workloads.
          scx_rusty   — general purpose / many-core.
        '';
      };
    };

    limine = {
      maxGenerations = lib.mkOption {
        type = lib.types.int;
        default = 15;
        description = "Boot-menu entries to show (GC still decides what exists on disk).";
      };
      editor = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Allow editing kernel parameters from the boot menu (handy for rescue).";
      };
      secureBoot = lib.mkEnableOption ''
        Secure Boot through Limine + sbctl. Before enabling, create and enroll keys:
          sudo sbctl create-keys && sudo sbctl enroll-keys --microsoft
      '';
    };

    plymouth = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Graphical boot splash and quiet kernel output.";
    };
  };

  config = {
    boot = {
      kernelPackages = kernels.${cfg.kernel};

      loader = {
        limine = {
          enable = true;
          efiSupport = true;
          enableEditor = cfg.limine.editor;
          maxGenerations = cfg.limine.maxGenerations;
          secureBoot.enable = cfg.limine.secureBoot;
          # Cosmetics (optional):
          style.wallpapers = [ ../../../assets/limine/limine_wallpaper.jpg ];
          # extraConfig = ''
          #   interface_branding: NixOS
          # '';
        };
        efi.canTouchEfiVariables = true;
        timeout = 3;
        # make sure nothing else claims the ESP
        systemd-boot.enable = lib.mkForce false;
        grub.enable = lib.mkForce false;
      };

      # systemd in stage 1: faster, cleaner, and required for a good Plymouth experience
      initrd.systemd.enable = true;
      tmp.cleanOnBoot = true;

      plymouth.enable = cfg.plymouth;
      consoleLogLevel = lib.mkIf cfg.plymouth 3;
      initrd.verbose = lib.mkIf cfg.plymouth false;
      kernelParams = lib.optionals cfg.plymouth [
        "quiet"
        "splash"
        "loglevel=3"
        "rd.systemd.show_status=auto"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
    };

    # sched_ext: CachyOS-style latency-oriented scheduling from user space
    #   check with:  systemctl status scx.service
    services.scx = lib.mkIf cfg.scx.enable {
      enable = true;
      inherit (cfg.scx) scheduler;
    };

    environment.systemPackages = lib.optional cfg.limine.secureBoot pkgs.sbctl;
  };
}
