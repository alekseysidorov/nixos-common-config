# Common home-manager configuration for Linux and macOS
{ lib, pkgs, ... }:
{
  # Useful command-line utilities
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
