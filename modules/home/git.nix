# Git configuration
{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    git-credential-manager
    carapace
    # Cleanup all git repos
    (writeShellApplication {
      name = "git-clean-all";
      runtimeInputs = [
        git
        coreutils
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
    })
    # Sweep all stale branches in all projects
    (writeShellApplication {
      name = "git-sweep-all";
      runtimeInputs = [
        git
        coreutils
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
    })
  ];

  programs.git = {
    enable = true;
    lfs.enable = true;

    settings = lib.mkMerge [{
      # Default user info
      user.name = "Aleksey Sidorov";
      user.email = "sauron1987@gmail.com";

      # Common aliases
      alias.cln = "!git clean -dxf -e \"/.vscode\" -e \".idea\" -e \".zed\" -e \".private\"";
      alias.sweep-branches = "!git fetch -p && for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == \"[gone]\" {sub(\"refs/heads/\", \"\", $1); print $1}'); do git branch -D $branch; done";

      # Some settings from this article
      #
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
    }];
  };
}
