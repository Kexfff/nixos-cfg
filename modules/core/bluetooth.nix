# Bluetooth (Plasma's Bluedevil provides the UI).
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      Experimental = true; # battery levels of connected devices
      FastConnectable = true;
    };
  };
}
