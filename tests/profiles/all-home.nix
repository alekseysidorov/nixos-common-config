# Build standalone Home Manager profiles in a minimal synthetic configuration.
#
# This verifies both module evaluation and the packages pulled in by a profile.

{
  inputs,
  lib,
  self,
  ...
}:

{
  perSystem =
    { pkgs, ... }:

    let
      mkHomeCheck =
        module:
        (inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs;
          };

          modules = [
            module

            # Minimal user context required to build a Home Manager
            # activation package without depending on a real host.
            {
              home = {
                username = "check";
                homeDirectory = if pkgs.stdenv.isDarwin then "/Users/check" else "/home/check";

                stateVersion = "26.05";
              };
            }
          ];
        }).activationPackage;

      # Only profiles that are expected to work as standalone Home Manager
      # modules belong here. Reusable fragments do not need an isolated check.
      homeProfiles = {
        nix-dev = self.modules.homeManager.nixDev;
        rust-dev = self.modules.homeManager.rustDev;
        dev-tools = self.modules.homeManager.devTools;
      };
    in
    {
      checks = lib.mapAttrs (_name: module: mkHomeCheck module) homeProfiles;
    };
}
