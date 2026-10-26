# Laptop: power management, lid handling, touchpad, battery tooling.
{ pkgs, ... }:
{
  # Integrates with Plasma's battery applet. For longer runtime, swap for
  # services.tlp (and set services.power-profiles-daemon.enable = false).
  services.power-profiles-daemon.enable = true;

  services.upower.enable = true;
  services.libinput.enable = true; # touchpad
  powerManagement.enable = true;
  networking.networkmanager.wifi.powersave = true;
  hardware.sensor.iio.enable = true; # auto-rotate / ambient light on convertibles

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  environment.systemPackages = with pkgs; [
    powertop
    brightnessctl
    acpi
  ];

  # Some machines resume more reliably from S3 than s2idle:
  # boot.kernelParams = [ "mem_sleep_default=deep" ];
}
