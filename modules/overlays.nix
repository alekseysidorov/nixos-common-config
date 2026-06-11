{ inputs, ... }:

{
  nixpkgs.overlays = [
    # Local overlay providing custom packages and utilities.
    (import ./../pkgs)
    (
      final: prev:
      let
        system = prev.stdenv.hostPlatform.system;
      in
      {
        # Unstable overlay providing newer versions of selected packages.
        unstable = import inputs.nixpkgs-unstable {
          localSystem = system;
          inherit (prev) config overlays;
        };
        # Additional packages from flake inputs.
        nufmt = final.callPackage inputs.nufmt { };
      }
    )
  ];
}
