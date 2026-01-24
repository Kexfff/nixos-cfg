{pkgs, ...}: {
  environment.systemPackages = with pkgs; [

    #Networking----------------------------
    wget
    curl
    git
    #zapret
    iptables
    ipset




    # Text Editors // IDEs
    zed-editor-fhs
    vscodium-fhs

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
    #docker-compose

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
