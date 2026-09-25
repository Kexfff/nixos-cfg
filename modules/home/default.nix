# Shared Home Manager configuration, applied to `my.user` on every host.
# Modules read the system's switches through `osConfig.my.*`, so e.g. the MangoHud
# config only appears on hosts where my.gaming.enable = true.
# Personal extras go to users/<name>/default.nix.
{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  imports = [
    ./shell.nix
    ./fastfetch.nix
    ./git.nix
    ./editors.nix
    ./development.nix
    ./gaming.nix
    ./plasma.nix
    ./inir.nix
  ];

  programs.home-manager.enable = true;

  # Same state version as the system — do not bump after the first install
  home.stateVersion = lib.mkDefault osConfig.system.stateVersion;

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

  home.packages = with pkgs; [
    tealdeer # `tldr <cmd>`
    glow # markdown in the terminal
    yazi # terminal file manager
  ];

  # Restart changed user services on `switch`
  systemd.user.startServices = "sd-switch";
}
