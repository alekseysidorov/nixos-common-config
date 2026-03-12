{ inputs, ... }:

{
  nixpkgs.overlays = [
    (import ./../pkgs)
    # Unstable overlay providing newer versions of selected packages.
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        localSystem = prev.stdenv.hostPlatform.system;
        inherit (prev) config overlays;
      };
    })
  ];
}
