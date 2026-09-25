# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  PLACEHOLDER — REPLACE THIS FILE WITH YOUR GENERATED ONE                  ║
# ║                                                                           ║
# ║    sudo cp /etc/nixos/hardware-configuration.nix hosts/desktop/           ║
# ║    # or regenerate: sudo nixos-generate-config --show-hardware-config     ║
# ║                                                                           ║
# ║  The build refuses to proceed while "CHANGE-ME" is still in here.         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Typical flat-subvolume Btrfs layout. compress=zstd / noatime are added by
  # modules/nixos/core/filesystem.nix, so they need not be here.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/CHANGE-ME";
    fsType = "btrfs";
    options = [ "subvol=@" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/CHANGE-ME";
    fsType = "btrfs";
    options = [ "subvol=@home" ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/CHANGE-ME";
    fsType = "btrfs";
    options = [ "subvol=@nix" ];
  };

  # EFI System Partition — Limine installs here
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/CHANGE-ME";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
