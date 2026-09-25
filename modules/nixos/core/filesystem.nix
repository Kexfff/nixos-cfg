# Btrfs: mount tuning, monthly scrub, TRIM.
# Deliberately NO snapshot tooling (no snapper / btrbk / btrfs-assistant).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.filesystem.btrfs;
in
{
  options.my.filesystem.btrfs = {
    mountpoints = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/" ];
      example = [
        "/"
        "/home"
        "/nix"
      ];
      description = ''
        Btrfs mount points declared in hardware-configuration.nix that receive
        `extraMountOptions`. Only list mount points that really exist there.
      '';
    };

    extraMountOptions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "compress=zstd"
        "noatime"
      ];
      description = "Added on top of the generated options (subvol=… is preserved).";
    };

    scrub = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      interval = lib.mkOption {
        type = lib.types.str;
        default = "monthly";
      };
      fileSystems = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "/" ];
        description = "One entry per *filesystem* (subvolumes share a scrub), so usually just \"/\".";
      };
    };
  };

  config = {
    boot.supportedFilesystems = [ "btrfs" ];

    # Lists merge, so this adds compress=zstd,noatime to the generated subvol=… options
    fileSystems = lib.genAttrs cfg.mountpoints (_: {
      options = cfg.extraMountOptions;
    });

    services.btrfs.autoScrub = lib.mkIf cfg.scrub.enable {
      enable = true;
      inherit (cfg.scrub) interval fileSystems;
    };

    # SSD TRIM (btrfs uses discard=async by default; fstrim is belt and braces)
    services.fstrim.enable = true;

    environment.systemPackages = with pkgs; [
      btrfs-progs
      compsize # `sudo compsize /` → real compression ratio
    ];

    # Safety net: refuse to build while the placeholder hardware config is still in place
    assertions = [
      {
        assertion =
          let
            dev = config.fileSystems."/".device;
          in
          dev == null || !(lib.hasInfix "CHANGE-ME" dev);
        message = ''
          hosts/${config.networking.hostName}/hardware-configuration.nix is still the placeholder.
          Copy your real one:  sudo cp /etc/nixos/hardware-configuration.nix hosts/${config.networking.hostName}/
        '';
      }
    ];
  };
}
