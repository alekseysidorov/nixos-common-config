{ nixpkgs-unstable
, config ? { allowUnfree = true; }
}:

final: prev: {
  # Unstable packages.
  unstable = import nixpkgs-unstable {
    inherit config;
    system = prev.stdenv.hostPlatform.system;

    overlays = [
      # Some additional packages.
      (import ./pkgs)
    ];
  };
}
