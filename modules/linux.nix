# Linux specific configuration
{ pkgs, flake, lib, ... }:
let
  nixPath = "/etc/nixpkgs/channels";
in
{
  imports = [
    flake.inputs.vscode-server.nixosModules.default
  ];

  # Setup nix paths for the nix-channel, we can use unstable branch.
  systemd.tmpfiles.rules = [
    "L+ ${nixPath} - - - - ${pkgs.unstable.path}"
  ];
  nix = {
    nixPath = [ "nixpkgs=${nixPath}" ];
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = lib.mkDefault "ru_RU.UTF-8";
    supportedLocales = lib.mkDefault [ "all" ];
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
}
