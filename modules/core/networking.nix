# NetworkManager, firewall, DNS, mDNS, firmware.
{ ... }:
{
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
    # firewall.allowedTCPPorts = [ ];
  };

  # systemd-resolved: DNS caching + per-link DNS (plays well with NetworkManager and VPNs)
  services.resolved.enable = true;

  # Don't make boot wait for the network
  systemd.services.NetworkManager-wait-online.enable = false;

  # mDNS: printers, KDE Connect, *.local hosts
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Wi-Fi / Bluetooth / GPU firmware blobs
  hardware.enableRedistributableFirmware = true;
}
