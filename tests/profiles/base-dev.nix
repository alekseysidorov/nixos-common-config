# Verify the base-dev profile exports the same tool set for every module
# class, including the system graphs where Home Manager does not apply.
#
# Home Manager is covered separately in all-home. This check builds minimal
# NixOS and nix-darwin systems with the base module and asserts the expected
# base tools land in `environment.systemPackages`.

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
      # The base tools every module class must expose. Listing them here pins
      # the "same packages across platforms" contract the profile promises.
      #
      # Note: `dust` ships under the pname `du-dust` in nixpkgs.
      expectedPackages = [
        "bat"
        "du-dust"
        "eza"
        "fd"
        "fzf"
        "jq"
        "p7zip"
        "ripgrep"
        "tree"
        "unzip"
        "yq"
        "zip"
      ];

      # Normalize a derivation to a comparable package name.
      pkgName = p: p.pname or p.name;

      # Fail when any expected tool is missing, otherwise produce a trivial
      # output so the evaluation itself is the assertion.
      assertBaseTools =
        {
          name,
          config,
        }:
        let
          present = map pkgName config.environment.systemPackages;
        in
        assert (config.environment.systemPackages != [ ]);
        assert builtins.all (n: builtins.elem n present) expectedPackages;
        pkgs.runCommand name { } ''
          touch $out
        '';
    in
    {
      checks =
        lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          test-base-dev-nixos =
            let
              testSystem = inputs.nixpkgs.lib.nixosSystem {
                inherit system;

                modules = [
                  self.modules.nixos.baseDev
                  {
                    system.stateVersion = "26.05";
                  }
                ];
              };
            in
            assertBaseTools {
              name = "test-base-dev-nixos";
              inherit (testSystem) config;
            };
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          test-base-dev-darwin =
            let
              testSystem = inputs.nix-darwin.lib.darwinSystem {
                inherit system;

                modules = [
                  self.modules.darwin.baseDev
                  {
                    system.stateVersion = 6;
                  }
                ];
              };
            in
            assertBaseTools {
              name = "test-base-dev-darwin";
              inherit (testSystem) config;
            };
        };
    };
}
