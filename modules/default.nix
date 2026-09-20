myCommonInputs:

{ flake-parts-lib, ... }:

{
  imports = [
    (flake-parts-lib.importApply ./myCommon myCommonInputs)
    ./profiles
  ];
}
