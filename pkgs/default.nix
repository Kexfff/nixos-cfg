# Custom packages. Available as `pkgs.<name>` on every host (overlay in
# modules/core/nix.nix) and as `nix build .#<name>`.
# Scaffold new ones with `nix-init` / `nurl`.
pkgs: {
  # `nixos-gens` prints boot generations + store size
  nixos-gens = pkgs.writeShellApplication {
    name = "nixos-gens";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.nix
    ];
    text = ''
      echo "== System generations =="
      nix-env --list-generations --profile /nix/var/nix/profiles/system
      echo
      echo "== Store =="
      du -sh /nix/store 2>/dev/null || true
    '';
  };
}
