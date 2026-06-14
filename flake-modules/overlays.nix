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
in
{
  flake = {
    overlays.unstable = unstableOverlay;
    overlays.common = commonOverlay;

    nixosModules.unstableOverlay = overlayModule unstableOverlay;
    nixosModules.commonOverlay = overlayModule commonOverlay;

    darwinModules.unstableOverlay = overlayModule unstableOverlay;
    darwinModules.commonOverlay = overlayModule commonOverlay;
  };
}
