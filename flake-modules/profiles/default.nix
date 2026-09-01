{ ... }:
let
  nixSettings = ./nixSettings.nix;

in

{
  flake = {
    nixosModules = rec {
      inherit nixSettings;

      default.imports = [
        nixSettings
      ];
    };

    darwinModules = rec {
      inherit nixSettings;

      default.imports = [
        nixSettings
      ];
    };

    homeManagerModules = rec {
      inherit nixSettings;
      core = ./home/core.nix;
      develop = ./home/develop.nix;
      git = ./home/git.nix;
      shell = ./home/shell.nix;

      default.imports = [
        core
        develop
        git
        shell
      ];
    };
  };
}
