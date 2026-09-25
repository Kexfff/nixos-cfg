{
  imports = [
    ./cpu.nix # my.hardware.cpu = "amd" | "intel"
    ./gpu.nix # my.hardware.gpu = "nvidia" | "amd" | "intel" | "none"
    ./laptop.nix # my.hardware.laptop.enable
    ./audio.nix # my.hardware.audio.enable  (PipeWire)
    ./bluetooth.nix # my.hardware.bluetooth.enable
  ];
}
