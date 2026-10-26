# Time zone, locale, keyboard layout. Override per host if a machine differs.
{
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  # Dates, paper size, currency in another locale while keeping English messages:
  # i18n.extraLocaleSettings = { LC_TIME = "ru_RU.UTF-8"; LC_MONETARY = "ru_RU.UTF-8"; };

  services.xserver.xkb = {
    layout = "us,ru";
    # options = "grp:alt_shift_toggle";
  };
  console.useXkbConfig = true; # TTYs follow the same layout
}
