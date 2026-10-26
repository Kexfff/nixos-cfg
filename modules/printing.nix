# CUPS printing + SANE scanning with network discovery.
{ pkgs, username, ... }:
{
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      hplip
    ];
  };

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ]; # driverless network scanners
  };

  users.users.${username}.extraGroups = [
    "scanner"
    "lp"
  ];

  environment.systemPackages = with pkgs.kdePackages; [
    print-manager
    skanpage
  ];
}
