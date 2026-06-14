# treefmt configuration
{ pkgs, ... }:
{
  # Project root marker used by treefmt
  projectRootFile = "flake.nix";

  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt-rs;
  };
  programs.taplo.enable = true;
}
