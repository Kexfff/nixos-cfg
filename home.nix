{ config, pkgs, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "kexfff";
  home.homeDirectory = "/home/kexfff";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';


  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # here is some command line tools I use frequently
    # feel free to add your own or remove some of them

    # archives
    zip
    xz
    unzip
    p7zip


  ];

  programs.illogical-impulse = {
    enable = true;

    # Customize shell tools (all enabled by default)
    dotfiles = {
      fish.enable = true;     # Fish shell with custom config
      kitty.enable = true;    # Kitty terminal emulator
      starship.enable = true; # Starship prompt
    };
  };

  # GitHub CLI configuration
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    settings.user.name = "kexfff";
    settings.user.email = "llexxass@gmail.com";
  };

  # starship - an customizable prompt for any shell
#   programs.starship = {
#     enable = true;
#     # custom settings
#     settings = {
#       add_newline = false;
#       aws.disabled = true;
#       gcloud.disabled = true;
#       line_break.disabled = true;
#     };
#   };

  # alacritty - a cross-platform, GPU-accelerated terminal emulator
  programs.alacritty = {
    enable = true;
    # custom settings
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
        draw_bold_text_with_bright_colors = true;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

#   programs.bash = {
#     enable = true;
#     enableCompletion = true;
#     # TODO add your custom bashrc here
#     bashrcExtra = ''
#       export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
#     '';
#
#     # set some aliases, feel free to add more or remove some
#     shellAliases = {
#       k = "kubectl";
#       urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
#       urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
#     };
#   };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "thorium-browser.desktop" ];
      "x-scheme-handler/http" = [ "thorium-browser.desktop" ];
      "x-scheme-handler/https" = [ "thorium-browser.desktop" ];
      "x-scheme-handler/about" = [ "thorium-browser.desktop" ];
      "x-scheme-handler/unknown" = [ "thorium-browser.desktop" ];
      "application/pdf" = [ "thorium-browser.desktop" ];
      "application/x-extension-htm" = [ "thorium-browser.desktop" ];
      "application/x-extension-html" = [ "thorium-browser.desktop" ];
      "application/x-extension-shtml" = [ "thorium-browser.desktop" ];
      "application/xhtml+xml" = [ "thorium-browser.desktop" ];
      "application/x-extension-xhtml" = [ "thorium-browser.desktop" ];
      "application/x-extension-xht" = [ "thorium-browser.desktop" ];
    };
  };

  home.sessionVariables = {
    BROWSER = "thorium-browser";
    DEFAULT_BROWSER = "thorium-browser";
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}
