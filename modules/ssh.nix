# OpenSSH server — keys only. Add yours to openssh.authorizedKeys in users/kexfff/default.nix.
{
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
