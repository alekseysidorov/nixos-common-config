{ inputs, ... }@self:
let
  unstableOverlay = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      # Inherit config from the previous package set, so that the unstable overlay
      # can see the same configuration as the stable one.
      config = prev.config or { };
      # But we can't inherit overlays, because that would create a circular
      # dependency. So we just ignore them.
      overlays = [ ];
    };
  };
  commonOverlay = (import ./../overlay.nix) self;

  overlayModule = overlay: {
    nixpkgs.overlays = [
      overlay
    ];
  };

  overlayModules = {
    unstableOverlay = overlayModule unstableOverlay;
    commonOverlay = overlayModule commonOverlay;
  };

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
    ];

    overlays = {
      unstable = unstableOverlay;
      common = commonOverlay;
    };

    nixosModules = rec {
      inherit (commonModules)
        myCommon
        nixSettings
        shell
        ;
      inherit (overlayModules)
        unstableOverlay
        commonOverlay
        ;

      default.imports = [
        myCommon
        nixSettings
        unstableOverlay
        commonOverlay
        shell
      ];
    };

    darwinModules = rec {
      inherit (commonModules)
        myCommon
        nixSettings
        shell
        ;
      inherit (overlayModules)
        unstableOverlay
        commonOverlay
        ;

      primaryUser = ./darwin/primaryUser.nix;

      default.imports = [
        myCommon
        nixSettings
        unstableOverlay
        commonOverlay
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
