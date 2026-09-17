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
      directory = ../../pkgs;
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
  # Each capability contributes its own fragment to the aggregate module.
  #
  # Apply the overlay once in the NixOS and nix-darwin graphs so `pkgs`
  # exposes the shared unstable universe and the local packages. Home Manager
  # reuses that same package set under `useGlobalPkgs`, so it must not
  # re-apply `nixpkgs.overlays` (those options are disabled there). Consumers
  # that build a standalone Home Manager package set can apply
  # `inputs.my-common.overlays.default` themselves.
  flake.modules = {
    nixos.myCommon.imports = [
      packagesModule
    ];
    darwin.myCommon.imports = [
      packagesModule
    ];
  };
}
