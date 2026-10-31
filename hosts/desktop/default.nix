# ── Desktop: AMD CPU + NVIDIA GPU ─────────────────────────────────────────────
# A host = the modules it imports + a few machine-specific settings.
# Importing a module turns it on; comment a line out to turn it off.
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core

    ../../modules/hardware/amd-cpu.nix
    ../../modules/hardware/nvidia.nix

    ../../modules/desktop/plasma.nix
    ../../modules/desktop/dm-desktop.nix # niri + DM-Shell + DM Manager

    ../../modules/gaming.nix
    ../../modules/development.nix
    ../../modules/podman.nix
    ../../modules/libvirt.nix
    ../../modules/printing.nix
    ../../modules/flatpak.nix
    # ../../modules/tailscale.nix
    # ../../modules/ssh.nix
  ];

  # GTX 10xx or older: no open kernel modules
  # hardware.nvidia.open = false;

  # Zen 4 / Zen 5: CPU-tuned kernel build
  # boot.kernelPackages = pkgs.linuxPackages_cachyos-lto-znver4;

  environment.systemPackages = with pkgs; [
    # openrgb
  ];
  # services.hardware.openrgb.enable = true;

  # CHANGEME: the release this machine is first installed with (see
  # /etc/nixos/configuration.nix after installing). Never bump it blindly.
  system.stateVersion = "26.05";
}
