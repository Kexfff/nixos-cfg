# Podman (rootless, no daemon) + Distrobox.
{ config, pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = !config.virtualisation.docker.enable; # `docker` alias unless real Docker is on
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    podman-compose
    podman-tui
    distrobox
    boxbuddy # Distrobox GUI
  ];
}
