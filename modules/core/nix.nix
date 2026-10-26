# Nix itself: Lix, flakes, binary caches, garbage collection, and the tooling that
# makes day-to-day NixOS pleasant.
#
#   nh os switch            rebuild with a pretty diff (nom + nvd built in)
#   nh search <pkg>         fast package search
#   nh clean all            garbage collect (also runs weekly, see below)
#   , <cmd>                 run any program without installing it (comma)
#   nix-tree                why is my closure so big?
#   nix-inspect             TUI to browse the evaluated config
#   manix <query>           search option/function docs offline
#   nurl <url> / nix-init   generate fetchers / scaffold a package
{
  lib,
  pkgs,
  inputs,
  username,
  ...
}:
{
  imports = [ inputs.nix-index-database.nixosModules.nix-index ];

  nix = {
    package = pkgs.lixPackageSets.stable.lix;

    # Flakes only — no channels. Legacy tools (`nix-shell -p`, `<nixpkgs>`) are
    # pointed at the very same nixpkgs the system was built from.
    channel.enable = false;
    registry.nixpkgs.flake = inputs.nixpkgs;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [
        "root"
        "@wheel"
      ];
      warn-dirty = false;
      # keep build-time deps of dev shells so `nix develop` stays fast after a GC
      keep-outputs = true;
      keep-derivations = true;
      connect-timeout = 5;
      log-lines = 50;
      # chaotic-nyx registers its own cache via its module (core/boot.nix)
      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.numtide.com" # llm-agents
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      ];
    };

    # Hard-link identical store files once a week
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  # ── Garbage collection ───────────────────────────────────────────────────
  # `nh clean` instead of nix.gc: it also cleans user/Home Manager profiles and
  # gcroots. (nixpkgs asserts that nh.clean and nix.gc.automatic are not both on.)
  programs.nh = {
    enable = true;
    # Where this repo lives (exported as NH_FLAKE, so `nh os switch` needs no arguments)
    flake = lib.mkDefault "/home/${username}/nixos-cfg";
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --keep-since 7d";
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    # Custom packages from pkgs/ as pkgs.<name>. Package overrides go here too:
    #   (final: prev: { steam = prev.steam.override { ... }; })
    overlays = [ (final: _prev: import ../../pkgs final) ];
  };

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
