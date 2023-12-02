# Common home-manager configuration shared between Linux and macOS
{ pkgs, lib, ... }: {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = lib.mkDefault "Aleksey Sidorov";
    userEmail = lib.mkDefault "sauron1987@gmail.com";

    extraConfig = {
      alias.cln = "!git clean -dxf -e \"/.vscode\" -e \".idea\"";
      push.autoSetupRemote = true;
    };
  };

  home.packages = with pkgs; [
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
  ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "brew"
        "direnv"
        "git"
      ];
      theme = lib.mkDefault "af-magic";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.vim = {
    enable = true;

    extraConfig = builtins.readFile ./assets/vimrc;
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };
}
