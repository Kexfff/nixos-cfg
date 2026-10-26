# ── Laptop: Intel CPU + Intel iGPU ────────────────────────────────────────────
# A host = the modules it imports + a few machine-specific settings.
# Importing a module turns it on; comment a line out to turn it off.
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core

    ../../modules/hardware/intel-cpu.nix
    ../../modules/hardware/intel-gpu.nix
    ../../modules/hardware/laptop.nix

    ../../modules/desktop/plasma.nix
    ../../modules/desktop/qylock.nix

    ../../modules/gaming.nix
    ../../modules/development.nix
    ../../modules/podman.nix # rootless, no daemon → kinder to the battery
    ../../modules/printing.nix
    ../../modules/flatpak.nix
    ../../modules/tailscale.nix
  ];

  # sched_ext scheduler for interactive workloads, gentle on battery
  services.scx.scheduler = "scx_bpfland";

  # This vendor WMI driver's suspend callback returns -EINVAL, which aborts
  # suspend and leaves the screen on. Blacklisted until the kernel driver is fixed.
  boot.blacklistedKernelModules = [ "bitland_mifs_wmi" ];

  # Proxy client. TUN mode needs the capability/polkit wrapper this module sets up.
  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  # Fingerprint reader — check support first with `fprintd-enroll`
  # services.fprintd.enable = true;

  environment.systemPackages = with pkgs; [
    qemu # Claude Desktop's Cowork VM (the desktop gets it from libvirt.nix)
  ];

  # The release this machine was first installed with. Never bump it blindly.
  system.stateVersion = "26.05";
}
