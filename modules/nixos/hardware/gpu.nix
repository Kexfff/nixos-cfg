# GPU drivers: NVIDIA (proprietary/open), AMD (amdgpu), Intel (i915/xe).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  gpu = config.my.hardware.gpu;
  nv = config.my.hardware.nvidia;
  cachyKernel = lib.hasPrefix "cachyos" config.my.boot.kernel;
in
{
  options.my.hardware = {
    gpu = lib.mkOption {
      type = lib.types.enum [
        "nvidia"
        "amd"
        "intel"
        "none"
      ];
      default = "none";
      description = "Primary GPU vendor.";
    };

    nvidia = {
      open = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Use NVIDIA's open kernel modules. Required for RTX 50xx, recommended for
          Turing (RTX 20xx / GTX 16xx) and newer. Set to false for GTX 10xx and older.
        '';
      };
      driver = lib.mkOption {
        type = lib.types.enum [
          "cachyos"
          "stable"
          "beta"
          "latest"
          "production"
        ];
        default = if cachyKernel then "cachyos" else "latest";
        description = ''
          "cachyos": chaotic's `nvidia_cachyos`, pre-built for linuxPackages_cachyos (no
          local compile, matches the Clang/LTO kernel). Anything else selects
          boot.kernelPackages.nvidiaPackages.<name> and builds against your kernel.
        '';
      };
      powerManagement = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Save/restore VRAM across suspend — fixes broken resume on Wayland.";
      };
    };
  };

  config = lib.mkMerge [
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true; # 32-bit games / Steam
      };
    }

    # ── NVIDIA ─────────────────────────────────────────────────────────────
    (lib.mkIf (gpu == "nvidia") {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        package =
          if nv.driver == "cachyos" then
            pkgs.nvidia_cachyos
          else
            config.boot.kernelPackages.nvidiaPackages.${nv.driver};
        inherit (nv) open;
        modesetting.enable = true; # mandatory for Wayland
        nvidiaSettings = true;
        powerManagement.enable = nv.powerManagement;
        powerManagement.finegrained = false; # only for PRIME-offload laptops
      };

      hardware.graphics.extraPackages = [ pkgs.nvidia-vaapi-driver ]; # VA-API in browsers
      boot.kernelParams = [ "nvidia-drm.fbdev=1" ]; # proper framebuffer console + Plymouth

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        NVD_BACKEND = "direct";
      };
      environment.systemPackages = [ pkgs.nvtopPackages.nvidia ];

      assertions = [
        {
          assertion = (nv.driver == "cachyos") -> cachyKernel;
          message = "my.hardware.nvidia.driver = \"cachyos\" requires a CachyOS kernel (my.boot.kernel).";
        }
      ];
    })

    # ── AMD (in-tree amdgpu) ───────────────────────────────────────────────
    (lib.mkIf (gpu == "amd") {
      hardware.amdgpu.initrd.enable = true; # early KMS → flicker-free boot
      services.lact.enable = true; # GPU control panel: fan curves, power limits, OC
      environment.systemPackages = [ pkgs.nvtopPackages.amd ];
      # OpenCL / ROCm:
      # hardware.graphics.extraPackages = [ pkgs.rocmPackages.clr.icd ];
    })

    # ── Intel iGPU ─────────────────────────────────────────────────────────
    (lib.mkIf (gpu == "intel") {
      hardware.graphics.extraPackages = with pkgs; [
        intel-media-driver # VA-API, Broadwell and newer (older: intel-vaapi-driver)
        vpl-gpu-rt # QuickSync / oneVPL
        intel-compute-runtime # OpenCL
      ];
      hardware.graphics.extraPackages32 = [ pkgs.driversi686Linux.intel-media-driver ];
      environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
      environment.systemPackages = [ pkgs.nvtopPackages.intel ];
    })
  ];
}
