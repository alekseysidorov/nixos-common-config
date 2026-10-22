myCommonInputs:

{ flake-parts-lib, ... }:

{
  imports = [
    (flake-parts-lib.importApply ./flake myCommonInputs)
    ./fancy
    ./nix
  ];
}
