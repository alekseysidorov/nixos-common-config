# Extra development stuff
{ pkgs, ... }: {

  # Common develop nixos/nix-darwin configuration shared between Linux and macOS
  home.packages = with pkgs; [
    # Rust
    cargo-criterion
    cargo-deny
    cargo-machete
    cargo-nextest
    cargo-watch
    criterion-table
    markdownlint-cli
    shellcheck
    taplo
    typos
  ];
}
