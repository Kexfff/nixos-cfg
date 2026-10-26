# AMD CPU: microcode, KVM, amd_pstate.
{
  hardware.cpu.amd.updateMicrocode = true;
  boot.kernelModules = [ "kvm-amd" ];
  # amd_pstate in active (EPP) mode: Zen 2 and newer; silently ignored on older CPUs
  boot.kernelParams = [ "amd_pstate=active" ];
}
