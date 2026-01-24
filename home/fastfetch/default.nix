{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fastfetch
  ];

  xdg.configFile."fastfetch/config.jsonc".source = ./config.jsonc;
  xdg.configFile."fastfetch/images/rei.png".source = ./images/rei.png;
}
