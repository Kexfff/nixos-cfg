# Docker + Distrobox.
{ pkgs, username, ... }:
{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    # overlay2 (default) on purpose — the "btrfs" storage driver uses subvolume
    # snapshots, which this config avoids.
  };
  users.users.${username}.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
    distrobox
    boxbuddy # Distrobox GUI
  ];
}
