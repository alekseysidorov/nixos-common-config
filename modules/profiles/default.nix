myCommonInputs:
{ flake-parts-lib, ... }:
{
  imports = [
    ./base-dev.nix
    (flake-parts-lib.importApply ./dev-tools.nix myCommonInputs)
    ./fonts.nix
    ./localization.nix
    ./networking.nix
    ./nix-dev.nix
    ./rust-dev.nix
    ./serial-dev.nix
  ];
}
