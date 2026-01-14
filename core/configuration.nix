# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #./nvidia.nix
      ./intel.nix
      ../modules/services
      ../modules/programs
    ];





   environment.systemPackages = [
    inputs.thorium-flake.packages.${pkgs.system}.default
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.download-buffer-size = 524288000;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 3d";





  # Enable Hyprland
  programs.hyprland.enable = true;

  # Required services
  services.geoclue2.enable = true;  # For QtPositioning

  # System fonts (optional but recommended)
  fonts.packages = with pkgs; [
    rubik
    nerd-fonts.ubuntu
    nerd-fonts.jetbrains-mono
  ];




  # Define a user account.
  users.users.kexfff = {
    isNormalUser = true;
    description = "Aleksei";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.yakuake
      kdePackages.dolphin
      kdePackages.ark
      kdePackages.gwenview
    ];
  };

  # This value determines the NixOS release from which the default
  system.stateVersion = "25.05"; # Did you read the comment?

}
