# PipeWire audio stack (PulseAudio + JACK + ALSA compatibility).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.hardware.audio.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "PipeWire audio.";
  };

  config = lib.mkIf config.my.hardware.audio.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;

      # Lower latency for music production (uncomment if you need it):
      # extraConfig.pipewire."92-low-latency" = {
      #   "context.properties" = {
      #     "default.clock.rate" = 48000;
      #     "default.clock.quantum" = 256;
      #     "default.clock.min-quantum" = 256;
      #   };
      # };
    };

    environment.systemPackages = with pkgs; [
      pulseaudio # pactl / pacmd for scripting
      pwvucontrol # PipeWire-native mixer
    ];
  };
}
