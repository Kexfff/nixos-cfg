# KDE Plasma 6 on Wayland with SDDM.
# Declarative Plasma *settings* live in modules/home/plasma.nix (plasma-manager).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktop.plasma;
in
{
  options.my.desktop.plasma = {
    enable = lib.mkEnableOption "KDE Plasma 6 (Wayland) with SDDM";

    excludePackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs.kdePackages; [
        elisa
        khelpcenter
      ];
      description = "Default Plasma applications you don't want.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional desktop applications.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true; # keeps an X11 session as fallback + xkb plumbing

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        wayland.compositor = "kwin";
        autoNumlock = true;
      };
      defaultSession = "plasma";
    };

    services.desktopManager.plasma6.enable = true;
    environment.plasma6.excludePackages = cfg.excludePackages;

    programs = {
      kdeconnect.enable = true; # phone integration (opens the needed firewall ports)
      partition-manager.enable = true;
      dconf.enable = true; # GTK apps remember their settings
      firefox = {
        enable = true;
        nativeMessagingHosts.packages = [ pkgs.kdePackages.plasma-browser-integration ];
      };
    };

    environment.systemPackages =
      (with pkgs.kdePackages; [
        kate
        kcalc
        filelight
        kolourpaint
        ksystemlog
        isoimagewriter
        kio-admin # "Open as administrator" in Dolphin
        kwalletmanager
        okular
        yakuake
        sddm-kcm
      ])
      ++ (with pkgs; [
        wl-clipboard
        xdg-utils
        haruna # mpv-based video player with a KDE face
      ])
      ++ cfg.extraPackages;

    # Unlock KWallet with the login password
    security.pam.services.sddm.kwallet.enable = true;

    # Electron / Chromium apps: native Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    xdg.portal.xdgOpenUsePortal = true;
    services.udisks2.enable = true;
  };
}
