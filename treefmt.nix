# treefmt.nix
{ ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";

  programs.nixfmt.enable = true;
  programs.taplo.enable = true;
}
