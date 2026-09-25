{
  description = "Modular NixOS — Lix · Limine · Btrfs · CachyOS kernel · KDE Plasma 6 · Home Manager";

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

    inir = {
      url = "github:Kexfff/iNiR-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Extra community packages (ab-download-manager, thorium, …).
    custom-packages.url = "github:Rishabh5321/custom-packages-flake";

    # Declarative Flatpaks (services.flatpak.packages = [ ... ]).
    nix-flatpak.url = "github:gmodena/nix-flatpak?ref=latest";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      mylib = import ./lib {
        inherit inputs outputs;
        inherit (nixpkgs) lib;
      };
    in
    {
      # ── Hosts ──────────────────────────────────────────────────────────────
      #   sudo nixos-rebuild switch --flake .#desktop     (or simply: nh os switch)
      #   sudo nixos-rebuild switch --flake .#laptop
      # Adding a machine = new hosts/<name>/ directory + one line here.
      nixosConfigurations = {
        desktop = mylib.mkHost { hostname = "desktop"; };
        laptop = mylib.mkHost { hostname = "laptop"; };
      };

      # ── Reusable pieces (importable from other flakes) ─────────────────────
      nixosModules.default = import ./modules/nixos;
      homeModules.default = import ./modules/home;
      overlays = import ./overlays { inherit inputs; };
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

      # `nix fmt` formats the whole repository (RFC 166 style)
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      # `nix develop` (or direnv via .envrc): tooling for hacking on this config
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
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
        }
      );
    };
}
