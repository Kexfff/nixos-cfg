# Per-user Home Manager settings for the user "user".
#
# Rename this directory to match `my.user.name` in your host file — it is imported
# automatically when it exists. Anything personal goes here (extra apps, dotfiles,
# SSH hosts); everything shared lives in modules/home/.
{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    # CHANGEME — your personal apps
    #keepassxc
    obsidian
    # mpv is provided by the iNiR runtime set (with mpv-mpris); adding
    # pkgs.mpv here would conflict in home-manager-path's buildEnv.
    floorp-bin
    telegram-desktop
    qbittorrent
    libreoffice
    mission-center
    vlc
    inputs.custom-packages.packages.${pkgs.stdenv.hostPlatform.system}.ab-download-manager
  ];

  # Example: extra git config only for you
  # programs.git.settings.github.user = "your-github-handle";

  # Example: dotfile you don't want to translate to Nix (yet)
  # home.file.".config/foo/foo.conf".source = ./foo.conf;
}
