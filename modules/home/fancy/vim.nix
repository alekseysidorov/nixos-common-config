{ ... }:

let
  optionsModule =
    { lib, ... }:
    {
      key = "myCommon/home/fancy/vim";

      options.myCommon.home.fancy.vim.enable = lib.mkEnableOption "the common Vim defaults";
    };

  vimConfig = ''
    set background=dark
    set termguicolors
    colorscheme fleetish
  '';

  mkVimPlugins =
    pkgs:
    let
      fleetish = pkgs.vimUtils.buildVimPlugin {
        pname = "fleetish-vim";
        version = "unstable";

        src = pkgs.fetchFromGitHub {
          owner = "krfl";
          repo = "fleetish-vim";
          rev = "e2d3c7f";
          hash = "sha256-ciHSCI2M8CqKmYY9HaF88n3ev0HTLEJsTSB/UK+m9ps=";
        };
      };
    in
    [
      fleetish
      pkgs.vimPlugins.vim-easy-align
    ];

  homeManagerModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf config.myCommon.home.fancy.vim.enable {
        programs.vim = {
          enable = true;
          defaultEditor = true;

          plugins = mkVimPlugins pkgs;
          extraConfig = vimConfig;
        };
      };
    };
in
{
  flake.modules.homeManager.myCommon.imports = [
    optionsModule
    homeManagerModule
  ];
}
