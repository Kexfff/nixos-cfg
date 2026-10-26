# The user account (NixOS side) + Home Manager wiring. Imported on every host by flake.nix.
# Your Home Manager config starts at ./home.nix.
{
  pkgs,
  inputs,
  username,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  users.mutableUsers = true; # `passwd` keeps working

  users.users.${username} = {
    isNormalUser = true;
    description = "Aleksei";
    shell = pkgs.fish;
    # Feature modules add their own groups (docker, libvirtd, scanner, …)
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
      "render"
    ];
    # Declarative password: hashedPasswordFile = "/run/secrets/…";  (mkpasswd -m yescrypt)
    # SSH keys allowed to log in (with modules/ssh.nix):
    openssh.authorizedKeys.keys = [ ];
  };

  # The login shell must be enabled system-wide (adds it to /etc/shells)
  programs.fish.enable = true;

  home-manager = {
    useGlobalPkgs = true; # same nixpkgs + overlays as the system
    useUserPackages = true;
    backupFileExtension = "hm-bak"; # never fail on pre-existing dotfiles
    overwriteBackup = true; # and never fail on an existing .hm-bak either
    extraSpecialArgs = { inherit inputs; };
    users.${username} = ./home.nix;
  };
}
