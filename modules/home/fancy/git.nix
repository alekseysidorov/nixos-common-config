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
      key = "myCommon/home/fancy/git";

      options.myCommon.home.fancy.git.enable = lib.mkEnableOption "the common Git defaults";
    };

  homeManagerModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf config.myCommon.home.fancy.git.enable {
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
  flake.modules.homeManager.myCommon.imports = [
    optionsModule
    homeManagerModule
  ];
}
