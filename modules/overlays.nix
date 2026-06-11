{ inputs, ... }@self:

{
  nixpkgs.overlays = [
    # Local overlay providing custom packages and utilities.
    ((import ./../overlay.nix) self)
    # Unstable overlay providing newer versions of selected packages.
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        localSystem = prev.stdenv.hostPlatform.system;
        inherit (prev) config overlays;
      };
    })
  ];
}
