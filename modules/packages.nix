{ inputs, lib, ... }:

let
  localPackagesFor =
    pkgs:
    lib.filesystem.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage;
      directory = ../pkgs;
    };

  localOverlay = final: _prev: localPackagesFor final;

  unstableOverlay = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config = final.config;

      overlays = [
        inputs.rust-dev-flake.overlays.default
        inputs.rust-overlay.overlays.default
        localOverlay
      ];
    };
  };
in
{
  flake.overlays.default = lib.composeManyExtensions [
    inputs.rust-dev-flake.overlays.default
    inputs.rust-overlay.overlays.default
    unstableOverlay
    localOverlay
  ];

  perSystem =
    { pkgs, ... }:
    {
      packages = localPackagesFor pkgs;
    };
}
