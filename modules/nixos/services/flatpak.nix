# Flatpak with Flathub, managed declaratively by nix-flatpak.
{ config, lib, ... }:
let
  cfg = config.my.services.flatpak;
in
{
  options.my.services.flatpak = {
    enable = lib.mkEnableOption "Flatpak (Flathub)";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [
        "com.github.tchx84.Flatseal"
        "org.videolan.VLC"
      ];
      description = "Flatpak application IDs to keep installed.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      inherit (cfg) packages;
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
      # uninstallUnmanaged = true;  # remove flatpaks not listed above
    };

    xdg.portal.enable = true;
  };
}
