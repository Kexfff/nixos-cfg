{pkgs, ...}: {
  programs.firefox.enable = false;
  programs.amnezia-vpn.enable = true;
  programs.nix-ld.enable = true;






  environment.systemPackages = with pkgs; [
    libsecret
    seahorse



    antigravity
    gemini-cli
    amnezia-vpn
    vlc
    vesktop
    obsidian
    telegram-desktop
    discord
    lutris
    heroic
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
  ];
}
