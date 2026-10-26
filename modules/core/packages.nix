# Baseline CLI tools on every host. User-facing apps live in Home Manager.
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # basics
    vim
    git
    curl
    wget
    file
    which
    tree
    less

    # archives
    unzip
    zip
    p7zip
    unrar

    # modern coreutils companions
    ripgrep
    fd
    bat
    eza
    fzf
    zoxide
    jq
    yq-go
    btop
    htop
    duf
    dust
    ncdu

    # hardware / diagnostics
    pciutils
    usbutils
    lm_sensors
    lshw
    dmidecode
    smartmontools
    nvme-cli
    inxi
    fastfetch

    # networking
    dig
    traceroute
    iperf3
    nmap

    # misc
    killall
    psmisc
    lsof
    tmux
  ];

  programs.mtr.enable = true;

  # man pages incl. developer sections (man 3 …)
  documentation = {
    enable = true;
    man.enable = true;
    dev.enable = true;
  };
}
