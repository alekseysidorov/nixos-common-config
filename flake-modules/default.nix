{ ... }:
let
  commonModules = {
    nixSettings = ./common/nixSettings.nix;
    shell = ./common/shell.nix;
  };
in
{
  imports = [
    ./options.nix
    ./overlays.nix
    ./myCommon.nix
  ];

  flake = {
    nixosModules = rec {
      inherit (commonModules)
        nixSettings
        shell
        ;

      default.imports = [
        nixSettings
        shell
      ];
    };

    darwinModules = rec {
      inherit (commonModules)
        myCommon
        nixSettings
        shell
        ;

      default.imports = [
        myCommon
        nixSettings
        shell
      ];
    };

    homeManagerModules = rec {
      inherit (commonModules)
        nixSettings
        ;

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
