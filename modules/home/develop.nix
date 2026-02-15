# Common development stuff for nixos and nix-darwin
{ pkgs, lib, ... }:
{

  # Common develop nixos/nix-darwin configuration shared between Linux and macOS
  home.packages = with pkgs.unstable; [
    # Rust
    pkgs.rustup
    sccache
    # Nix extensions
    nil
    nixd
    nixfmt
    devenv
    attic-client
    # Useful utilites
    xh
    # Gitlab tools
    gitlab-ci-ls
    gitlab-ci-linter
  ];

  home.sessionVariables = lib.mkMerge [
    {
      RUSTC_WRAPPER = "sccache";
    }
  ];

  # Popular extra paths.
  # TODO Implement home-manager module to manage cargo home configuration.
  home.sessionPath = lib.mkDefault [
    "$HOME/.cargo/bin" # For packages installed by Cargo
  ];
}
