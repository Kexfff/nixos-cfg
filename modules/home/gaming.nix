# MangoHud overlay defaults (only when my.gaming.enable).
# Enable per game with `mangohud %command%` in Steam launch options, or MANGOHUD=1.
{ lib, osConfig, ... }:
{
  config = lib.mkIf osConfig.my.gaming.enable {
    programs.mangohud = {
      enable = true;
      enableSessionWide = false;
      settings = {
        toggle_hud = "Shift_R+F12";
        position = "top-left";
        font_size = 20;
        fps = true;
        frametime = true;
        frame_timing = true;
        cpu_stats = true;
        cpu_temp = true;
        gpu_stats = true;
        gpu_temp = true;
        ram = true;
        vram = true;
        gamemode = true;
        wine = true;
        vulkan_driver = true;
      };
    };
  };
}
