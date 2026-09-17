{
  inputs,
  lib,
  ...
}:

{
  perSystem =
    {
      pkgs,
      ...
    }:

    let
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

            myCommon.home.fancy.vim.enable = true;
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

      checks = {
        test-vim-home =
          assert homeConfig.config.programs.vim.enable;
          assert homeConfig.config.programs.vim.defaultEditor;
          assert lib.hasInfix "colorscheme fleetish" homeConfig.config.programs.vim.extraConfig;
          assert lib.any (plugin: lib.getName plugin == "fleetish-vim") homePlugins;

          testVim "test-vim-home" homeConfig.config.programs.vim.package;
      };
    in
    {
      inherit checks;
    };
}
