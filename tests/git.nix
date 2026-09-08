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
      gitOverride = {
        myCommon.enableGitIntegration = true;
      };

      gitHelpersInstalled =
        packages:
        builtins.all (package: builtins.elem package packages) [
          pkgs.git-clean-all
          pkgs.git-sweep-all
        ];

      buildGitTest =
        {
          name,
          packages,
        }:
        assert gitHelpersInstalled packages;
        pkgs.runCommand name { } ''
          touch $out
        '';

      nixosChecks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        test-git-nixos =
          let
            testSystem = inputs.nixpkgs.lib.nixosSystem {
              inherit system;

              modules = [
                self.modules.nixos.myCommon
                gitOverride

                {
                  system.stateVersion = "26.05";
                }
              ];
            };

            config = testSystem.config;
          in
          assert config.programs.git.enable;
          assert config.programs.git.lfs.enable;
          assert config.programs.git ? config;

          buildGitTest {
            name = "test-git-nixos";
            packages = config.environment.systemPackages;
          };
      };

      darwinChecks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        test-git-darwin =
          let
            testSystem = inputs.nix-darwin.lib.darwinSystem {
              inherit system;

              modules = [
                self.modules.darwin.myCommon
                gitOverride

                {
                  system.stateVersion = 6;
                }
              ];
            };

            config = testSystem.config;
          in
          assert config.environment.etc.gitconfig ? text;

          buildGitTest {
            name = "test-git-darwin";
            packages = config.environment.systemPackages;
          };
      };

      homeChecks = {
        test-git-home =
          let
            testHome = inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;

              modules = [
                self.modules.homeManager.myCommon
                gitOverride

                {
                  home = {
                    username = "test";
                    homeDirectory = "/home/test";
                    stateVersion = "26.05";
                  };
                }
              ];
            };

            config = testHome.config;
          in
          assert config.programs.git.enable;
          assert config.programs.git.lfs.enable;

          buildGitTest {
            name = "test-git-home";
            packages = config.home.packages;
          };
      };
    in
    {
      checks = nixosChecks // darwinChecks // homeChecks;
    };
}
