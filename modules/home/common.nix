# Common home-manager configuration shared between Linux and macOS
{ pkgs, lib, ... }:
{
  # Common develop nixos/nix-darwin configuration shared between Linux and macOS
  home.packages = with pkgs; [
    # Nix extensions
    nil
    nixd
    nixpkgs-fmt
    cachix

    # Rust
    dprint
    just
    rustup
    sccache

    # Useful utilites
    bat
    ripgrep
    xh
    pwgen
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

  home.sessionVariables = lib.mkMerge [{
    RUSTC_WRAPPER = "sccache";
    EDITOR = "vim";
  }];

  # Popular extra paths.
  # TODO Implement home-manager module to manage cargo home configuration.
  home.sessionPath = lib.mkDefault [
    "$HOME/.cargo/bin" # For packages installed by Cargo
  ];

  home.shell.enableShellIntegration = true;

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    bash = {
      enable = true;
      enableCompletion = true;
    };

    fish.enable = true;
    nushell.extraConfig = lib.mkMerge [ (builtins.readFile ./assets/config.nu) ];

    starship = {
      enable = true;
      settings = lib.mkDefault (builtins.fromTOML (builtins.readFile ./assets/starship.toml));
    };

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        plugins = [
          "brew"
          "direnv"
          "git"
        ];
      };
    };

    vim = {
      enable = true;
      extraConfig = builtins.readFile ./assets/vimrc;
    };

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };

    git = {
      enable = true;
      lfs.enable = true;

      userName = lib.mkDefault "Aleksey Sidorov";
      userEmail = lib.mkDefault "sauron1987@gmail.com";

      extraConfig = lib.mkMerge [{
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
  };
}
