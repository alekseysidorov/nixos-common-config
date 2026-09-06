{ inputs, lib, ... }:

let
  localPackagesFor =
    pkgs:
    lib.filesystem.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage;
      directory = ../pkgs;
    };

  unstableOverlay = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config = final.config;
    };
  };

  localOverlay = final: _prev: localPackagesFor final;

  overlay = lib.composeManyExtensions [
    inputs.rust-dev-flake.overlays.default
    unstableOverlay
    localOverlay
  ];
in
{
  flake.overlays.default = overlay;

  perSystem =
    { pkgs, ... }:
    {
      packages = localPackagesFor pkgs;
    };
}
