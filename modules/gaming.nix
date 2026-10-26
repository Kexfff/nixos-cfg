# Gaming: Steam + Proton-GE, Gamescope, GameMode, MangoHud, launchers, controllers.
{ pkgs, ... }:
{
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
  services.udev.packages = [ pkgs.game-devices-udev-rules ];
  # Out-of-tree Xbox drivers. If one fails to build against the Clang-built kernel,
  # use boot.kernelPackages = pkgs.linuxPackages_cachyos-gcc in the host.
  # hardware.xone.enable = true;     # Xbox One/Series wireless dongle
  # hardware.xpadneo.enable = true;  # Xbox controllers over Bluetooth

  # Wine/Proton NTSYNC fast path (built into the CachyOS kernel)
  boot.kernelModules = [ "ntsync" ];

  environment.systemPackages = with pkgs; [
    # launchers besides Steam
    heroic # Epic / GOG / Amazon
    lutris
    prismlauncher # Minecraft
    bottles

    mangohud
    goverlay # MangoHud GUI
    protonup-qt # manage Proton-GE / Luxtorpeda versions
    umu-launcher # run non-Steam games with Proton
    vesktop # Discord with working Wayland screen-share
    winetricks
    wineWow64Packages.staging
    steam-run # run random Linux binaries in Steam's FHS env
  ];

  # MangoHud defaults (Home Manager). Enable per game with `mangohud %command%`
  # in Steam launch options, or MANGOHUD=1.
  home-manager.sharedModules = [
    {
      programs.mangohud = {
        enable = true;
        enableSessionWide = false;
        settings = {
          toggle_hud = "Shift_R+F12";
          position = "top-left";
          font_size = 20;
          fps = true;
          frametime = true;
          frame_timing = true;
          cpu_stats = true;
          cpu_temp = true;
          gpu_stats = true;
          gpu_temp = true;
          ram = true;
          vram = true;
          gamemode = true;
          wine = true;
          vulkan_driver = true;
        };
      };
    }
  ];
}
