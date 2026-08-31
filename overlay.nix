{ inputs, ... }:

final: prev:
let
  system = prev.stdenv.hostPlatform.system;
in
{
  # Unstable overlay providing newer versions of selected packages.
  unstable = import inputs.nixpkgs-unstable {
    localSystem = system;
    inherit (final) config overlays;
  };

  # Additional packages from flake inputs.
  nufmt = inputs.nufmt.packages.${system}.nufmt;

  # Custom packages.
  comchan = final.unstable.callPackage ./pkgs/comchan.nix { };

  # Preserve the common overlay API; the implementation lives in rust-dev-flake.
  inherit (inputs.rust-dev-flake.overlays.default final prev) writeNuApplication;
}
