# OpenSSH server — keys only (add them via my.user.authorizedKeys).
{ config, lib, ... }:
{
  options.my.services.ssh.enable = lib.mkEnableOption "the OpenSSH server";

  config = lib.mkIf config.my.services.ssh.enable {
    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
