# Nix itself: Lix, flakes, binary caches, garbage collection, store optimisation.
{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
let
  cfg = config.my.nix;
in
{
  options.my.nix = {
    useLix = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Use Lix (packaged in nixpkgs) as the Nix implementation.";
    };

    flakePath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos";
      example = "/home/user/nixos-config";
      description = ''
        Directory containing this flake on the machine. Exported as NH_FLAKE so
        `nh os switch` and `nh clean` work without arguments.
      '';
    };

    gc = {
      dates = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        description = "systemd calendar expression for automatic garbage collection.";
      };
      keepGenerations = lib.mkOption {
        type = lib.types.ints.positive;
        default = 5;
        description = "Always keep at least this many of the newest generations.";
      };
      keepSince = lib.mkOption {
        type = lib.types.str;
        default = "7d";
        description = "Keep every generation newer than this, regardless of count.";
      };
    };
  };

  config = {
    nix = {
      package = lib.mkIf cfg.useLix pkgs.lixPackageSets.stable.lix;

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
        # chaotic-nyx registers its own cache via its module
        substituters = [ "https://nix-community.cachix.org" ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };

      # Hard-link identical store files once a week
      optimise = {
        automatic = true;
        dates = [ "weekly" ];
      };
    };

    # ── Garbage collection ─────────────────────────────────────────────────
    # Handled by `nh clean all`, which is smarter than nix.gc: it also cleans user
    # and Home Manager profiles + gcroots, and keeps the N newest generations.
    # (nixpkgs asserts that nh.clean and nix.gc.automatic are not both enabled.)
    programs.nh = {
      enable = true;
      flake = cfg.flakePath;
      clean = {
        enable = true;
        dates = cfg.gc.dates;
        extraArgs = "--keep ${toString cfg.gc.keepGenerations} --keep-since ${cfg.gc.keepSince}";
      };
    };

    nixpkgs = {
      config.allowUnfree = true;
      overlays = builtins.attrValues outputs.overlays;
    };
  };
}
