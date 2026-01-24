{
  lib,
  pkgs,
  config,
  ...
}:{
  hardware.graphics = {
   enable = true;
   extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl];
   extraPackages32 = with pkgs.driversi686Linux; [
        intel-vaapi-driver
        libva-vdpau-driver
        libvdpau-va-gl
   ];
  };
}
