# niri desktop around DM-Shell: niri + dmsh (the shell) + DM Manager (its settings app),
# with the configs from dm-desktop (github:Kexfff/dm-desktop) and the tools they use:
# walker/elephant (launcher, clipboard, power menu), swayidle + hyprlock (idle and lock),
# awww (wallpaper), kitty, screenshots/OCR/recording. Shows up as "niri" in SDDM.
#
# The configs come from the dm-desktop flake input, so edit them in that repo and run
# `nix flake update dm-desktop`. Two files are copied in once and then left to you,
# because DM Manager edits them in place: ~/.config/dmsh/config.kdl and
# ~/.config/swayidle/config. DM Manager's own ~/.config/niri/dm-manager.kdl is never
# touched by Nix.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  src = "${inputs.dm-desktop}/config";

  # dmsh's niri keybinds; its install.sh writes this file on other distros
  dmshKdl = pkgs.runCommand "dmsh.kdl" { } ''
    ${lib.getExe config.programs.dmsh.package} niri --no-autostart > $out
  '';
in
{
  imports = [
    inputs.dmsh.nixosModules.default
    inputs.dm-manager.nixosModules.default
  ];

  programs.niri = {
    enable = true;
    useNautilus = false; # GTK file chooser instead of pulling in Nautilus
  };

  programs.dmsh.enable = true; # user service, started with graphical-session.target
  programs.dm-manager.enable = true;
  programs.hyprlock.enable = true; # the lock screen (+ its PAM service)

  # Everything niri starts or binds in the dm-desktop config
  environment.systemPackages = with pkgs; [
    xwayland-satellite # X11 apps (niri starts it on demand)
    swayidle # idle → screen off / lock / lock before sleep
    awww # wallpaper daemon
    walker # launcher, clipboard history, power menu, wallpaper picker
    elephant # walker's backend
    kitty # terminal (Mod+T, Mod+Return)
    grim # OCR (Mod+Shift+X)
    slurp
    (tesseract.override {
      enableLanguages = [
        "eng"
        "rus"
      ];
    })
    wf-recorder # region recording (Mod+Shift+R)
    wl-clipboard
    libnotify # notify-send
    playerctl # media keys
    brightnessctl # brightness keys
    capitaine-cursors # cursor theme set in local.kdl
    darkly # Qt widget style set in local.kdl
  ];

  # dm-desktop's startup.kdl looks for the polkit agent in distro paths that don't
  # exist on NixOS, so it runs as a service with niri instead.
  systemd.user.services.niri-polkit-agent = {
    description = "Polkit authentication agent for niri";
    wantedBy = [ "niri.service" ];
    after = [ "niri.service" ];
    partOf = [ "niri.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
    };
  };

  home-manager.sharedModules = [
    (
      { lib, ... }:
      {
        # Read-only, linked from the dm-desktop repo
        xdg.configFile = {
          "niri/config.kdl".text = builtins.readFile "${src}/niri/config.kdl" + ''

            // DM Manager's settings (keyboard, cursor, …). It writes this file itself.
            include optional=true "dm-manager.kdl"
          '';
          "niri/dm-desktop".source = "${src}/niri/dm-desktop";
          "niri/local.kdl".source = "${src}/niri/local.kdl";
          "niri/dmsh.kdl".source = dmshKdl;
          "hypr/hyprlock.conf".source = "${src}/hypr/hyprlock.conf";
          "swayidle/lock".source = "${src}/swayidle/lock";
          "walker" = {
            source = "${src}/walker";
            recursive = true;
          };
          "elephant/menus" = {
            source = "${src}/elephant/menus";
            recursive = true;
          };
        };

        # Copied once, then yours (and DM Manager's) to edit
        home.activation.dmDesktopSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          seed() {
            if [ ! -e "$2" ]; then
              run mkdir -p "$(dirname "$2")"
              run install -m 644 "$1" "$2"
            fi
          }
          seed ${src}/dmsh/config.kdl "$HOME/.config/dmsh/config.kdl"
          seed ${src}/swayidle/config "$HOME/.config/swayidle/config"
        '';
      }
    )
  ];
}
