{
  inputs,
  self,
  ...
}:

{
  perSystem =
    { pkgs, ... }:

    let
      gitOverride = {
        myCommon.home.fancy.git.enable = true;
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

      homeChecks = {
        test-git-home =
          let
            testHome = inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;

              modules = [
                self.modules.homeManager.myCommon
                gitOverride

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
      checks = homeChecks;
    };
}
