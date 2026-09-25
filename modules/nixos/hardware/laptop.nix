# Laptop tweaks: power management, lid handling, touchpad, battery tooling.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.hardware.laptop;
in
{
  options.my.hardware.laptop = {
    enable = lib.mkEnableOption "laptop tweaks (power management, lid, touchpad, battery tools)";

    powerBackend = lib.mkOption {
      type = lib.types.enum [
        "power-profiles-daemon"
        "tlp"
      ];
      default = "power-profiles-daemon";
      description = "PPD integrates with Plasma's battery applet; TLP squeezes out more runtime.";
    };

    batteryThreshold = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      example = 80;
      description = "Stop charging at this percentage (TLP only, firmware permitting).";
    };

    blacklistedKernelModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "bitland_mifs_wmi" ];
      description = ''
        Kernel modules to blacklist. Some vendor WMI drivers (e.g. bitland_mifs_wmi
        on Bitland/Redmi laptops) return -EINVAL from their suspend callback, which
        aborts every suspend attempt, so the machine immediately resumes and the
        screen never turns off.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.power-profiles-daemon.enable = cfg.powerBackend == "power-profiles-daemon";

    services.tlp = lib.mkIf (cfg.powerBackend == "tlp") {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        RUNTIME_PM_ON_BAT = "auto";
        USB_AUTOSUSPEND = 0; # avoids flaky mice / keyboards
      }
      // lib.optionalAttrs (cfg.batteryThreshold != null) {
        START_CHARGE_THRESH_BAT0 = cfg.batteryThreshold - 5;
        STOP_CHARGE_THRESH_BAT0 = cfg.batteryThreshold;
      };
    };

    services.upower.enable = true;
    services.libinput.enable = true; # touchpad
    powerManagement.enable = true;
    boot.blacklistedKernelModules = cfg.blacklistedKernelModules;
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
  };
}
