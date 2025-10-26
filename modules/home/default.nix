# Complete home configuration for desktop
{ ... }:
{
  imports = [
    ./core.nix
    ./develop.nix
    ./shell.nix
    ./git.nix
  ];
}
