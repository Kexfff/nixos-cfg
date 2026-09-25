# Time zone, locales, keyboard layout.
{ config, lib, ... }:
let
  cfg = config.my.locale;
in
{
  options.my.locale = {
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "Etc/UTC";
      example = "Europe/Berlin";
    };
    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
    };
    regionalLocale = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "de_DE.UTF-8";
      description = "Locale for dates, paper size, currency, … while keeping English messages.";
    };
    keyboard = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
      };
      variant = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      options = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "caps:escape";
      };
    };
  };

  config = {
    time.timeZone = cfg.timeZone;

    i18n.defaultLocale = cfg.defaultLocale;
    i18n.extraLocaleSettings = lib.mkIf (cfg.regionalLocale != null) {
      LC_ADDRESS = cfg.regionalLocale;
      LC_IDENTIFICATION = cfg.regionalLocale;
      LC_MEASUREMENT = cfg.regionalLocale;
      LC_MONETARY = cfg.regionalLocale;
      LC_NAME = cfg.regionalLocale;
      LC_NUMERIC = cfg.regionalLocale;
      LC_PAPER = cfg.regionalLocale;
      LC_TELEPHONE = cfg.regionalLocale;
      LC_TIME = cfg.regionalLocale;
    };

    services.xserver.xkb = {
      inherit (cfg.keyboard) layout variant options;
    };
    # TTYs follow the same layout
    console.useXkbConfig = true;
  };
}
