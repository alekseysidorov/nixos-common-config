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

  myCommon = ./common;

  overlayModule = overlay: {
    nixpkgs.overlays = [
      overlay
    ];
  };

  overlayModules = {
    unstableOverlay = overlayModule unstableOverlay;
    commonOverlay = overlayModule commonOverlay;
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
      inherit myCommon;
      inherit (overlayModules)
        unstableOverlay
        commonOverlay
        ;

      default.imports = [
        myCommon
        unstableOverlay
        commonOverlay
      ];
    };

    darwinModules = {
      inherit myCommon;
      inherit (overlayModules)
        unstableOverlay
        commonOverlay
        ;

      default.imports = [
        myCommon
        unstableOverlay
        commonOverlay
      ];
    };

    homeManagerModules = rec {
      core = ./home/core.nix;
      develop = ./home/develop.nix;
      git = ./home/git.nix;
      shell = ./home/shell.nix;

      default = {
        imports = [
          core
          develop
          git
          shell
        ];
      };
    };
  };
}
