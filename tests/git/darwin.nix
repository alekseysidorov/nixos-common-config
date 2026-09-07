{
  inputs,
  self,
  lib,
  ...
}:

{
  perSystem =
    { pkgs, system, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      checks.git-darwin =
        let
          testSystem = inputs.nix-darwin.lib.darwinSystem {
            inherit system;

            modules = [
              self.modules.darwin.myCommon
              {
                myCommon.enableGitIntegration = true;
                system.stateVersion = 6;
              }
            ];
          };

          config = testSystem.config;
        in

        assert config.programs.git.enable;

        testSystem.system;
    };
}
