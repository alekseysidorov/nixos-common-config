# Development tools for working on Nix expressions, flakes, and NixOS/Home Manager
# configurations.
#
# Project-specific environments still belong to each repository's devShell.
# This module only provides the tooling that is useful across Nix projects.
{ ... }:
{
  flake.modules.homeManager.nixDev =
    { pkgs, ... }:
    {
      # Automatically enter project-provided Nix environments.
      #
      # nix-direnv caches evaluated environments, avoiding a full `nix develop`
      # evaluation every time a project directory is entered.
      programs.direnv = {
        enable = true;
        # Keep this explicit even though Home Manager currently enables
        # nix-direnv by default: using nix-direnv is part of this profile's
        # intended behaviour rather than an incidental upstream default.
        nix-direnv.enable = true;
        # `.direnv/` is runtime/cache state and should never be committed.
        # TODO enable when home-manager-26.11 become stable.
        # enableGitIntegration = true;
      };

      home.packages = with pkgs; [
        # Nix language tooling.
        #
        # nixd is the primary LSP. Do not install nil alongside it by default:
        # they occupy the same role, while nixd also understands NixOS and
        # Home Manager option evaluation particularly well.
        nixd
        nixfmt
        # Static analysis.
        statix
        deadnix
        # Package authoring and updates.
        nix-init
        nurl
        nix-update
        # Inspect why derivations, closures, and lock files look the way they do.
        nix-diff
        nix-tree
        nix-melt
        nvd
        # Make long Nix builds easier to understand without changing their
        # semantics.
        nix-output-monitor
      ];
    };
}
