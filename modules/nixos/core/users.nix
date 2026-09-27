# The primary user account + Home Manager wiring.
#
# Shared Home Manager modules:  modules/home/
# Per-user extras:              users/<name>/default.nix (imported automatically if present)
{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
let
  cfg = config.my.user;
  userDir = ../../../users/${cfg.name};
in
{
  options.my.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "user";
      description = "Login name of the primary user.";
    };
    fullName = lib.mkOption {
      type = lib.types.str;
      default = "NixOS User";
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = "user@example.com";
      description = "Used for git.";
    };
    shell = lib.mkOption {
      type = lib.types.enum [
        "zsh"
        "fish"
        "bash"
      ];
      default = "zsh";
    };
    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    initialPassword = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Only used the first time the account is created (existing users keep their
        password). Null leaves password provisioning to the existing system or
        installer; use hashedPasswordFile for declarative provisioning.
      '';
    };
    hashedPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Path to a file with a `mkpasswd -m yescrypt` hash (e.g. from sops/agenix).";
    };
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys allowed to log in as this user.";
    };
  };

  config = {
    users.mutableUsers = true; # `passwd` keeps working

    users.users.${cfg.name} = {
      isNormalUser = true;
      description = cfg.fullName;
      shell = pkgs.${cfg.shell};
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
        "audio"
        "input"
        "render"
      ]
      ++ cfg.extraGroups;
      initialPassword = lib.mkIf (cfg.hashedPasswordFile == null) cfg.initialPassword;
      inherit (cfg) hashedPasswordFile;
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    # The login shell must be enabled system-wide (adds it to /etc/shells)
    programs.zsh.enable = cfg.shell == "zsh";
    programs.fish.enable = cfg.shell == "fish";

    home-manager = {
      useGlobalPkgs = true; # same nixpkgs + overlays as the system
      useUserPackages = true;
      backupFileExtension = "hm-bak"; # never fail on pre-existing dotfiles
      overwriteBackup = true; # and never fail on an existing .hm-bak either
      extraSpecialArgs = { inherit inputs outputs; };
      sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];
      users.${cfg.name} = {
        imports = [ ../../home ] ++ lib.optional (builtins.pathExists userDir) userDir;
      };
    };
  };
}
