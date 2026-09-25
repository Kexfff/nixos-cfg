{
  imports = [
    ./gaming.nix # my.gaming.enable
    ./development.nix # my.development.enable
    ./virtualisation.nix # my.virtualisation.{docker,podman,libvirt,distrobox}.enable
    ./nix-tools.nix # always on: quality-of-life tooling for NixOS
  ];
}
