# CPU vendor: microcode, KVM module, frequency scaling.
{ config, lib, ... }:
let
  cpu = config.my.hardware.cpu;
in
{
  options.my.hardware.cpu = lib.mkOption {
    type = lib.types.enum [
      "amd"
      "intel"
    ];
    description = "CPU vendor (no default on purpose — every host must say).";
  };

  config = lib.mkMerge [
    (lib.mkIf (cpu == "amd") {
      hardware.cpu.amd.updateMicrocode = true;
      boot.kernelModules = [ "kvm-amd" ];
      # amd_pstate in active (EPP) mode: Zen 2 and newer; silently ignored on older CPUs
      boot.kernelParams = [ "amd_pstate=active" ];
    })

    (lib.mkIf (cpu == "intel") {
      hardware.cpu.intel.updateMicrocode = true;
      boot.kernelModules = [ "kvm-intel" ];
      services.thermald.enable = true; # avoids thermal-throttling storms
    })
  ];
}
