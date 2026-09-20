myCommonInputs:

{ flake-parts-lib, ... }:

{
  imports = [
    (flake-parts-lib.importApply ./commands.nix myCommonInputs)
  ];
}
