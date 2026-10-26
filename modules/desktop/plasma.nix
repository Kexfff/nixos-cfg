# KDE Plasma 6 on Wayland with SDDM, plus declarative Plasma settings (plasma-manager).
{ pkgs, inputs, ... }:
{
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
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    khelpcenter
  ];

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
    ]);

  # Unlock KWallet with the login password
  security.pam.services.sddm.kwallet.enable = true;

  # Electron / Chromium apps: native Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal.xdgOpenUsePortal = true;
  services.udisks2.enable = true;

  # ── Plasma settings (Home Manager) ───────────────────────────────────────
  # Find option names for anything you change in System Settings with:
  #   nix run github:nix-community/plasma-manager   # (rc2nix) dumps current config as Nix
  home-manager.sharedModules = [
    inputs.plasma-manager.homeModules.plasma-manager
    {
      programs.plasma = {
        enable = true;

        # Only manage what is declared here; whatever you change in System Settings stays.
        overrideConfig = false;

        workspace = {
          lookAndFeel = "org.kde.breezedark.desktop";
          clickItemTo = "select";
        };

        kwin = {
          virtualDesktops = {
            number = 4;
            rows = 1;
          };
          nightLight = {
            enable = true;
            mode = "times";
            temperature = {
              day = 6500;
              night = 4200;
            };
            time = {
              morning = "07:00";
              evening = "20:00";
            };
          };
        };

        hotkeys.commands."launch-konsole" = {
          name = "Launch Konsole";
          key = "Meta+Return";
          command = "konsole";
        };

        shortcuts = {
          kwin."Overview" = "Meta+Tab";
          kwin."Window Maximize" = "Meta+Up";
        };

        # File indexing eats IO on big game libraries
        configFile.baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      };
    }
  ];
}
