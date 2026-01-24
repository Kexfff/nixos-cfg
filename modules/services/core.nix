{ config, pkgs, ... }:

{
    # Bootloader.----------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #//Bootloader------------------------------------------------------------------------



  # Use latest kernel.-----------------------------------------------------------------
  boot.kernelPackages = pkgs.linuxPackages_zen;
  #//Kernels---------------------------------------------------------------------------









  # Enable the X11 windowing system.---------------------------------------------------
  services.xserver.enable = true;
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = false;
  services.desktopManager.plasma6.enable = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  #//DE--------------------------------------------------------------------------------




  # Audio------------------------------------------------------------------------------
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  #//Audio------------------------------------------------------------------------------




  #Other--------------------------------------------------------------------------------
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;





  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;
  services.upower.enable = true;
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.blueman.enable = true;


  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  security.polkit.enable = true;
  services.dbus.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
  #//Other------------------------------------------------------------------------------










    # Set your time zone.---------------------------------------------------------------
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };
  #//Time-------------------------------------------------------------------------------

  services.fstrim.enable = true;
  zramSwap.enable = true;
}
