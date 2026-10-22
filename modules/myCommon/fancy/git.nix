{ self, ... }:
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

  optionsModule =
    { lib, ... }:
    {
      key = "myCommon/fancy/git";

      options.myCommon.fancy.git.enable = lib.mkEnableOption "the common Git defaults";
    };

  homeManagerModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      pkgs' = pkgs.extend self.overlays.default;
    in
    {
      key = "my-common/fancy/git";
      config = lib.mkIf config.myCommon.fancy.git.enable {
        home.packages = [
          pkgs'.git-clean-all
          pkgs'.git-sweep-all
        ];

        programs.git = {
          enable = true;
          lfs.enable = true;
          settings = gitSettings;
        };
      };
    };

  systemModule =
    {
      lib,
      pkgs,
      ...
    }:
    let
      pkgs' = pkgs.extend self.overlays.default;
    in
    {
      # Git reads the system config before the user's global config. This
      # gives every user the common defaults while keeping `git config
      # --global` as the natural per-user override.
      environment.etc."gitconfig".text = lib.mkDefault (lib.generators.toINI { } gitSettings);

      environment.systemPackages = [
        pkgs.git
        pkgs.git-lfs
        pkgs'.git-clean-all
        pkgs'.git-sweep-all
      ];
    };
in
{
  flake.modules.homeManager.myCommon.imports = [
    optionsModule
    homeManagerModule
  ];

  flake.modules.nixos.myCommon = systemModule;
  flake.modules.darwin.myCommon = systemModule;
}
