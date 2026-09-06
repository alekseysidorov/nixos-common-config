{ ... }:
let
  gitSettings = {
    alias = {
      cln = "!git-clean-all --this-repo";
      swp = "!git-sweep-all --this-repo";
    };

    push = {
      autoSetupRemote = true;
      default = "simple";
      followTags = true;
    };

    fetch = {
      prune = true;
      followTags = true;
      all = true;
    };

    help.autocorrect = "prompt";
    diff.algorithm = "histogram";

    rerere = {
      enabled = true;
      autoupdate = true;
    };

    rebase = {
      autoSquash = true;
      autoStash = true;
      updateRefs = true;
    };

    pull.rebase = true;
  };

  gitLfsSettings = {
    filter.lfs = {
      clean = "git-lfs clean -- %f";
      smudge = "git-lfs smudge -- %f";
      process = "git-lfs filter-process";
      required = true;
    };
  };

  optionsModule =
    { lib, ... }:
    {
      key = "myCommon/enableGitIntegration/config";

      options.myCommon.enableGitIntegration = lib.mkEnableOption "the common Git defaults";
    };

  nixosModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf config.myCommon.enableGitIntegration {
        environment.systemPackages = [
          pkgs.git-clean-all
          pkgs.git-sweep-all
        ];

        programs.git = {
          enable = true;
          lfs.enable = true;
          config = gitSettings;
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
      config = lib.mkIf config.myCommon.enableGitIntegration {
        environment.systemPackages = [
          pkgs.git
          pkgs.git-lfs
          pkgs.git-clean-all
          pkgs.git-sweep-all
        ];

        # nix-darwin has no programs.git module, but Git reads /etc/gitconfig
        # on Darwin too. Mirror the NixOS module's generated system config.
        environment.etc.gitconfig.text = lib.generators.toGitINI (gitSettings // gitLfsSettings);
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
      config = lib.mkIf config.myCommon.enableGitIntegration {
        home.packages = [
          pkgs.git-clean-all
          pkgs.git-sweep-all
        ];

        programs.git = {
          enable = true;
          lfs.enable = true;
          settings = gitSettings;
        };
      };
    };
in
{
  flake = {
    nixosModules.myCommon.imports = [
      optionsModule
      nixosModule
    ];

    darwinModules.myCommon.imports = [
      optionsModule
      darwinModule
    ];

    homeManagerModules.myCommon.imports = [
      optionsModule
      homeManagerModule
    ];
  };
}
