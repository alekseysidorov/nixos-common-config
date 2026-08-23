{ ... }:
let
  commonModules = {
    myCommon = ./common/myCommon;
    nixSettings = ./common/nixSettings.nix;
    shell = ./common/shell.nix;
  };
in
{
  flake = {
    imports = [
      ./options.nix
      ./overlays.nix
    ];

    nixosModules = rec {
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

    darwinModules = rec {
      inherit (commonModules)
        myCommon
        nixSettings
        shell
        ;

      primaryUser = ./common/myCommon/darwin/primaryUser.nix;

      default.imports = [
        myCommon
        nixSettings
        primaryUser
        shell
      ];
    };

    homeManagerModules = rec {
      inherit (commonModules)
        myCommon
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
