{ config, pkgs, inputs, ... }:

{
  imports = [
    ./home/kitty/default.nix
    ./home/alacritty/default.nix
    ./home/git/default.nix
    ./home/gh/default.nix
    ./home/zsh/default.nix
    ./home/fastfetch/default.nix
  ];

  home.username = "kexfff";
  home.homeDirectory = "/home/kexfff";

  programs.inir.enable = true;

  # User Packages
  home.packages = with pkgs; [

    # archives
    zip
    xz
    unzip
    p7zip

    nix-tree
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "thorium-browser.desktop" ];
      "x-scheme-handler/http" = [ "thorium-browser.desktop" ];
      "x-scheme-handler/https" = [ "thorium-browser.desktop" ];
      "x-scheme-handler/about" = [ "thorium-browser.desktop" ];
      "x-scheme-handler/unknown" = [ "thorium-browser.desktop" ];
      "application/pdf" = [ "thorium-browser.desktop" ];
      "application/x-extension-htm" = [ "thorium-browser.desktop" ];
      "application/x-extension-html" = [ "thorium-browser.desktop" ];
      "application/x-extension-shtml" = [ "thorium-browser.desktop" ];
      "application/xhtml+xml" = [ "thorium-browser.desktop" ];
      "application/x-extension-xhtml" = [ "thorium-browser.desktop" ];
      "application/x-extension-xht" = [ "thorium-browser.desktop" ];
    };
  };

  home.sessionVariables = {
    BROWSER = "thorium-browser";
    DEFAULT_BROWSER = "thorium-browser";
    NIXOS_OZONE_WL = "1";
  };

  home.stateVersion = "25.05";
}
