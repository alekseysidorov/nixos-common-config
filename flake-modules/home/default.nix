{ ... }:
let
  core = import ./core.nix;
  develop = import ./develop.nix;
  git = import ./git.nix;
  shell = import ./shell.nix;
in
{
  flake.homeManagerModules = {
    inherit
      core
      develop
      git
      shell
      ;

    default = {
      imports = [
        core
        develop
        git
        shell
      ];
    };
  };
}
