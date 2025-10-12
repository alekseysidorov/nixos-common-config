{ inputs, ... }:

{
  nixpkgs.overlays = [
    (
      import ./../overlay.nix {
        nixpkgs-unstable = inputs.nixpkgs-unstable;
        # TODO Make it configurable
        config.allowUnfree = true;
      }
    )
  ];
}
