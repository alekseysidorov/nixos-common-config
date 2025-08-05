# Extra development stuff
{ pkgs, lib, ... }: {

  # Common develop nixos/nix-darwin configuration shared between Linux and macOS
  home.packages = with pkgs.unstable; [
    # Rust
    cargo-criterion
    cargo-deny
    cargo-machete
    cargo-nextest
    cargo-release
    # Unstable version are broken.
    pkgs.cargo-semver-checks
    cargo-watch
    cargo-workspaces
    criterion-table
    markdownlint-cli
    shellcheck
    taplo
    typos
    dprint
    just
    rustup
    sccache

    # Nix extensions
    nil
    nixd
    nixpkgs-fmt
    cachix

    # Useful utilites
    xh
  ];

  home.sessionVariables = lib.mkMerge [{
    RUSTC_WRAPPER = "sccache";
    EDITOR = "vim";
  }];

  # Popular extra paths.
  # TODO Implement home-manager module to manage cargo home configuration.
  home.sessionPath = lib.mkDefault [
    "$HOME/.cargo/bin" # For packages installed by Cargo
  ];
}
