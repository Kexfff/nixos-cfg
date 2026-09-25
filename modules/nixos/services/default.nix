{
  imports = [
    ./printing.nix # my.services.printing.enable
    ./ssh.nix # my.services.ssh.enable
    ./flatpak.nix # my.services.flatpak.enable
    ./tailscale.nix # my.services.tailscale.enable
  ];
}
