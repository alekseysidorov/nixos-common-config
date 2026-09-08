{ lib, ... }:

{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:

    let
      inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

      apps = config.apps;

      # `apps.*.program` points to <derivation>/bin/<command>.
      # Recover the backing derivation so behavioral checks can inspect the
      # generated Nushell application without depending on its implementation
      # being exported through `packages`.
      appPackage = app: builtins.dirOf (builtins.dirOf app.program);

      activatePackage = appPackage apps.activate;
      cleanupPackage = appPackage apps.cleanup;

      # Contract shared by every supported platform:
      # enabling the command capability publishes the same public app surface.
      commonChecks = {
        test-commands-flake-apps-eval =
          assert apps ? activate;
          assert apps ? cleanup;
          assert apps.activate.type == "app";
          assert apps.cleanup.type == "app";
          assert apps.activate.meta.description != "";
          assert apps.cleanup.meta.description != "";

          pkgs.runCommand "test-commands-flake-apps-eval" { } ''
            touch $out
          '';

        test-commands-flake-cleanup = pkgs.runCommand "test-commands-flake-cleanup" { } ''
          # Intent:
          # cleanup is platform-independent and performs both privileged and
          # user store garbage collection followed by store optimisation.
          grep -R --fixed-strings "sudo nix store gc -vv" ${cleanupPackage}
          grep -R --fixed-strings "nix store gc -vv" ${cleanupPackage}
          grep -R --fixed-strings "nix store optimise" ${cleanupPackage}

          touch $out
        '';
      };

      # Platform-specific contract:
      # `activate` keeps one stable public name while selecting exactly the
      # backend appropriate for the current host platform.
      platformChecks =
        lib.optionalAttrs isLinux {
          test-commands-flake-nixos-activate = pkgs.runCommand "test-commands-flake-nixos-activate" { } ''
            grep -R --fixed-strings "nixos-rebuild" ${activatePackage}

            if grep -R --fixed-strings "darwin-rebuild" ${activatePackage}; then
              echo "Darwin backend leaked into the NixOS activate command" >&2
              exit 1
            fi

            touch $out
          '';
        }
        // lib.optionalAttrs isDarwin {
          test-commands-flake-darwin-activate = pkgs.runCommand "test-commands-flake-darwin-activate" { } ''
            grep -R --fixed-strings "darwin-rebuild" ${activatePackage}

            if grep -R --fixed-strings "nixos-rebuild" ${activatePackage}; then
              echo "NixOS backend leaked into the Darwin activate command" >&2
              exit 1
            fi

            touch $out
          '';
        };
    in
    {
      # Scenario under test:
      # command publication is an explicit per-system decision because its
      # result lives under `apps.<system>`.
      myCommon.flake.commands.enable = true;

      checks = commonChecks // platformChecks;
    };
}
