# Bluetooth (Plasma's Bluedevil provides the UI).
{ config, lib, ... }:
{
  options.my.hardware.bluetooth.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };

  config = lib.mkIf config.my.hardware.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Experimental = true; # battery levels of connected devices
        FastConnectable = true;
      };
    };
  };
}
