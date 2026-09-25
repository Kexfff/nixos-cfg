# Declarative KDE Plasma settings via plasma-manager (only when my.desktop.plasma.enable).
#
# Discover option names for anything you tweak in System Settings with:
#   nix run github:nix-community/plasma-manager   # (rc2nix) dumps your current config as Nix
{ lib, osConfig, ... }:
{
  config = lib.mkIf osConfig.my.desktop.plasma.enable {
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

      configFile = {
        # File indexing eats IO on big game libraries
        baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      };
    };
  };
}
