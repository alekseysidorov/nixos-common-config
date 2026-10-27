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
      mkHome =
        nushellConfig:
        inputs.home-manager.lib.homeManagerConfiguration {
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

              myCommon.fancy.nushell = nushellConfig;
            }
          ];
        };

      # Scenario:
      # Enable the common Nushell environment without changing Bash or Zsh.
      integration = mkHome {
        enable = true;
      };

      integrationConfig = integration.config;

      starshipConfig =
        integrationConfig.home.file.${integrationConfig.programs.starship.configPath}.source;

      # Scenario:
      # Explicitly opt Bash and Zsh into interactive trampolining to Nushell.
      trampolines = mkHome {
        enable = true;

        trampoline = {
          bash.enable = true;
          zsh.enable = true;
        };
      };

      trampolineConfig = trampolines.config;

      darwinHomebrewShellInit = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin (
        let
          testSystem = inputs.nix-darwin.lib.darwinSystem {
            inherit system;

            modules = [
              {
                system.primaryUser = "test";
                system.stateVersion = 6;
                users.users.test.home = "/Users/test";

                homebrew = {
                  enable = true;
                  enableBashIntegration = true;
                  enableZshIntegration = true;
                };
              }
            ];
          };

          config = testSystem.config;
        in
        {
          bash = config.programs.bash.interactiveShellInit;
          zsh = config.programs.zsh.interactiveShellInit;
        }
      );

      # These assertions only inspect generated configuration text.
      # Strip Nix string context so store paths can safely participate
      # in string matching without altering production dependency tracking.
      plainText = builtins.unsafeDiscardStringContext;

      expectedNushellExe = plainText (lib.getExe trampolineConfig.programs.nushell.package);

      bashInit = plainText trampolineConfig.programs.bash.initExtra;
      zshInit = plainText trampolineConfig.programs.zsh.initContent;

      mkEvalCheck =
        name:
        pkgs.runCommand name { } ''
          touch $out
        '';
    in
    {
      checks = {
        test-nushell-home-integration-eval =
          # Nushell integration configures the common shell environment.
          assert integrationConfig.programs.nushell.enable;
          assert integrationConfig.programs.fish.enable;
          assert integrationConfig.programs.starship.enable;
          assert integrationConfig.home.shell.enableShellIntegration;

          # Nushell integration alone must not implicitly enable source shells.
          assert !integrationConfig.programs.bash.enable;
          assert !integrationConfig.programs.zsh.enable;

          # Nushell integration should has an external completers.
          assert integrationConfig.programs.nushell.settings.completions.external.enable;
          assert integrationConfig.programs.nushell.settings.completions.external.completer != null;

          mkEvalCheck "test-nushell-home-integration-eval";

        test-nushell-starship-prompt =
          pkgs.runCommand "test-nushell-starship-prompt"
            {
              nativeBuildInputs = [
                pkgs.python3
                pkgs.starship
              ];
            }
            ''
              export STARSHIP_CONFIG=${starshipConfig}
              export STARSHIP_CACHE="$TMPDIR/starship-cache"
              export TERM=xterm-256color

              python3 - <<'PY'
              import re
              import os
              import subprocess
              import tomllib
              from pathlib import Path

              config = tomllib.loads(Path(os.environ["STARSHIP_CONFIG"]).read_text())
              assert "$line_break" in config["format"]
              assert "$rust" not in config["format"]
              assert config["character"]["success_symbol"] == r"[\$](purple)"
              assert config["character"]["error_symbol"] == r"[\$](red)"

              ansi = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")
              for status in (0, 1):
                  result = subprocess.run(
                      ["starship", "prompt", "--status", str(status)],
                      check=True,
                      capture_output=True,
                      text=True,
                  )
                  assert "Error in module `character`" not in result.stderr
                  rendered = ansi.sub("", result.stdout).replace("%{", "").replace("%}", "")
                  assert "\n" in rendered, repr(rendered)
                  assert rendered.splitlines()[-1].strip() == "$", repr(rendered)
              PY

              touch $out
            '';

        test-nushell-home-trampoline-eval =
          # Explicit trampoline configuration enables its source shells.
          assert trampolineConfig.programs.bash.enable;
          assert trampolineConfig.programs.zsh.enable;

          # Interactive source shells redirect into the configured Nushell.
          assert lib.hasInfix "exec ${expectedNushellExe}" bashInit;
          assert lib.hasInfix "exec ${expectedNushellExe}" zshInit;

          # Escape hatches start interactive shells without reading the rc files
          # containing the trampoline.
          assert trampolineConfig.programs.nushell.shellAliases.bashInteractive == "exec bash --norc -i";
          assert trampolineConfig.programs.nushell.shellAliases.zshInteractive == "exec zsh --no-rcs -i";

          mkEvalCheck "test-nushell-home-trampoline-eval";

      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        test-nushell-darwin-homebrew-integration-eval =
          let
            systemInit = darwinHomebrewShellInit;
          in
          assert lib.hasInfix "brew shellenv bash" systemInit.bash;
          assert lib.hasInfix "brew shellenv zsh" systemInit.zsh;
          assert lib.hasInfix "/opt/homebrew/bin/brew" systemInit.zsh;
          assert lib.hasInfix "/opt/homebrew/bin/brew" systemInit.bash;
          mkEvalCheck "test-nushell-darwin-homebrew-integration-eval";
      };
    };
}
