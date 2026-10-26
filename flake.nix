{
  description = "NixOS — Lix · Limine · Btrfs · CachyOS kernel · KDE Plasma 6 · Home Manager";

  inputs = {
    # Rolling release. Swap for "github:NixOS/nixpkgs/nixos-25.11" if you want stable.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # CachyOS kernel (+ sched_ext, nvidia_cachyos, bleeding-edge pkgs) with a binary cache.
    # !! Do NOT add `inputs.nixpkgs.follows = "nixpkgs"` here: it changes the kernel's
    #    dependency closure, invalidates the cache and you would compile the kernel yourself.
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Declarative KDE Plasma settings through Home Manager.
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Weekly pre-built nix-index database → `comma` (`, htop`) and command-not-found hints.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SDDM login themes + Quickshell lockscreen.
    qylock.url = "github:Darkkal44/qylock";

    # Extra community packages (ab-download-manager, thorium, …).
    custom-packages.url = "github:Rishabh5321/custom-packages-flake";

    # Declarative Flatpaks (services.flatpak.packages = [ ... ]).
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      username = "kexfff";

      # A host = hosts/<hostname>/ + the user from users/<username>/.
      # `inputs` and `username` are available as arguments in every module.
      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs username; };
          modules = [
            ./hosts/${hostname}
            ./users/${username}
            { networking.hostName = hostname; }
          ];
        };
    in
    {
      #   nh os switch                                  (on the machine itself)
      #   sudo nixos-rebuild switch --flake .#laptop
      nixosConfigurations = {
        desktop = mkHost "desktop";
        laptop = mkHost "laptop";
      };

      # Custom packages from ./pkgs (also available as pkgs.<name> on the system)
      packages.${system} = import ./pkgs pkgs;

      # `nix fmt` formats the whole repository (RFC 166 style)
      formatter.${system} = pkgs.nixfmt;

      # `nix develop` (or direnv via .envrc): tooling for hacking on this config
      devShells.${system}.default = pkgs.mkShell {
        name = "nixos-config";
        packages = with pkgs; [
          git
          nh
          nix-output-monitor
          nvd
          nixd
          nixfmt
          statix
          deadnix
        ];
      };
    };
}
