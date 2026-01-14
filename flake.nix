{
  description = "Kexfff's Flakes";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    illogical-flake = {
      url = "github:Kexfff/illogical-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    thorium-flake = {
      url = "github:Kexfff/thorium-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, illogical-flake, thorium-flake, ... }@inputs: {
    # Please replace my-nixos with your hostname
    nixosConfigurations.kexfff = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Import the previous configuration.nix we used,
        # so the old configuration file still takes effect
        ./core/configuration.nix

        home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # TODO replace ryan with your own username
            home-manager.users.kexfff = {
              imports = [
                ./home.nix
                illogical-flake.homeManagerModules.default
              ];
            };

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }

      ];
    };
  };
}
