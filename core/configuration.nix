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
    inputs.thorium-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  nixpkgs.config.allowUnfree = true;
  nix.settings.download-buffer-size = 524288000;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.settings.trusted-users = [ "root" "kexfff" ];
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 3d";




  # Required services
  services.geoclue2.enable = true;  # For QtPositioning
  programs.niri.enable = true;
  # System fonts
  fonts.packages = with pkgs; [
    rubik
    nerd-fonts.ubuntu
    nerd-fonts.jetbrains-mono
  ];




  # User account
  users.users.kexfff = {
    isNormalUser = true;
    description = "Aleksei";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      kdePackages.kate
      kdePackages.yakuake
      kdePackages.dolphin
      kdePackages.ark
      kdePackages.gwenview
    ];
  };

  programs.zsh.enable = true;

  system.stateVersion = "25.05";

}
