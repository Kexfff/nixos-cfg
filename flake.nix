{
  description = "Kexfff's Flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    thorium-flake = {
      url = "github:Kexfff/thorium-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    inir-flake = {
        url = "github:Kexfff/iNiR-flake";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, thorium-flake, inir-flake, ... }@inputs: {
    nixosConfigurations.kexfff = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./core/configuration.nix

        home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };

            home-manager.users.kexfff = {
              imports = [
                ./home.nix
                inir-flake.homeManagerModules.default
              ];
            };

          }

      ];
    };
  };
}
