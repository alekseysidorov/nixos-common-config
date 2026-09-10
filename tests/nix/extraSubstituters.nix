{
  inputs,
  self,
  lib,
  ...
}:

{
  perSystem =
    { pkgs, system, ... }:

    let
      enabledUri = "https://enabled.example.org";
      enabledKey = "enabled.example.org-1:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

      disabledUri = "https://disabled.example.org";
      disabledKey = "disabled.example.org-1:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";

      # Define known substituters. Presence alone must not enable them.
      substituters = {
        myCommon.nix.extraSubstituters = {
          enabled = {
            uri = enabledUri;
            publicKey = enabledKey;
          };

          disabled = {
            uri = disabledUri;
            publicKey = disabledKey;
          };
        };
      };

      # Enable exactly one substituter from another module to exercise
      # normal Nix module merging.
      enableSubstituter = {
        myCommon.nix.extraSubstituters.enabled.enable = true;
      };

      # Verify both sides of the contract:
      # enabled substituters are emitted, disabled ones are not.
      substitutersConfigured =
        config:
        let
          settings = config.nix.settings;
        in
        builtins.elem enabledUri settings.extra-substituters
        && builtins.elem enabledKey settings.extra-trusted-public-keys
        && !(builtins.elem disabledUri settings.extra-substituters)
        && !(builtins.elem disabledKey settings.extra-trusted-public-keys);

      buildSubstituterTest =
        {
          name,
          config,
        }:
        assert substitutersConfigured config;
        pkgs.runCommand name { } ''
          touch $out
        '';

      nixosChecks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        test-extra-substituters-nixos =
          let
            testSystem = inputs.nixpkgs.lib.nixosSystem {
              inherit system;

              modules = [
                self.modules.nixos.myCommon
                substituters
                enableSubstituter

                {
                  system.stateVersion = "26.05";
                }
              ];
            };
          in
          buildSubstituterTest {
            name = "test-extra-substituters-nixos";
            inherit (testSystem) config;
          };
      };

      darwinChecks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        test-extra-substituters-darwin =
          let
            testSystem = inputs.nix-darwin.lib.darwinSystem {
              inherit system;

              modules = [
                self.modules.darwin.myCommon
                substituters
                enableSubstituter

                {
                  system.stateVersion = 6;
                }
              ];
            };
          in
          buildSubstituterTest {
            name = "test-extra-substituters-darwin";
            inherit (testSystem) config;
          };
      };

      homeChecks = {
        test-extra-substituters-home =
          let
            testHome = inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;

              modules = [
                self.modules.homeManager.myCommon
                substituters
                enableSubstituter

                {
                  nix.package = pkgs.nix;
                  home = {
                    username = "test";
                    homeDirectory = "/home/test";
                    stateVersion = "26.05";
                  };
                }
              ];
            };
          in
          buildSubstituterTest {
            name = "test-extra-substituters-home";
            inherit (testHome) config;
          };
      };
    in
    {
      checks = nixosChecks // darwinChecks // homeChecks;
    };
}
