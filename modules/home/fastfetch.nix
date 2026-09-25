# fastfetch — system info splash with the Rei logo.
#
# The old hand-written config.jsonc is merged here: Home Manager renders the
# `settings` attribute set to $XDG_CONFIG_HOME/fastfetch/config.jsonc, and the
# logo lives in the repo under assets/fastfetch/.
{ ... }:
let
  cyan = "36";
  red = "31";
  magenta = "35";
in
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "~/.config/fastfetch/images/rei.png";
        type = "kitty";
        height = 27;
      };
      display.separator = " ➜  ";
      modules = [
        "break"
        "break"
        "break"
        {
          type = "os";
          key = "OS   ";
          keyColor = cyan;
        }
        {
          type = "kernel";
          key = " ├  ";
          keyColor = cyan;
        }
        {
          type = "shell";
          key = " ├  ";
          keyColor = cyan;
        }
        {
          type = "uptime";
          format = "Uptime: {2}h{3}m{4}s";
          key = " └ 󰏖 ";
          keyColor = cyan;
        }
        "break"
        {
          type = "wm";
          key = "WM   ";
          keyColor = red;
        }
        {
          type = "wmtheme";
          key = " ├ 󰉼 ";
          keyColor = red;
        }
        {
          type = "icons";
          key = " ├ 󰀻 ";
          keyColor = red;
        }
        {
          type = "cursor";
          key = " ├  ";
          keyColor = red;
        }
        {
          type = "terminal";
          key = " ├  ";
          keyColor = red;
        }
        {
          type = "terminalfont";
          key = " └  ";
          keyColor = red;
        }
        "break"
        {
          type = "host";
          format = "{5} {1} Type {2}";
          key = "PC   ";
          keyColor = magenta;
        }
        {
          type = "cpu";
          format = "{1} ({3}) @ {7} GHz";
          key = " ├  ";
          keyColor = magenta;
        }
        {
          type = "gpu";
          format = "{1} {2} @ {12} GHz";
          key = " ├ 󰢮 ";
          keyColor = magenta;
        }
        {
          type = "memory";
          format = "RAM: {1}/{2} {3}";
          key = " ├  ";
          keyColor = magenta;
        }
        {
          type = "swap";
          format = "Swap: {1}/{2} {3}";
          key = " ├ 󰓡 ";
          keyColor = magenta;
        }
        {
          type = "disk";
          format = "Hard Disk: {1}/{2} {10}({9})";
          key = " ├ 󰋊 ";
          keyColor = magenta;
        }
        {
          type = "monitor";
          key = " └  ";
          keyColor = magenta;
        }
        "break"
        "break"
      ];
    };
  };

  # Keep the original `~/.config/fastfetch/images/rei.png` logo path working.
  xdg.configFile."fastfetch/images/rei.png".source = ../../assets/fastfetch/rei.png;
}
