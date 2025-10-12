{ inputs, ... }:

{
  nixpkgs.overlays = [
    (import ./../pkgs)
    # Unstable overlay to get the latest versions of some packages.
    (final: prev: {
      unstable = import inputs.nixpkgs-unstable {
        inherit (prev) system config overlays;
      };
    })
  ];
}
