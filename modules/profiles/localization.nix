{ ... }:

{
  flake.modules.nixos.localization =
    { lib, ... }:
    {
      i18n = {
        defaultLocale = lib.mkDefault "en_US.UTF-8";

        extraLocaleSettings = {
          LC_MEASUREMENT = lib.mkDefault "ru_RU.UTF-8";
          LC_MONETARY = lib.mkDefault "ru_RU.UTF-8";
          LC_NUMERIC = lib.mkDefault "ru_RU.UTF-8";
          LC_TIME = lib.mkDefault "ru_RU.UTF-8";
        };
      };

      console = {
        useXkbConfig = lib.mkDefault true;
        earlySetup = lib.mkDefault true;
      };

      services.xserver.xkb = {
        layout = lib.mkDefault "us,ru";
        options = lib.mkDefault "grp:caps_toggle";
        variant = lib.mkDefault "mac";
      };
    };
}
