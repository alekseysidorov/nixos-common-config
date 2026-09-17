{
  inputs,
  lib,
  ...
}:

{
  perSystem =
    { pkgs, system, ... }:

    let
      secretOptionsFile = "/run/secrets/nix.conf";

      nixosConfig = inputs.nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          inputs.self.modules.nixos.myCommon

          {
            myCommon.nix.secretOptionsFile = secretOptionsFile;
          }
        ];
      };

      homeConfig = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          inputs.self.modules.homeManager.myCommon

          {
            home.username = "test";
            home.homeDirectory = "/home/test";
            home.stateVersion = "25.05";

            nix.package = pkgs.nix;

            myCommon.nix.secretOptionsFile = secretOptionsFile;
          }
        ];
      };

      hasSecretOptions = value: lib.hasInfix "!include ${secretOptionsFile}" value;
    in
    {
      checks = {
        test-secret-options-nixos =
          assert hasSecretOptions nixosConfig.config.nix.extraOptions;
          pkgs.runCommand "test-secret-options-nixos" { } ''
            touch $out
          '';

        test-secret-options-home =
          assert hasSecretOptions homeConfig.config.nix.extraOptions;
          pkgs.runCommand "test-secret-options-home" { } ''
            touch $out
          '';
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        test-secret-options-darwin =
          let
            darwinConfig = inputs.nix-darwin.lib.darwinSystem {
              inherit system;

              modules = [
                inputs.self.modules.darwin.myCommon

                {
                  myCommon.nix.secretOptionsFile = secretOptionsFile;
                }
              ];
            };
          in
          assert hasSecretOptions darwinConfig.config.nix.extraOptions;
          pkgs.runCommand "test-secret-options-darwin" { } ''
            touch $out
          '';
      };
    };
}
