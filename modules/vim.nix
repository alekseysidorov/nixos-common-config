{ ... }:

let
  optionsModule =
    { lib, ... }:
    {
      key = "myCommon/enableVimIntegration/config";

      options.myCommon.enableVimIntegration = lib.mkEnableOption "the common Vim defaults";
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

          # Pin this to a concrete commit once you've fetched the hash.
          rev = "e2d3c7f";
          hash = "sha256-ciHSCI2M8CqKmYY9HaF88n3ev0HTLEJsTSB/UK+m9ps=";
        };
      };
    in
    [
      fleetish
      pkgs.vimPlugins.vim-easy-align
    ];

  mkVim =
    pkgs:
    pkgs.vim-full.customize {
      name = "vim";

      vimrcConfig = {
        customRC = vimConfig;
        packages.myCommon.start = mkVimPlugins pkgs;
      };
    };

  nixosModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      config = lib.mkIf config.myCommon.enableVimIntegration {
        programs.vim = {
          enable = true;
          defaultEditor = true;
          package = mkVim pkgs;
        };
      };
    };

  darwinModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      config = lib.mkIf config.myCommon.enableVimIntegration {
        environment.systemPackages = [
          (mkVim pkgs)
        ];

        environment.variables = {
          EDITOR = "vim";
          VISUAL = "vim";
        };
      };
    };

  homeManagerModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    {
      config = lib.mkIf config.myCommon.enableVimIntegration {
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
  flake.modules = {
    nixos.myCommon.imports = [
      optionsModule
      nixosModule
    ];

    darwin.myCommon.imports = [
      optionsModule
      darwinModule
    ];

    homeManager.myCommon.imports = [
      optionsModule
      homeManagerModule
    ];
  };
}
