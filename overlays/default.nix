# Overlays applied to nixpkgs on every host (see modules/nixos/core/nix.nix).
{ ... }:
{
  # Custom packages from ./pkgs, usable as pkgs.<name>
  additions = final: _prev: import ../pkgs final;

  # Patch or override existing packages here
  modifications = _final: _prev: {
    # Example: run Steam with an extra library
    # steam = prev.steam.override { extraPkgs = p: [ p.libkrb5 ]; };
  };
}
