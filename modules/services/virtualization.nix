{pkgs, ...}: {
  # Enable Docker
  virtualisation.docker.enable = true;

  # Enable Libvirtd
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Add user to necessary groups
  users.users.kexfff.extraGroups = [ "docker" "libvirtd" ];

  services.spice-vdagentd.enable = true;
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    qemu
    qemu_kvm
    bridge-utils
    virt-viewer
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
  ];
}
