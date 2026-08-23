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
  flake.overlays.unstable = unstableOverlay;
  flake.overlays.common = commonOverlay;

  flake.nixosModules.unstableOverlay = unstableOverlayModule;
  flake.nixosModules.commonOverlay = commonOverlayModule;

  flake.nixosModules.default = {
    imports = [
      unstableOverlayModule
      commonOverlayModule
    ];
  };

  flake.darwinModules.unstableOverlay = unstableOverlayModule;
  flake.darwinModules.commonOverlay = commonOverlayModule;

  flake.darwinModules.default = {
    imports = [
      unstableOverlayModule
      commonOverlayModule
    ];
  };
}
