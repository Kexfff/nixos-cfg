# Flatpak with Flathub, managed declaratively by nix-flatpak.
{ inputs, ... }:
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    # Application IDs to keep installed, e.g. "com.github.tchx84.Flatseal"
    packages = [ ];
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
    # uninstallUnmanaged = true;  # remove flatpaks not listed above
  };

  xdg.portal.enable = true;
}
