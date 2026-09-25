# iNiR — the Niri/Quickshell desktop shell (system half).
#
# Imports the flake input's NixOS module (`inputs.inir`): niri, PipeWire,
# NetworkManager, xdg portals, polkit, ydotool, group memberships and the
# systemd user service. The user half lives in modules/home/inir.nix.
{
  config,
  lib,
  inputs,
  ...
}:
let
  cfg = config.my.desktop.inir;
in
{
  imports = [ inputs.inir.nixosModules.inir ];

  options.my.desktop.inir = {
    enable = lib.mkEnableOption "the iNiR (Niri + Quickshell) desktop shell";

    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ config.my.user.name ];
      description = "Users added to the input/video/i2c/ydotool/networkmanager groups.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.inir = {
      enable = true;
      inherit (cfg) users;
    };
  };
}
