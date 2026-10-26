# NVIDIA GPU (proprietary driver, open kernel modules).
{ lib, pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit games / Steam
    extraPackages = [ pkgs.nvidia-vaapi-driver ]; # VA-API in browsers
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # chaotic's driver, pre-built for the CachyOS kernel (no local compile).
    # On a non-CachyOS kernel use config.boot.kernelPackages.nvidiaPackages.latest
    # (needs `config` in the arguments above).
    package = pkgs.nvidia_cachyos;
    # Open kernel modules: RTX 20xx / GTX 16xx and newer. GTX 10xx or older → false
    open = lib.mkDefault true;
    modesetting.enable = true; # mandatory for Wayland
    nvidiaSettings = true;
    powerManagement.enable = true; # save/restore VRAM across suspend (fixes Wayland resume)
    powerManagement.finegrained = false; # only for PRIME-offload laptops
  };

  boot.kernelParams = [ "nvidia-drm.fbdev=1" ]; # proper framebuffer console + Plymouth

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  };
  environment.systemPackages = [ pkgs.nvtopPackages.nvidia ];
}
