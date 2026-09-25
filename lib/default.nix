# Tiny helper library. Receives the flake's inputs/outputs from flake.nix.
{
  inputs,
  outputs,
  lib,
}:
{
  # Build a NixOS system from hosts/<hostname>/ + the shared module tree.
  mkHost =
    {
      hostname,
      system ? "x86_64-linux",
      extraModules ? [ ],
    }:
    lib.nixosSystem {
      inherit system;

      # Available as arguments in every NixOS module:  { inputs, outputs, hostname, ... }
      specialArgs = { inherit inputs outputs hostname; };

      modules = [
        ../modules/nixos # shared modules — every feature is gated by `my.*`
        ../hosts/${hostname} # per-machine switches + hardware-configuration.nix
        inputs.home-manager.nixosModules.home-manager # Home Manager as a NixOS module
        inputs.chaotic.nixosModules.default # CachyOS kernel, binary cache, overlay
        inputs.nix-index-database.nixosModules.nix-index # comma + command-not-found
        inputs.nix-flatpak.nixosModules.nix-flatpak # declarative flatpaks
        { networking.hostName = lib.mkDefault hostname; }
      ] ++ extraModules;
    };
}
