# Common development configuration for NixOS and nix-darwin
{ pkgs, lib, ... }:
{

  # Shared development configuration for Linux and macOS
  home.packages = with pkgs.unstable; [
    # Rust toolchain and related tooling
    pkgs.rustup
    sccache
    # Nix tooling and extensions
    nil
    nixd
    attic-client
    # Utilities
    xh
    # GitLab tools
    gitlab-ci-ls
    gitlab-ci-linter
  ];

  home.sessionVariables = lib.mkMerge [
    {
      RUSTC_WRAPPER = "sccache";
    }
  ];

  # Common additional paths
  # TODO: Implement a home-manager module to manage Cargo home configuration.
  home.sessionPath = lib.mkDefault [
    "$HOME/.cargo/bin" # For packages installed by Cargo
  ];
}
