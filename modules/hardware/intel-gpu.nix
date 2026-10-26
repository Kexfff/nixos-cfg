# Intel iGPU: VA-API, QuickSync, OpenCL.
{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit games / Steam
    extraPackages = with pkgs; [
      intel-media-driver # VA-API, Broadwell and newer (older: intel-vaapi-driver)
      vpl-gpu-rt # QuickSync / oneVPL
      intel-compute-runtime # OpenCL
    ];
    extraPackages32 = [ pkgs.driversi686Linux.intel-media-driver ];
  };

  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  environment.systemPackages = [ pkgs.nvtopPackages.intel ];
}
