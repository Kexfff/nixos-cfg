# Btrfs: mount tuning, monthly scrub, TRIM.
# Deliberately NO snapshot tooling (no snapper / btrbk / btrfs-assistant).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Added on top of the options in hardware-configuration.nix (subvol=… is kept).
  # Every host must have these three mount points there.
  tuned = {
    options = [
      "compress=zstd"
      "noatime"
    ];
  };
in
{
  boot.supportedFilesystems = [ "btrfs" ];

  fileSystems = {
    "/" = tuned;
    "/home" = tuned;
    "/nix" = tuned;
  };

  # One entry per filesystem (subvolumes share a scrub)
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # SSD TRIM (btrfs already uses discard=async; fstrim is belt and braces)
  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    btrfs-progs
    compsize # `sudo compsize /` → real compression ratio
  ];

  # Refuse to build while a host still has the placeholder hardware config
  assertions = [
    {
      assertion =
        let
          dev = config.fileSystems."/".device;
        in
        dev == null || !(lib.hasInfix "CHANGE-ME" dev);
      message = ''
        hosts/${config.networking.hostName}/hardware-configuration.nix is still the placeholder.
        Generate the real one:  sudo nixos-generate-config --show-hardware-config > hosts/${config.networking.hostName}/hardware-configuration.nix
      '';
    }
  ];
}
