# Per-user development helpers (only when my.development.enable).
{
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  config = lib.mkIf osConfig.my.development.enable {
    # Per-project environments: put `use flake` in a project's .envrc and it just works
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };

    home.packages = with pkgs; [
      devenv # batteries-included dev environments (devenv.sh)
      codex
    ];

    # A minimal flake template for new projects:  nix flake init -t ~/.config/nix-templates#basic
    xdg.configFile."nix-templates/flake.nix".text = ''
      {
        outputs = _: {
          templates.basic = {
            path = ./basic;
            description = "devShell with direnv";
          };
        };
      }
    '';
    xdg.configFile."nix-templates/basic/flake.nix".text = ''
      {
        inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        outputs = { nixpkgs, ... }:
          let
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
          in {
            devShells.x86_64-linux.default = pkgs.mkShell {
              packages = with pkgs; [ ];
            };
          };
      }
    '';
    xdg.configFile."nix-templates/basic/.envrc".text = "use flake\n";
  };
}
