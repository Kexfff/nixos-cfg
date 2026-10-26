# niri + DM-Shell (dmsh, the dynamic-island shell) + DM Manager (its settings app).
# Shows up as a "niri" session in SDDM next to Plasma.
#
# niri's own config (~/.config/niri/config.kdl) and dmsh's (~/.config/dmsh/config.kdl)
# are left to you. `dmsh niri --no-autostart` prints the keybinds to add; dmsh starts
# with the session by itself, so leave it out of spawn-at-startup.
{ pkgs, inputs, ... }:
{
  imports = [
    inputs.dmsh.nixosModules.default
    inputs.dm-manager.nixosModules.default
  ];

  programs.niri = {
    enable = true;
    useNautilus = false; # GTK file chooser instead of pulling in Nautilus
  };

  programs.dmsh.enable = true; # user service, started with graphical-session.target
  programs.dm-manager.enable = true;

  # dmsh leaves these desktop pieces to you; DM Manager drives swayidle and awww.
  environment.systemPackages = with pkgs; [
    xwayland-satellite # X11 apps (niri starts it on demand)
    swayidle # idle → lock / screen off / sleep (DM Manager's Power & Sleep page)
    awww # wallpaper daemon (DM Manager's Wallpapers page)
  ];

  # Plasma starts its polkit agent only in its own session; this one runs with niri.
  systemd.user.services.niri-polkit-agent = {
    description = "Polkit authentication agent for niri";
    wantedBy = [ "niri.service" ];
    after = [ "niri.service" ];
    partOf = [ "niri.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
    };
  };
}
