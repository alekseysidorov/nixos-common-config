# Common home-manager configuration shared between Linux and macOS
{ pkgs, lib, ... }:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = lib.mkDefault "Aleksey Sidorov";
    userEmail = lib.mkDefault "sauron1987@gmail.com";

    extraConfig = lib.mkMerge [{
      alias.cln = "!git clean -dxf -e \"/.vscode\" -e \".idea\"";
      alias.sweep-branches = "!git fetch -p && for branch in $(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == \"[gone]\" {sub(\"refs/heads/\", \"\", $1); print $1}'); do git branch -D $branch; done";

      push.autoSetupRemote = true;
    }];
  };

  # Common develop nixos/nix-darwin configuration shared between Linux and macOS
  home.packages = with pkgs.unstable; [
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

  home.sessionVariables = lib.mkMerge [{
    RUSTC_WRAPPER = "sccache";
    EDITOR = "vim";
  }];

  # Popular extra paths.
  # TODO Implement home-manager module to manage cargo home configuration.
  home.sessionPath = [
    "$HOME/.cargo/bin" # For packages installed by Cargo
  ];

  programs.starship = {
    enable = true;
    settings = lib.mkDefault (builtins.fromTOML (builtins.readFile ./assets/starship.toml));
  };

  programs.zsh = {
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
      theme = lib.mkDefault "af-magic";
    };
  };

  programs.bash = {
    enable = true;
    completion.enable = true;
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

  programs.nushell = {
    package = pkgs.unstable.nushell;
    extraConfig = lib.mkMerge [ (builtins.readFile ./assets/config.nu) ];
  };
}
