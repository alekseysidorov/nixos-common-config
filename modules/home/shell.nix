# Shell configuration
{ lib, pkgs, ... }: {
  home.shell.enableShellIntegration = true;

  programs = {
    starship = {
      enable = true;
      settings = lib.mkDefault (builtins.fromTOML (builtins.readFile ./assets/starship.toml));
    };

    bash = {
      enable = true;
      enableCompletion = true;
    };

    fish.enable = true;

    nushell = {
      enable = true;
      package = pkgs.unstable.nushell;
      extraConfig = lib.mkMerge [ (builtins.readFile ./assets/config.nu) ];
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

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
  };
}
