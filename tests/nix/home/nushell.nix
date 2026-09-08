{
  inputs,
  self,
  lib,
  ...
}:

{
  perSystem =
    { pkgs, ... }:

    let
      mkHome =
        nushellConfig:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            self.modules.homeManager.myCommon

            {
              home = {
                username = "test";
                homeDirectory = "/home/test";
                stateVersion = "26.05";
              };

              myCommon.home.nushell = nushellConfig;
            }
          ];
        };

      # Scenario:
      # Enable the common Nushell environment without changing Bash or Zsh.
      integration = mkHome {
        enable = true;
      };

      integrationConfig = integration.config;

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
      checks.test-nushell-home-integration-eval =
        # Nushell integration configures the common shell environment.
        assert integrationConfig.programs.nushell.enable;
        assert integrationConfig.programs.fish.enable;
        assert integrationConfig.programs.starship.enable;
        assert integrationConfig.programs.nix-your-shell.enable;
        assert integrationConfig.programs.nix-your-shell.enableNushellIntegration;
        assert integrationConfig.home.shell.enableShellIntegration;

        # Nushell integration alone must not implicitly enable source shells.
        assert !integrationConfig.programs.bash.enable;
        assert !integrationConfig.programs.zsh.enable;

        mkEvalCheck "test-nushell-home-integration-eval";

      checks.test-nushell-home-trampoline-eval =
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
    };
}
