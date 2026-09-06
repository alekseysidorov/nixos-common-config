{ ... }:
let
  nixSettings = ./nixSettings.nix;

  nushellIntegration = {
    myCommon.home.enableNushellIntegration = true;
  };

in

{
  flake = {
    nixosModules = rec {
      inherit nixSettings;

      default.imports = [
        nixSettings
        nushellIntegration
      ];
    };

    darwinModules = rec {
      inherit nixSettings;

      default.imports = [
        nixSettings
        nushellIntegration
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
