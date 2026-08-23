{ inputs, ... }:

let
  unstableOverlay = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config = prev.config or { };
      overlays = [ ];
    };
  };
  commonOverlay = import ../overlay.nix { inherit inputs; };

  unstableOverlayModule = {
    nixpkgs.overlays = [ unstableOverlay ];
  };
  commonOverlayModule = {
    nixpkgs.overlays = [ commonOverlay ];
  };
in
{
  flake = {
    overlays = {
      unstable = unstableOverlay;
      common = commonOverlay;
    };

    nixosModules = {
      unstableOverlay = unstableOverlayModule;
      commonOverlay = commonOverlayModule;

      default = {
        imports = [
          unstableOverlayModule
          commonOverlayModule
        ];
      };
    };

    darwinModules = {
      unstableOverlay = unstableOverlayModule;
      commonOverlay = commonOverlayModule;

      default = {
        imports = [
          unstableOverlayModule
          commonOverlayModule
        ];
      };
    };
  };
}
