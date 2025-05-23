# Extra development stuff
{ pkgs, ... }: {

  # Common develop nixos/nix-darwin configuration shared between Linux and macOS
  home.packages = with pkgs.unstable; [
    # Rust
    cargo-criterion
    cargo-deny
    cargo-machete
    cargo-nextest
    cargo-release
    cargo-semver-checks
    cargo-watch
    cargo-workspaces
    criterion-table
    markdownlint-cli
    shellcheck
    taplo
    typos
  ];
}
