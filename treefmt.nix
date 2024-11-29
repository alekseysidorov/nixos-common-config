# treefmt.nix
{ ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";

  programs.nixpkgs-fmt.enable = true;
  programs.nufmt.enable = true;
  programs.taplo.enable = true;
}
