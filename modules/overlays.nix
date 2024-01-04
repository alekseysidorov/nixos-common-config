{ flake, pkgs, ... }: {
  # Some tweaks for nix packages
  nixpkgs = {
    config.allowUnfree = true;
    # Some additional overlays
    overlays = [
      (final: prev: {
        unstable = import flake.inputs.nixpkgs-unstable {
          inherit (pkgs) system;
          config.allowUnfree = true;
        };
      })
    ];
  };
}
