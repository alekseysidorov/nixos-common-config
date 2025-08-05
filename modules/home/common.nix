# Common home-manager configuration shared between Linux and macOS
{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # Useful utilites
    bat
    ripgrep
    pwgen
  ];

  home.sessionVariables = lib.mkMerge [{
    EDITOR = "vim";
  }];

  programs.vim = {
    enable = true;
    extraConfig = builtins.readFile ./assets/vimrc;
  };
}
