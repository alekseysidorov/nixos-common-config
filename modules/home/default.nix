# Complete home configuration for desktop
{ ... }:
{
  imports = [
    ./common.nix
    ./develop.nix
    ./shell.nix
    ./git.nix
  ];
}
