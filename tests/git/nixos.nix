{
  inputs,
  self,
  lib,
  ...
}:

{
  perSystem =
    {
      pkgs,
      system,
      ...
    }:
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
        # Git must be enabled.
        assert config.programs.git.enable;
        # Git LFS integration is enabled.
        assert config.programs.git.lfs.enable;
        # The git config section the module injects must be present.
        assert config.programs.git ? config;
        # Both helper packages must be installed into the system.
        assert builtins.elem pkgs.git-clean-all config.environment.systemPackages;
        assert builtins.elem pkgs.git-sweep-all config.environment.systemPackages;

        pkgs.runCommand "git-nixos-test" { } ''
          touch $out
        '';
    };
}
