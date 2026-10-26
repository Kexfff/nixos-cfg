# Development: toolchains, nix-ld (unpatched binaries), envfs, direnv.
# Editors are personal → users/kexfff/editors.nix.
#
# Global toolchains are for scratch work. For real projects use a flake with a
# devShell + `.envrc` ("use flake") — direnv loads it automatically.
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # general
    gh
    lazygit
    git-lfs
    just
    hyperfine
    tokei
    sqlite
    shellcheck
    shfmt

    # C / C++
    gcc
    gnumake
    cmake
    ninja
    pkg-config
    gdb
    clang-tools # clangd, clang-format (no `cc` collision with gcc)

    # Rust — run `rustup default stable` once
    rustup

    # Go
    go
    gopls

    # Python
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

    # Node
    nodejs_22
    pnpm
    bun
    typescript-language-server

    # More, when needed:
    # jdk maven gradle  ·  dotnet-sdk  ·  zig zls  ·  ghc cabal-install haskell-language-server
  ];

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

  home-manager.sharedModules = [
    {
      # Per-project environments: put `use flake` in a project's .envrc
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
        silent = true;
      };

      home.packages = with pkgs; [
        devenv # batteries-included dev environments (devenv.sh)
      ];

      # Minimal flake template for new projects:  nix flake init -t ~/.config/nix-templates#basic
      xdg.configFile."nix-templates/flake.nix".text = ''
        {
          outputs = _: {
            templates.basic = {
              path = ./basic;
              description = "devShell with direnv";
            };
          };
        }
      '';
      xdg.configFile."nix-templates/basic/flake.nix".text = ''
        {
          inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
          outputs = { nixpkgs, ... }:
            let
              pkgs = nixpkgs.legacyPackages.x86_64-linux;
            in {
              devShells.x86_64-linux.default = pkgs.mkShell {
                packages = with pkgs; [ ];
              };
            };
        }
      '';
      xdg.configFile."nix-templates/basic/.envrc".text = "use flake\n";
    }
  ];
}
