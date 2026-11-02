myCommonInputs:

{ flake-parts-lib, ... }:

{
  imports = [
    (flake-parts-lib.importApply ./myCommon myCommonInputs)
    (flake-parts-lib.importApply ./profiles myCommonInputs)
  ];
}
