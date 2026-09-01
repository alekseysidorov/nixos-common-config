{ inputs, ... }:
let
  gitSettings = {
    alias = {
      cln = "!git-clean-all";
      swp = "!git-sweep-all";
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

  mkGitTools =
    pkgs:
    let
      writeNuShellApplication =
        pkgs.callPackage "${inputs.rust-dev-flake}/lib/write-nu-shell-application.nix"
          { };

      gitCleanAll = writeNuShellApplication {
        name = "git-clean-all";
        runtimeInputs = [
          pkgs.git
          pkgs.findutils
        ];
        text = ''
          # Clean ignored and untracked files in a Git repository.
          def main [
            root: path = "." # Repository or root directory to process.
            --recursive (-r) # Process every Git repository under root.
          ] {
            let root = ($root | path expand)
            let repos = if $recursive {
              ^find $root -type d -name .git -prune
              | lines
              | each { path dirname }
            } else {
              [$root]
            }

            $repos | each { |repo|
                print $"Cleaning ($repo)"
                ^git -C $repo clean -dxf -e "/.vscode" -e ".idea" -e ".zed" -e ".private" -e ".cargo"
            } | ignore
          }
        '';
      };

      gitSweepAll = writeNuShellApplication {
        name = "git-sweep-all";
        runtimeInputs = [
          pkgs.git
          pkgs.findutils
        ];
        text = ''
          # Delete local branches with a gone upstream in a Git repository.
          def main [
            root: path = "." # Repository or root directory to process.
            --recursive (-r) # Process every Git repository under root.
          ] {
            let root = ($root | path expand)
            let repos = if $recursive {
              ^find $root -type d -name .git -prune
              | lines
              | each { path dirname }
            } else {
              [$root]
            }

            $repos | each { |repo|
                print $"Sweeping ($repo)"
                ^git -C $repo fetch -p

                ^git -C $repo for-each-ref --format "%(refname) %(upstream:track)" refs/heads
                | lines
                | where { str ends-with "[gone]" }
                | each { |branch|
                    let name = ($branch | split row " " | first | str replace "refs/heads/" "")
                    ^git -C $repo branch -D $name
                  }
            } | ignore
          }
        '';
      };
    in
    [
      gitCleanAll
      gitSweepAll
    ];

  optionsModule =
    { lib, ... }:
    {
      key = "myCommon/gitDefaults/config";

      options.myCommon.gitDefaults = lib.mkEnableOption "the common Git defaults";
    };

  nixosModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkIf config.myCommon.gitDefaults {
        environment.systemPackages = mkGitTools pkgs;

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
      config = lib.mkIf config.myCommon.gitDefaults {
        environment.systemPackages = [
          pkgs.git
          pkgs.git-lfs
        ]
        ++ mkGitTools pkgs;

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
      config = lib.mkIf config.myCommon.gitDefaults {
        home.packages = mkGitTools pkgs;

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
