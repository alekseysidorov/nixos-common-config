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

    let
      gitOverride = {
        myCommon.fancy.git.enable = true;
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

      buildGlobalOverrideTest =
        {
          name,
          systemGitConfig,
        }:
        pkgs.runCommand name { } ''
          export HOME="$TMPDIR/home"
          mkdir -p "$HOME"
          printf '%s' ${lib.escapeShellArg systemGitConfig} > "$TMPDIR/system-gitconfig"
          export GIT_CONFIG_SYSTEM="$TMPDIR/system-gitconfig"

          ${pkgs.git}/bin/git config --global pull.rebase false

          test "$(${pkgs.git}/bin/git config --get pull.rebase)" = false
          test "$(${pkgs.git}/bin/git config --get diff.algorithm)" = histogram
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

        test-git-home-disabled =
          let
            testHome = inputs.home-manager.lib.homeManagerConfiguration {
              inherit pkgs;

              modules = [
                self.modules.homeManager.myCommon

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
          assert !config.programs.git.enable;
          assert !gitHelpersInstalled config.home.packages;
          pkgs.runCommand "test-git-home-disabled" { } "touch $out";
      };

      systemChecks =
        lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          test-git-nixos =
            let
              testSystem = inputs.nixpkgs.lib.nixosSystem {
                inherit system;

                modules = [
                  self.modules.nixos.myCommon
                  gitOverride
                  { system.stateVersion = "26.05"; }
                ];
              };

              config = testSystem.config;
              systemGitConfig = config.environment.etc."gitconfig".text;
            in
            assert lib.hasInfix "[alias]" systemGitConfig;
            assert lib.hasInfix "cln" systemGitConfig;
            assert lib.hasInfix "git-clean-all --this-repo" systemGitConfig;
            assert builtins.elem pkgs.git config.environment.systemPackages;
            assert builtins.elem pkgs.git-lfs config.environment.systemPackages;
            assert builtins.elem pkgs.git-clean-all config.environment.systemPackages;
            assert builtins.elem pkgs.git-sweep-all config.environment.systemPackages;
            buildGlobalOverrideTest {
              name = "test-git-nixos";
              inherit systemGitConfig;
            };

          test-git-nixos-disabled =
            let
              testSystem = inputs.nixpkgs.lib.nixosSystem {
                inherit system;

                modules = [
                  self.modules.nixos.myCommon
                  { system.stateVersion = "26.05"; }
                ];
              };

              config = testSystem.config;
            in
            assert !(config.environment.etc ? "gitconfig");
            assert !(builtins.elem pkgs.git-clean-all config.environment.systemPackages);
            assert !(builtins.elem pkgs.git-sweep-all config.environment.systemPackages);
            pkgs.runCommand "test-git-nixos-disabled" { } "touch $out";
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          test-git-darwin =
            let
              testSystem = inputs.nix-darwin.lib.darwinSystem {
                inherit system;

                modules = [
                  self.modules.darwin.myCommon
                  gitOverride
                  { system.stateVersion = 6; }
                ];
              };

              config = testSystem.config;
              systemGitConfig = config.environment.etc."gitconfig".text;
            in
            assert lib.hasInfix "[alias]" systemGitConfig;
            assert lib.hasInfix "cln" systemGitConfig;
            assert lib.hasInfix "git-clean-all --this-repo" systemGitConfig;
            assert builtins.elem pkgs.git config.environment.systemPackages;
            assert builtins.elem pkgs.git-lfs config.environment.systemPackages;
            assert builtins.elem pkgs.git-clean-all config.environment.systemPackages;
            assert builtins.elem pkgs.git-sweep-all config.environment.systemPackages;
            buildGlobalOverrideTest {
              name = "test-git-darwin";
              inherit systemGitConfig;
            };

          test-git-darwin-disabled =
            let
              testSystem = inputs.nix-darwin.lib.darwinSystem {
                inherit system;

                modules = [
                  self.modules.darwin.myCommon
                  { system.stateVersion = 6; }
                ];
              };

              config = testSystem.config;
            in
            assert !(config.environment.etc ? "gitconfig");
            assert !(builtins.elem pkgs.git-clean-all config.environment.systemPackages);
            assert !(builtins.elem pkgs.git-sweep-all config.environment.systemPackages);
            pkgs.runCommand "test-git-darwin-disabled" { } "touch $out";
        };
    in
    {
      checks = homeChecks // systemChecks;
    };
}
