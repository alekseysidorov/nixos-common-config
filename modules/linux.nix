# Linux specific configuration
{ pkgs, flake, lib, ... }: {
  imports = [
    flake.inputs.vscode-server.nixosModules.default
  ];

  # Select internationalisation properties.
  i18n.defaultLocale = lib.mkDefault "ru_RU.UTF-8";
  i18n.supportedLocales = [ "all" ];
  # Use same config for linux console
  console.useXkbConfig = true;
  # My favorite keyboard layout
  services.xserver = {
    layout = "us,ru";
    xkbOptions = "grp:caps_toggle";
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
}
