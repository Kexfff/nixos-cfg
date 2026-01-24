{pkgs, ...}: {
  programs.firefox.enable = false;
  programs.amnezia-vpn.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
      curl
      icu
      libffi
      libxml2
    ];
  };






  environment.systemPackages = with pkgs; [
    libsecret
    seahorse


    #antigravity
    gemini-cli
    codex
    amnezia-vpn
    vlc
    #vesktop
    #obsidian
    #telegram-desktop
    #discord
    #lutris
    #heroic
    #libreoffice-qt
    hunspell
    hunspellDicts.en_US
  ];
}
