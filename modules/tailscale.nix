# Tailscale mesh VPN.  First run:  sudo tailscale up
{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
