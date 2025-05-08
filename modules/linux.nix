# Linux specific configuration
{ pkgs, inputs, lib, ... }:
{
  imports = [
    inputs.vscode-server.nixosModules.default
  ];

  # Select internationalisation properties.
  i18n = {
    defaultLocale = lib.mkDefault "ru_RU.UTF-8";
    extraLocales = lib.mkDefault [ "all" ];
  };
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

  # Some basic packages
  environment.systemPackages = with pkgs; [
    wget
    glxinfo
    libva-utils
    pciutils
    psmisc
    usbutils
    vulkan-tools
    # Some diagnostic utils
    libva-utils
    vdpauinfo
    vulkan-tools
  ];

  services = {
    openssh.enable = true;
    vscode-server.enable = true;
  };

  # Some linux specific fonts
  fonts = {
    packages = with pkgs.unstable; [
      corefonts
      emojione
      ipafont
      kanji-stroke-order-font
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      roboto
      roboto-serif
      roboto-slab
    ];
  };
}
