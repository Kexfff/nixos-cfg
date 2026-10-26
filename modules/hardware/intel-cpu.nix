# Intel CPU: microcode, KVM, thermald.
{
  hardware.cpu.intel.updateMicrocode = true;
  boot.kernelModules = [ "kvm-intel" ];
  services.thermald.enable = true; # avoids thermal-throttling storms
}
