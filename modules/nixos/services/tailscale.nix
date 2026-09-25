# Tailscale mesh VPN.  First run:  sudo tailscale up
{ config, lib, ... }:
{
  options.my.services.tailscale.enable = lib.mkEnableOption "Tailscale";

  config = lib.mkIf config.my.services.tailscale.enable {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
    };
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
  };
}
