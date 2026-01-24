{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Optional: ensure tuigreet can run properly (sometimes needs permissions for /var/cache/greetd)
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal"; # Better for debugging
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}
