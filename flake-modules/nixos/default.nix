{ ... }:
let
  luksAutomount = import ./lluksAutomount.nix;
in
{
  flake.nixosModules = {
    inherit
      luksAutomount
      ;

    default = {
      imports = [
      ];
    };
  };
}
