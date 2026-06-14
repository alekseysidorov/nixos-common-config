{ inputs, ... }:

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
  # Define module that adds the unstable overlay to the system configuration.
  unstableModule = {
    nixpkgs.overlays = [
      unstableOverlay
    ];
  };
in
{
  flake = {
    overlays.unstable = unstableOverlay;
    nixosModules.unstableOverlay = unstableModule;
    darwinModules.unstableOverlay = unstableModule;
  };
}
