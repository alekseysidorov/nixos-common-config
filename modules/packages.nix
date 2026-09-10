{
  inputs,
  lib,
  ...
}:

let
  # Discover local packages against the final package set so they can depend
  # on capabilities introduced by preceding overlays and on sibling packages.
  localPackagesFor =
    pkgs:
    lib.filesystem.packagesFromDirectoryRecursive {
      inherit (pkgs) callPackage;
      directory = ../pkgs;
    };

  localOverlay = final: _prev: localPackagesFor final;

  # Expose an unstable package universe with the same common capabilities.
  unstableOverlay = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config = final.config;

      overlays = [
        inputs.nix-devtools.overlays.default
        localOverlay
      ];
    };
  };

  # Keep one canonical package-set extension for both the public overlay
  # and every platform module assembled into myCommon.
  defaultOverlay = lib.composeManyExtensions [
    inputs.nix-devtools.overlays.default
    unstableOverlay
    localOverlay
  ];

  # Installing myCommon should make its package capabilities available
  # through the ordinary `pkgs` argument of every contained module.
  packagesModule = {
    nixpkgs.overlays = [
      defaultOverlay
    ];
  };
in
{
  # Public package-set API for consumers that want the overlay directly.
  flake.overlays.default = defaultOverlay;

  # Each capability contributes its own fragment to the aggregate module.
  flake.modules = {
    nixos.myCommon.imports = [
      packagesModule
    ];
    darwin.myCommon.imports = [
      packagesModule
    ];
    homeManager.myCommon.imports = [
      packagesModule
    ];
  };
}
