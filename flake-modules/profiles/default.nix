{ ... }:
let
  nixSettings = ./nixSettings.nix;

  shellPrograms =
    { ... }:
    {
      programs.zsh.enable = true;
    };

in

{
  flake = {
    nixosModules = rec {
      inherit nixSettings;

      default.imports = [
        nixSettings
        shellPrograms
      ];
    };

    darwinModules = rec {
      inherit nixSettings;

      default.imports = [
        nixSettings
        shellPrograms
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
