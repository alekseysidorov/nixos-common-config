{
  lib,
  ...
}:

{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:

    let
      inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

      # Enable the public command surface exactly as a consumer would.
      commandsModule = {
        myCommon.flake.commands.enable = true;
      };

      # Evaluate this flake's per-system configuration with commands enabled.
      #
      # The test deliberately observes only the resulting `apps` interface:
      # backend selection remains an implementation detail of commands.nix.
      apps = config.apps;

      activateProgram = apps.activate.program;
      cleanupProgram = apps.cleanup.program;

      # `apps.*.program` points at <package>/bin/<command>.
      # Recover the package output so the generated Nushell application can be
      # inspected during the build without discarding Nix string context.
      activatePackage = builtins.dirOf (builtins.dirOf activateProgram);
      cleanupPackage = builtins.dirOf (builtins.dirOf cleanupProgram);

      platformChecks =
        lib.optionalAttrs isLinux {
          test-commands-flake-nixos-activate = pkgs.runCommand "test-commands-flake-nixos-activate" { } ''
            # Intent: Linux system activation is implemented by nixos-rebuild.
            grep -R --fixed-strings "nixos-rebuild" ${activatePackage}

            # Darwin must not accidentally leak into the Linux backend.
            if grep -R --fixed-strings "darwin-rebuild" ${activatePackage}; then
              echo "activate unexpectedly contains the Darwin backend" >&2
              exit 1
            fi

            touch $out
          '';
        }
        // lib.optionalAttrs isDarwin {
          test-commands-flake-darwin-activate = pkgs.runCommand "test-commands-flake-darwin-activate" { } ''
            # Intent: Darwin system activation is implemented by darwin-rebuild.
            grep -R --fixed-strings "darwin-rebuild" ${activatePackage}

            # NixOS must not accidentally leak into the Darwin backend.
            if grep -R --fixed-strings "nixos-rebuild" ${activatePackage}; then
              echo "activate unexpectedly contains the NixOS backend" >&2
              exit 1
            fi

            touch $out
          '';
        };

      commonChecks = {
        test-commands-flake-apps-eval =
          # Intent: enabling commands publishes the stable public app surface.
          assert apps ? activate;
          assert apps ? cleanup;
          assert apps.activate.type == "app";
          assert apps.cleanup.type == "app";

          pkgs.runCommand "test-commands-flake-apps-eval" { } ''
            touch $out
          '';

        test-commands-flake-cleanup = pkgs.runCommand "test-commands-flake-cleanup" { } ''
          # Intent: cleanup remains a platform-independent Nix store command.
          grep -R --fixed-strings "nix store gc" ${cleanupPackage}
          grep -R --fixed-strings "nix store optimise" ${cleanupPackage}

          touch $out
        '';
      };
    in
    {
      imports = [
        commandsModule
      ];

      checks = commonChecks // platformChecks;
    };
}
