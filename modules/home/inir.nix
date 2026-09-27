# iNiR — the Niri/Quickshell desktop shell (user half).
#
# The flake input is declared in flake.nix (`inputs.inir`); importing the module
# below injects a `programs.inir.package` built against this config's nixpkgs,
# so `programs.inir.enable = true` is genuinely all that is needed to activate.
#
# Gated by the same switch as the system half (modules/nixos/desktop/inir.nix),
# so `my.desktop.inir.enable = true;` on a host turns on both.
#
# Further shell configuration goes under `programs.inir.*` — the full option
# list is defined in nix/options.nix of the inir flake.
{
  lib,
  osConfig,
  inputs,
  ...
}:
{
  imports = [ inputs.inir.homeManagerModules.inir ];

  config = lib.mkIf osConfig.my.desktop.inir.enable {
    home.pointerCursor = lib.mkDefault {
      enable = true;
    };
    programs.inir = {
      enable = true;

      #dots.mode = "symlink";

      # Add/shell settings here, e.g.:
      # mascot.enable = true;        # bundled Kira mascot pack
      fonts.enable = true; # shell font set
      polkitAgent.enable = true; # graphical polkit prompt
      service.compositor = "niri";
      #extraPackages = with pkgs [ ];
      # environment = { INIR_LOG_LEVEL = "debug"; };
    };
  };
}
