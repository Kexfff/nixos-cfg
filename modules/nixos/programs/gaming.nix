# Gaming: Steam + Proton-GE, Gamescope, GameMode, MangoHud, launchers, controllers.
# MangoHud's per-user config lives in modules/home/gaming.nix.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.gaming;
in
{
  options.my.gaming = {
    enable = lib.mkEnableOption "the gaming stack";

    launchers = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        heroic # Epic / GOG / Amazon
        lutris
        prismlauncher # Minecraft
        bottles
      ];
      description = "Game launchers besides Steam.";
    };

    ntsync = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Load the ntsync module (Wine/Proton NTSYNC fast path; built into the CachyOS kernel).";
    };

    # Both are out-of-tree kernel modules. The default CachyOS kernel is Clang/LTO-built;
    # if one fails to build, switch to my.boot.kernel = "cachyos-gcc".
    xone.enable = lib.mkEnableOption "xone (Xbox One/Series wireless dongle driver)";
    xpadneo.enable = lib.mkEnableOption "xpadneo (Xbox controllers over Bluetooth)";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true; # "Steam (gamescope)" session in SDDM — Big Picture on a TV
      protontricks.enable = true;
      extest.enable = true; # Steam Input for native Wayland games
      extraCompatPackages = [ pkgs.proton-ge-bin ]; # shows up as "GE-Proton" in Steam
      extraPackages = with pkgs; [
        mangohud
        gamemode
      ];
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
          inhibit_screensaver = 1;
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    # Controllers
    hardware.steam-hardware.enable = true;
    hardware.uinput.enable = true;
    hardware.xone.enable = cfg.xone.enable;
    hardware.xpadneo.enable = cfg.xpadneo.enable;
    services.udev.packages = [ pkgs.game-devices-udev-rules ];

    boot.kernelModules = lib.optional cfg.ntsync "ntsync";

    environment.systemPackages =
      with pkgs;
      [
        mangohud
        goverlay # MangoHud GUI
        protonup-qt # manage Proton-GE / Luxtorpeda versions
        umu-launcher # run non-Steam games with Proton
        vesktop # Discord with working Wayland screen-share
        winetricks
        wineWow64Packages.staging
        steam-run # run random Linux binaries in Steam's FHS env
      ]
      ++ cfg.launchers;
  };
}
