# ── Laptop: Intel CPU + Intel iGPU ────────────────────────────────────────────
{ pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  my = {
    # ── Identity ─────────────────────────────────────────── CHANGEME ──
    user = {
      name = "kexfff"; # also rename users/user/ to match
      fullName = "Aleksei";
      email = "llexxass@gmail.com";
      shell = "fish";
    };
    locale = {
      timeZone = "Europe/Moscow";
      defaultLocale = "en_US.UTF-8";
      keyboard.layout = "us,ru";
    };
    nix.flakePath = "~/nixos-cfg";

    # ── Hardware ──────────────────────────────────────────────────────
    hardware = {
      cpu = "intel";
      gpu = "intel";
      laptop = {
        enable = true;
        powerBackend = "power-profiles-daemon"; # or "tlp" (+ batteryThreshold = 80)
        # Its suspend callback returns -EINVAL, which aborts suspend and leaves
        # the screen on. Blacklisted until the kernel driver is fixed.
        blacklistedKernelModules = [ "bitland_mifs_wmi" ];
      };
      bluetooth.enable = true;
    };

    # ── Boot ──────────────────────────────────────────────────────────
    boot = {
      kernel = "cachyos";
      scx.scheduler = "scx_bpfland"; # interactive workloads, gentle on battery
    };

    # ── Storage ──
    filesystem.btrfs.mountpoints = [
      "/"
      "/home"
      "/nix"
    ];

    # ── Desktop & workloads ───────────────────────────────────────────
    desktop.plasma.enable = true;
    desktop.inir.enable = true; # iNiR / Niri shell (modules/{nixos,home}/inir.nix)

    gaming = {
      enable = true;
      launchers = with pkgs; [
        heroic
        prismlauncher
      ]; # lighter set than the desktop
    };

    development = {
      enable = true;
      languages = [
        "python"
        "node"
      ];
      editors = [ "vscode" ];
    };

    virtualisation = {
      podman.enable = true; # rootless, no daemon → kinder to the battery
      distrobox.enable = true;
    };

    services = {
      printing.enable = true;
      flatpak.enable = true;
      tailscale.enable = true;
    };
  };

  # Proxy client. TUN mode needs the capability/polkit wrapper this module sets up.
  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };

  # Fingerprint reader — check support first with `fprintd-enroll`
  # services.fprintd.enable = true;

  # CHANGEME: copy from your current /etc/nixos/configuration.nix
  system.stateVersion = "26.05";
}
