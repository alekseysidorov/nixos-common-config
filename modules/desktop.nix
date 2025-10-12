# Linux specific configuration
{ pkgs, inputs, ... }:
{
  imports = [
    inputs.vscode-server.nixosModules.default
  ];

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
  fonts.packages = with pkgs.unstable; [
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
}
