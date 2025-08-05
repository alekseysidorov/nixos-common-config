{ inputs, ... }:

{
  nixpkgs = {
    overlays = [
      (
        import ./../overlay.nix {
          nixpkgs-unstable = inputs.nixpkgs-unstable;
          config.allowUnfree = true;
        }
      )
    ];
  };
}
