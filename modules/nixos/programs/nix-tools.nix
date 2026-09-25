# Quality-of-life tooling that makes day-to-day NixOS pleasant. Always on.
#
#   nh os switch            rebuild with a pretty diff (nom + nvd built in)
#   nh search <pkg>         fast package search
#   nh clean all            garbage collect (also runs weekly, see core/nix.nix)
#   , <cmd>                 run any program without installing it (comma)
#   nix-tree                why is my closure so big?
#   nvd diff /run/booted-system /run/current-system
#   nix-inspect             TUI to browse the evaluated config
#   manix <query>           search option/function docs offline
#   nurl <url>              generate fetcher expressions with hashes
#   nix-init                scaffold a package derivation
#   statix check / deadnix  lint this repo
{ pkgs, ... }:
{
  # comma + command-not-found powered by the pre-built nix-index database
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;
  programs.command-not-found.enable = false; # channel-based; conflicts with nix-index

  # Double-click AppImages, `appimage-run` in the shell
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = with pkgs; [
    nh
    nix-output-monitor
    nvd
    nix-tree
    nix-inspect
    nix-diff
    manix
    nix-search-cli
    nurl
    nix-init
    nix-prefetch-git
    cachix
    # Nix language tooling (also picked up by editors)
    nixd
    nixfmt
    statix
    deadnix
  ];
}
