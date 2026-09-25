# Containers and VMs: Docker, Podman, libvirt/QEMU, Distrobox.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.virtualisation;
  user = config.my.user.name;
in
{
  options.my.virtualisation = {
    docker.enable = lib.mkEnableOption "Docker";
    podman.enable = lib.mkEnableOption "Podman (rootless; provides `docker` alias unless Docker is on)";
    libvirt.enable = lib.mkEnableOption "libvirt + QEMU/KVM + virt-manager";
    distrobox.enable = lib.mkEnableOption "Distrobox (needs Docker or Podman)";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.docker.enable {
      virtualisation.docker = {
        enable = true;
        autoPrune.enable = true;
        # Note: overlay2 (default) is used on purpose — the "btrfs" storage driver
        # works with subvolume snapshots, which this config avoids.
      };
      users.users.${user}.extraGroups = [ "docker" ];
      environment.systemPackages = with pkgs; [
        docker-compose
        lazydocker
      ];
    })

    (lib.mkIf cfg.podman.enable {
      virtualisation.podman = {
        enable = true;
        dockerCompat = !cfg.docker.enable;
        defaultNetwork.settings.dns_enabled = true;
      };
      environment.systemPackages = with pkgs; [
        podman-compose
        podman-tui
      ];
    })

    (lib.mkIf cfg.libvirt.enable {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          runAsRoot = false;
          swtpm.enable = true; # TPM for Windows 11 guests
          ovmf = {
            enable = true;
            packages = [ pkgs.OVMFFull.fd ];
          };
        };
      };
      virtualisation.spiceUSBRedirection.enable = true;
      programs.virt-manager.enable = true;
      users.users.${user}.extraGroups = [
        "libvirtd"
        "kvm"
      ];
    })

    (lib.mkIf cfg.distrobox.enable {
      environment.systemPackages = with pkgs; [
        distrobox
        boxbuddy # GUI
      ];
      assertions = [
        {
          assertion = cfg.docker.enable || cfg.podman.enable;
          message = "my.virtualisation.distrobox needs docker or podman enabled.";
        }
      ];
    })
  ];
}
