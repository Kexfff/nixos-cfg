# CUPS printing + SANE scanning with network discovery.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.services.printing.enable = lib.mkEnableOption "printing and scanning";

  config = lib.mkIf config.my.services.printing.enable {
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

    users.users.${config.my.user.name}.extraGroups = [
      "scanner"
      "lp"
    ];

    environment.systemPackages = with pkgs.kdePackages; [
      print-manager
      skanpage
    ];
  };
}
