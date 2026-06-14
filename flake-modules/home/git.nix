{ pkgs, lib, ... }:
let
  # Clean up all Git repositories
  gitCleanAll = pkgs.writeShellApplication {
    name = "git-clean-all";
    runtimeInputs = [
      pkgs.git
      pkgs.coreutils
    ];
    text = ''
      REPOS=$(find "$1" -type d -exec test -d {}/.git \; -prune -print)
      for REPO in $REPOS
      do
        echo "Cleaning $REPO"
        cd "$REPO"
        git cln
      done
    '';
  };
  # Sweep stale branches across all projects
  gitSweepAll = pkgs.writeShellApplication {
    name = "git-sweep-all";
    runtimeInputs = [
      pkgs.git
      pkgs.coreutils
    ];
    text = ''
      REPOS=$(find "$1" -type d -exec test -d {}/.git \; -prune -print)
      for REPO in $REPOS
      do
        echo "Cleaning $REPO"
        cd "$REPO"
        git sweep-branches
      done
    '';
  };
in
{
  home.packages = with pkgs; [
    git-credential-manager
    gitCleanAll
    gitSweepAll
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = lib.mkMerge [
      {
        # Default user information
        user.name = "Aleksey Sidorov";
        user.email = "sauron1987@gmail.com";

        # Common Git aliases
        alias.cln = "!git clean -dxf -e \"/.vscode\" -e \".idea\" -e \".zed\" -e \".private\" -e \".cargo\"";
        alias.sweep-branches = "!git fetch -p && for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == \"[gone]\" {sub(\"refs/heads/\", \"\", $1); print $1}'); do git branch -D $branch; done";

        # Example settings inspired by:
        # https://habr.com/en/articles/886538/
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

        pull.rebase = "true";
      }
    ];
  };
}
