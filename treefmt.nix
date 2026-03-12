# treefmt configuration
{ ... }:
{
  # Project root marker used by treefmt
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  programs.taplo.enable = true;
}
