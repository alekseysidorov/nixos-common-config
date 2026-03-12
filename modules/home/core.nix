# Common home-manager configuration shared between Linux and macOS
{ lib, pkgs, ... }:
{
  # Useful utilities
  home.packages = with pkgs; [
    bat
    ripgrep
    pwgen
    jq
    nps
  ];

  programs.vim = {
    enable = true;
    defaultEditor = true;
    extraConfig = lib.mkDefault (builtins.readFile ./assets/vimrc);
  };
}
