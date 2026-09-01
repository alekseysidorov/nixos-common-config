# Shell settings and integrations
{ lib, ... }:
{
  myCommon.home.interactiveShell = "nushell";

  home.shell = {
    enableShellIntegration = true;
    enableNushellIntegration = true;
  };

  programs = {
    carapace = {
      enable = true;
      enableNushellIntegration = true;
    };

    nix-your-shell = {
      enable = true;
      enableNushellIntegration = true;
    };

    starship = {
      enable = true;
      presets = [ "pure-preset" ];
      settings = {
        format = lib.concatStrings [
          "$env_var"
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_state"
          "$git_status"
          "$cmd_duration"
          "$line_break"
          "$python"
          "$character"
        ];

        character = {
          success_symbol = "[➜](purple)";
          error_symbol = "[➜](red)";
          vimcmd_symbol = "[➜](green)";
        };

        hostname = {
          ssh_only = true;
          format = "[$hostname](purple) ";
        };

        env_var = {
          variable = "PROMPT_NAME";
          style = "bright-black";
          format = "[($env_value)]($style)";
        };
      };
    };

    zsh.enable = true;

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
  };
}
