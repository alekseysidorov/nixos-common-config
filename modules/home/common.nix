# Common home-manager configuration shared between Linux and macOS
{ lib, pkgs, ... }:
{
  # Useful utilites
  home.packages = with pkgs; [
    bat
    ripgrep
    pwgen
    jq
  ];

  programs.vim = {
    extraConfig = lib.mkDefault (builtins.readFile ./assets/vimrc);
  };
}
