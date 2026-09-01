# Shell settings and integrations
{ lib, pkgs, ... }:
{
  myCommon.home.interactiveShell = "nushell";

  home.shell = {
    enableShellIntegration = true;
    enableNushellIntegration = true;
  };

  programs = {
    nushell = {
      settings.completions.external = {
        enable = true;
        completer = lib.hm.nushell.mkNushellInline ''
          {|spans|
            ${lib.getExe pkgs.fish} --command $'complete "--do-complete=($spans | str join " ")"'
            | $"value(char tab)description(char newline)" + $in
            | from tsv --flexible --no-infer
          }
        '';
      };

      extraConfig = ''
        source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/nix/nix-completions.nu
        source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/just/just-completions.nu
      '';
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
