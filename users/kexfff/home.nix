# Home Manager config for kexfff — the same on every host.
# Personal apps go in home.packages below. Feature modules (gaming, plasma, …)
# add their own Home Manager bits through home-manager.sharedModules.
{
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:
{
  imports = [
    ./shell.nix
    ./git.nix
    ./editors.nix
    ./fastfetch.nix
  ];

  home.packages = with pkgs; [
    obsidian
    floorp-bin
    telegram-desktop
    qbittorrent
    libreoffice
    mission-center
    vlc
    mpv
    #keepassxc
    inputs.custom-packages.packages.${pkgs.stdenv.hostPlatform.system}.ab-download-manager

    tealdeer # `tldr <cmd>`
    glow # markdown in the terminal
    yazi # terminal file manager
  ];

  # Dotfile you don't want to translate to Nix (yet):
  # home.file.".config/foo/foo.conf".source = ./foo.conf;

  home.sessionVariables = {
    EDITOR = "kate";
    VISUAL = "kate";
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    # legacy `nix-shell -p` / `nix-env` should see unfree packages too
    configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";
  };

  programs.home-manager.enable = true;

  # Restart changed user services on `switch`
  systemd.user.startServices = "sd-switch";

  # Same state version as the system — do not bump after the first install
  home.stateVersion = lib.mkDefault osConfig.system.stateVersion;
}
