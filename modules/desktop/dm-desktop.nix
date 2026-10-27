# niri desktop around DM-Shell: niri + dmsh (the shell) + DM Manager (its settings app),
# with the configs in dotfiles/ (taken from github:Kexfff/dm-desktop) and the tools they
# use: walker/elephant (launcher, clipboard, power menu), swayidle + hyprlock (idle and
# lock), awww (wallpaper), kitty, screenshots/OCR/recording. Shows up as "niri" in SDDM.
#
# ~/.config links straight into this repo's checkout (programs.nh.flake), so editing a
# file in dotfiles/ takes effect at once; niri reloads its config on save. Two files are
# copied in once instead and then left to you, because DM Manager edits them in place:
# ~/.config/dmsh/config.kdl and ~/.config/swayidle/config. DM Manager's own
# ~/.config/niri/dm-manager.kdl is never touched by Nix.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  # The checkout on disk, not a store copy, so the links follow your edits
  dotfiles = "${config.programs.nh.flake}/dotfiles";

  # dmsh's niri keybinds (its install.sh writes this file on other distros)
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

  # Everything niri starts or binds in dotfiles/niri
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
    capitaine-cursors # cursor theme (pick it in DM Manager)
    darkly # Qt widget style set in dotfiles/niri/dm-desktop/base.kdl
  ];

  # Polkit agent for password prompts, started with niri
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
      { config, lib, ... }:
      let
        link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
      in
      {
        xdg.configFile = {
          "niri/config.kdl".source = link "niri/config.kdl";
          "niri/dm-desktop".source = link "niri/dm-desktop";
          "niri/local.kdl".source = link "niri/local.kdl";
          "niri/dmsh.kdl".source = dmshKdl;
          "hypr/hyprlock.conf".source = link "hypr/hyprlock.conf";
          "swayidle/lock".source = link "swayidle/lock";
          # File by file: walker and elephant keep their own state next to these
          "walker/config.toml".source = link "walker/config.toml";
          "walker/themes/dmsh/style.css".source = link "walker/themes/dmsh/style.css";
          "elephant/menus/power.toml".source = link "elephant/menus/power.toml";
          "elephant/menus/wallpapers.lua".source = link "elephant/menus/wallpapers.lua";
        };

        # Copied once, then yours (and DM Manager's) to edit
        home.activation.dmDesktopSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          seed() {
            if [ ! -e "$2" ]; then
              run mkdir -p "$(dirname "$2")"
              run install -m 644 "$1" "$2"
            fi
          }
          seed ${../../dotfiles/dmsh/config.kdl} "$HOME/.config/dmsh/config.kdl"
          seed ${../../dotfiles/swayidle/config} "$HOME/.config/swayidle/config"
        '';
      }
    )
  ];
}
