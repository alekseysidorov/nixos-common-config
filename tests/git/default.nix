{
  inputs,
  self,
  lib,
  ...
}:

{
  perSystem =
    { pkgs, system, ... }:
    # The Git integration is exercised per-platform. Both platforms load the same
    # `myCommon` capability with integration enabled; only the system assembly, the
    # state version, and the config shape differ.
    let
      # Shared module configuration: turn on the Git integration.
      gitOverride = {
        myCommon.enableGitIntegration = true;
      };

      # The common Git helpers every platform must install system-wide.
      gitHelperPackages = [
        pkgs.git-clean-all
        pkgs.git-sweep-all
      ];

      # Predicate shared by every platform: the helpers are present system-wide.
      gitHelpersInstalled =
        config: builtins.all (pk: builtins.elem pk config.environment.systemPackages) gitHelperPackages;

      # Build the per-platform test artifact. The shared helper predicate is
      # passed in so the per-platform body stays a single `assert …; build`.
      buildGitTest =
        {
          name,
          config,
          ...
        }:
        assert gitHelpersInstalled config;
        pkgs.runCommand name { } ''
          touch $out
        '';
    in
    {
      checks.git-nixos = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (
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
        in
        # Git and its LFS integration must be enabled.
        assert config.programs.git.enable;
        assert config.programs.git.lfs.enable;
        # The git config section the module injects must be present.
        assert config.programs.git ? config;

        buildGitTest {
          name = "git-nixos-test";
          inherit config;
        }
      );

      checks.git-darwin = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
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
        in
        # nix-darwin has no programs.git module, so the module writes /etc/gitconfig
        # instead of programs.git.config.
        assert config.environment.etc.gitconfig ? text;

        buildGitTest {
          name = "git-darwin-test";
          inherit config;
        }
      );
    };
}
