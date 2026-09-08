{
  inputs,
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
      nixosConfig = inputs.nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          inputs.self.modules.nixos.myCommon

          {
            myCommon.enableVimIntegration = true;
          }
        ];
      };

      homeConfig = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          inputs.self.modules.homeManager.myCommon

          {
            nix.package = pkgs.nix;
            home = {
              username = "test";
              homeDirectory = "/home/test";
              stateVersion = "25.05";
            };

            myCommon.enableVimIntegration = true;
          }
        ];
      };

      # Verify behavior through Vim itself rather than depending on how
      # buildVimPlugin/customize happen to lay files out in the store.
      testVim =
        name: vim:
        pkgs.runCommand name { } ''
          export HOME="$TMPDIR"

          ${vim}/bin/vim \
            -n \
            -e \
            -V1 \
            +"call writefile([g:colors_name], '$TMPDIR/colorscheme')" \
            +'qa!'

          test "$(cat "$TMPDIR/colorscheme")" = "fleetish"

          touch $out
        '';

      homePlugins = homeConfig.config.programs.vim.plugins;

      commonChecks = {
        test-vim-nixos =
          assert nixosConfig.config.programs.vim.enable;
          assert nixosConfig.config.programs.vim.defaultEditor;

          testVim "test-vim-nixos" nixosConfig.config.programs.vim.package;

        test-vim-home =
          assert homeConfig.config.programs.vim.enable;
          assert homeConfig.config.programs.vim.defaultEditor;
          assert lib.hasInfix "colorscheme fleetish" homeConfig.config.programs.vim.extraConfig;
          assert lib.any (plugin: lib.getName plugin == "fleetish-vim") homePlugins;

          testVim "test-vim-home" homeConfig.config.programs.vim.package;
      };

      platformChecks = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        test-vim-darwin =
          let
            darwinConfig = inputs.nix-darwin.lib.darwinSystem {
              inherit system;

              modules = [
                inputs.self.modules.darwin.myCommon

                {
                  myCommon.enableVimIntegration = true;
                  system.stateVersion = 6;
                }
              ];
            };

            vim = lib.findFirst (
              package: lib.getName package == "vim"
            ) null darwinConfig.config.environment.systemPackages;
          in
          assert darwinConfig.config.environment.variables.EDITOR == "vim";
          assert darwinConfig.config.environment.variables.VISUAL == "vim";
          assert vim != null;

          testVim "test-vim-darwin" vim;
      };
    in
    {
      checks = commonChecks // platformChecks;
    };
}
