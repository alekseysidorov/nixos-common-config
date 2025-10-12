{ lib, ... }:

{
  # Select internationalisation properties.
  i18n.defaultLocale = lib.mkDefault "ru_RU.UTF-8";
  # Use same config for linux console
  console = {
    useXkbConfig = lib.mkDefault true;
    earlySetup = lib.mkDefault true;
  };
  # My favorite keyboard layout
  services.xserver = {
    xkb.layout = lib.mkDefault "us,ru";
    xkb.options = lib.mkDefault "grp:caps_toggle";
  };
}
