# sudo, polkit, realtime, GPG, firmware updates.
{ pkgs, ... }:
{
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = true;
      extraConfig = ''
        Defaults timestamp_timeout=15
        Defaults lecture=never
        Defaults pwfeedback
      '';
    };
    polkit.enable = true;
    rtkit.enable = true; # realtime priorities for PipeWire
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
    pinentryPackage = pkgs.pinentry-qt;
  };

  # Firmware updates:  fwupdmgr refresh && fwupdmgr update
  services.fwupd.enable = true;

  # dbus-broker: faster, lower latency than the reference implementation
  services.dbus.implementation = "broker";
}
