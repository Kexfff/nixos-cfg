# VMs: libvirt + QEMU/KVM + virt-manager.
{ username, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      swtpm.enable = true; # TPM for Windows 11 guests
      # UEFI (OVMF) firmware images ship with QEMU and are available by default
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;

  users.users.${username}.extraGroups = [
    "libvirtd"
    "kvm"
  ];
}
