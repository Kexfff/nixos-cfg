# qylock — SDDM login themes + Quickshell lockscreen (system half).
#
# Imports the flake input's NixOS module (`inputs.qylock`): installs the theme
# collection from the Nix store, wires the Qt6 QML deps into the SDDM greeter and
# exposes `qylock-lock` for the Quickshell lockscreen.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.my.desktop.qylock;
in
{
  imports = [ inputs.qylock.nixosModules.default ];

  options.my.desktop.qylock = {
    enable = lib.mkEnableOption "qylock SDDM themes and Quickshell lockscreen";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "pixel-cyberpunk";
      description = "Theme directory name under qylock's themes/ to activate.";
    };

    sddm.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the SDDM themes and set the active login theme.";
    };

    quickshell.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install the `qylock-lock` Quickshell lockscreen wrapper.";
    };

    themeOptions = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Per-theme tweaks applied to theme.conf at build time.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.qylock = {
      enable = true;
      inherit (cfg)
        theme
        sddm
        quickshell
        themeOptions
        ;
    };

    # Background videos (SDDM via Qt Multimedia / Quickshell) need the
    # GStreamer plugins system-wide on NixOS.
    environment.systemPackages = with pkgs.gst_all_1; [
      gstreamer
      gst-plugins-base
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
    ];
  };
}
