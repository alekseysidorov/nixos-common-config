# Shell settings and integrations
{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.shell.enableShellIntegration = true;

  programs = {
    starship = {
      enable = true;
      settings = lib.mkDefault (fromTOML (builtins.readFile ./assets/starship.toml));
    };

    bash = {
      enable = true;
      enableCompletion = true;
    };

    fish.enable = true;

    # Fish enables man caches even when no man package is installed.
    man.generateCaches = lib.mkIf (config.programs.man.package == null) false;

    nushell = {
      enable = true;

      configFile.text =
        let
          mainConfig = builtins.readFile ./assets/config.nu;
          nuScriptsDir = "${pkgs.nu_scripts}/share/nu_scripts";
        in
        ''
          # Internal completions
          source ${nuScriptsDir}/custom-completions/just/just-completions.nu

          ${mainConfig}
        '';
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
