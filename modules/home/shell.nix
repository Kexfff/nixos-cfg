# Shell: zsh/fish/bash (per my.user.shell) + starship, zoxide, fzf, bat, btop.
{
  lib,
  osConfig,
  ...
}:
let
  shell = osConfig.my.user.shell;
  flake = osConfig.my.nix.flakePath;

  aliases = {
    # ── NixOS ──
    nrs = "nh os switch"; # rebuild + activate
    nrb = "nh os boot"; # activate on next boot only
    nrt = "nh os test"; # activate without adding a boot entry
    nup = "nix flake update --flake ${flake} && nh os switch";
    ngc = "nh clean all --keep 5 --keep-since 7d";
    nse = "nh search";
    ngen = "nixos-rebuild list-generations";
    ndiff = "nvd diff /run/booted-system /run/current-system";
    nfmt = "nix fmt ${flake}";

    # ── modern replacements ──
    ls = "eza --icons --group-directories-first";
    ll = "eza -l --icons --git --group-directories-first";
    la = "eza -la --icons --git --group-directories-first";
    lt = "eza --tree --icons --level=2";
    cat = "bat --paging=never";
    ".." = "cd ..";
    "..." = "cd ../..";
  };

  # Fish-native abbreviations: unlike aliases they expand inline as you type,
  # so you always see the command that actually runs. Start from the shared
  # aliases and add the git/nix habits that make an interactive shell pleasant.
  fishAbbrs = aliases // {
    # ── git ──
    g = "git";
    gs = "git status --short --branch";
    ga = "git add";
    gaa = "git add --all";
    gc = "git commit";
    gcm = "git commit -m";
    gca = "git commit --amend --no-edit";
    gco = "git checkout";
    gcb = "git checkout -b";
    gd = "git diff";
    gds = "git diff --staged";
    gl = "git log --oneline --graph --decorate";
    gla = "git log --oneline --graph --decorate --all";
    gp = "git push";
    gpf = "git push --force-with-lease";
    gpl = "git pull";
    gf = "git fetch --all --prune";
    gr = "git rebase";
    grc = "git rebase --continue";
    gst = "git stash";
    gstp = "git stash pop";

    # ── nix ──
    ns = "nix shell";
    nd = "nix develop";
    nb = "nix build";
    nr = "nix run";

    # ── system ──
    ports = "ss -tulpn";
    ip = "ip --color=auto";
  };
in
{
  programs.zsh = lib.mkIf (shell == "zsh") {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    shellAliases = aliases;
    initContent = ''
      bindkey -e
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey '^[[3~'   delete-char
      bindkey '^[[H'    beginning-of-line
      bindkey '^[[F'    end-of-line
      setopt HIST_REDUCE_BLANKS INTERACTIVE_COMMENTS
    '';
  };

  programs.fish = lib.mkIf (shell == "fish") {
    enable = true;

    shellAbbrs = fishAbbrs;
    preferAbbrs = true;

    # Small helpers written as real fish functions.
    functions = {
      mkcd = {
        description = "Create a directory and cd into it";
        argumentNames = "dir";
        body = "mkdir -p -- $dir; and cd -- $dir";
      };

      up = {
        description = "Go up N directory levels (default 1)";
        argumentNames = "n";
        body = ''
          set -l levels 1
          if test -n "$n"
            set levels $n
          end
          for i in (seq $levels)
            cd ..
          end
        '';
      };

      # Open yazi and land in the last visited directory on exit.
      y = {
        description = "Open yazi and cd to the last visited directory";
        body = ''
          set -l tmp (mktemp -t yazi-cwd.XXXXXX)
          yazi $argv --cwd-file="$tmp"
          if set -l cwd (command cat -- "$tmp")
            if test -n "$cwd"; and test "$cwd" != "$PWD"
              cd -- "$cwd"
            end
          end
          rm -f -- "$tmp"
        '';
      };

      extract = {
        description = "Extract most archive formats";
        argumentNames = "file";
        body = ''
          if not test -f "$file"
            echo "extract: not a file: $file" >&2
            return 1
          end
          switch "$file"
            case "*.tar.bz2" "*.tbz2"
              tar xjf "$file"
            case "*.tar.gz" "*.tgz"
              tar xzf "$file"
            case "*.tar.xz" "*.txz"
              tar xJf "$file"
            case "*.tar.zst"
              tar --zstd -xf "$file"
            case "*.tar"
              tar xf "$file"
            case "*.zip"
              unzip "$file"
            case "*.rar"
              unrar x "$file"
            case "*.7z"
              7z x "$file"
            case "*.gz"
              gunzip "$file"
            case "*"
              echo "extract: unsupported archive: $file" >&2
              return 1
          end
        '';
      };
    };

    # Comfort bindings on top of the fish defaults.
    binds = {
      "ctrl-backspace".command = "backward-kill-word";
      "ctrl-delete".command = "kill-word";
    };

    interactiveShellInit = ''
      # No welcome banner — starship owns the prompt, fastfetch the splash.
      set -g fish_greeting

      # Terminal-theme-aware colours for syntax highlighting and the pager.
      set -g fish_color_normal normal
      set -g fish_color_command green --bold
      set -g fish_color_param cyan
      set -g fish_color_keyword magenta
      set -g fish_color_quote yellow
      set -g fish_color_redirection brcyan --bold
      set -g fish_color_end magenta
      set -g fish_color_error red --bold
      set -g fish_color_comment brblack
      set -g fish_color_selection white --bold --background=brblack
      set -g fish_color_search_match bryellow --background=brblack
      set -g fish_color_history_current --bold
      set -g fish_color_operator brcyan
      set -g fish_color_escape brcyan
      set -g fish_color_cwd green
      set -g fish_color_cwd_root red
      set -g fish_color_valid_path --underline
      set -g fish_color_autosuggestion brblack
      set -g fish_color_cancel red --reverse
      set -g fish_pager_color_prefix cyan --bold --underline
      set -g fish_pager_color_completion normal
      set -g fish_pager_color_description brblack
      set -g fish_pager_color_selected_background --reverse
    '';
  };

  # bash is always configured: it's the fallback
  programs.bash = {
    enable = true;
    shellAliases = aliases;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
      nix_shell = {
        symbol = "❄️ ";
        format = "via [$symbol$state]($style) ";
      };
    };
  };

  programs.zoxide.enable = true; # `z <dir>` — smarter cd
  programs.fzf.enable = true; # Ctrl-R history, Ctrl-T files
  programs.bat = {
    enable = true;
    config.theme = "ansi";
  };
  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
      vim_keys = true;
    };
  };
}
