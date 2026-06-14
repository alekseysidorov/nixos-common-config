{ ... }:
let
  git = import ./git.nix;
in
{
  flake.homeManagerModules = {
    inherit git;

    default = {
      imports = [ git ];
    };
  };
}
