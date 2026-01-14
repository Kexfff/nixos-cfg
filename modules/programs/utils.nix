{pkgs, ...}: {
  environment.systemPackages = with pkgs; [

    #Networking----------------------------
    wget
    curl
    git
    #zapret
    iptables
    ipset





    zed-editor-fhs
    vscodium-fhs
    vscode-fhs
    jetbrains.idea-oss
    jetbrains.pycharm-oss

    # Development Tools--------------------
    gh
    gcc
    gnumake
    cmake
    python3
    nodejs
    nodePackages.npm
    nodePackages.pnpm
    rustup
    go
    docker-compose

    # System Utilities---------------------
    btop
    htop
    fastfetch
    unzip
    zip
    p7zip
    ripgrep
    fd
    fzf

    #MultiMedia----------------------------
    vivaldi-ffmpeg-codecs
    ffmpeg
    lshw
    qbittorrent-enhanced
    protonup-qt
    mangohud
    dbeaver-bin
  ];
}
