# qylock — SDDM login themes + Quickshell lockscreen.
#
# The flake input's module installs the theme collection, wires the Qt6 QML deps
# into the SDDM greeter and can expose `qylock-lock` for the Quickshell lockscreen.
{ pkgs, inputs, ... }:
{
  imports = [ inputs.qylock.nixosModules.default ];

  programs.qylock = {
    enable = true;
    theme = "pixel-cyberpunk"; # directory name under qylock's themes/
    sddm.enable = true; # install the SDDM themes and set the active login theme
    quickshell.enable = false; # `qylock-lock` Quickshell lockscreen wrapper
    # themeOptions = { };  # per-theme tweaks applied to theme.conf at build time
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
}
