# Shell settings and integrations
{ lib, ... }:
{
  myCommon.home.enableNushellIntegration = true;

  programs = {
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

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };
  };
}
