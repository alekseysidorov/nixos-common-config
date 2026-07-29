{  ... }:

{
  flake.imports = [
    ./options.nix
    ./overlays.nix
    ./nixos
    ./home
  ];
}
