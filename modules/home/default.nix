# Complete Home Manager configuration for desktop systems
{ ... }:
{
  imports = [
    ./core.nix
    ./develop.nix
    ./shell.nix
    ./git.nix
  ];
}
