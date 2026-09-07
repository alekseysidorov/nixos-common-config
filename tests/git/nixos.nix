{
  inputs,
  self,
  lib,
  ...
}:

{
  perSystem =
    { pkgs, system, ... }:
    lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      checks.git-nixos =
        let
          testSystem = inputs.nixpkgs.lib.nixosSystem {
            inherit system;

            modules = [
              self.modules.nixos.myCommon

              {
                myCommon.enableGitIntegration = true;
                system.stateVersion = "26.05";
              }
            ];
          };

          config = testSystem.config;
        in
        assert config.programs.git.enable;

        pkgs.runCommand "git-nixos-test" { } ''
          touch $out
        '';
    };
}
