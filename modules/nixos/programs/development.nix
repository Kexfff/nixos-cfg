# Development: toolchains, nix-ld (unpatched binaries), envfs, docs.
# Editors and direnv are configured per user in modules/home/{editors,development}.nix.
#
# Tip: install language toolchains here only for scratch work. For real projects use a
# flake with a devShell + `.envrc` ("use flake") — direnv loads it automatically.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.development;

  toolchains = {
    c = with pkgs; [
      gcc
      gnumake
      cmake
      ninja
      pkg-config
      gdb
      clang-tools # clangd, clang-format (no `cc` collision with gcc)
    ];
    rust = with pkgs; [ rustup ]; # `rustup default stable` once
    go = with pkgs; [
      go
      gopls
    ];
    python = with pkgs; [
      (python3.withPackages (
        ps: with ps; [
          pip
          virtualenv
          ipython
          requests
        ]
      ))
      uv
      ruff
      pyright
    ];
    node = with pkgs; [
      nodejs_22
      pnpm
      bun
      typescript-language-server
    ];
    java = with pkgs; [
      jdk
      maven
      gradle
    ];
    dotnet = with pkgs; [ dotnet-sdk ];
    zig = with pkgs; [
      zig
      zls
    ];
    haskell = with pkgs; [
      ghc
      cabal-install
      haskell-language-server
    ];
  };
in
{
  options.my.development = {
    enable = lib.mkEnableOption "development tooling";

    languages = lib.mkOption {
      type = lib.types.listOf (lib.types.enum (builtins.attrNames toolchains));
      default = [
        "c"
        "python"
        "node"
      ];
      description = "Globally installed toolchains.";
    };

    editors = lib.mkOption {
      type = lib.types.listOf (
        lib.types.enum [
          "vscode"
          "zed"
          "jetbrains-idea"
        ]
      );
      default = [ "vscode" ];
      description = "Editors set up through Home Manager (modules/home/editors.nix).";
    };
  };

  config = lib.mkIf cfg.enable {
    # Run unpatched dynamically linked binaries (VS Code Remote, prebuilt CLIs…)
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        openssl
        curl
        icu
        libxml2
        fuse3
        glib
        libGL
        libglvnd
        expat
      ];
    };

    # /usr/bin/* and /bin/* shebangs resolve to whatever is in $PATH
    services.envfs.enable = true;

    environment.systemPackages =
      with pkgs;
      [
        gh
        lazygit
        git-lfs
        just
        hyperfine
        tokei
        sqlite
        shellcheck
        shfmt
      ]
      ++ lib.concatMap (l: toolchains.${l}) cfg.languages;
  };
}
