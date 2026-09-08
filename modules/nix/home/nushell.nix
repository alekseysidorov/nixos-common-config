{ ... }:

let
  homeManagerModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      cfg = config.myCommon.home.nushell;
    in
    {
      key = "myCommon/home/nushell";

      options.myCommon.home.nushell = {
        enable = lib.mkEnableOption "the common Nushell environment";

        trampoline = {
          bash.enable = lib.mkEnableOption "the Bash to Nushell interactive trampoline";

          zsh.enable = lib.mkEnableOption "the Zsh to Nushell interactive trampoline";
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          {
            home.shell = {
              enableShellIntegration = lib.mkDefault true;
              enableNushellIntegration = lib.mkDefault true;
            };

            programs = {
              # Nushell uses fish for external completions.
              fish.enable = true;

              nushell = {
                enable = true;

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
            };
          }

          (lib.mkIf cfg.trampoline.bash.enable {
            programs.bash = {
              enable = true;

              # Home Manager places initExtra behind its interactive-shell guard.
              initExtra = lib.mkOrder 200 ''
                if [[ -t 0 && -t 1 ]]; then
                  exec ${lib.getExe config.programs.nushell.package}
                fi
              '';
            };

            # Escape hatch that bypasses Bash's rc file and therefore
            # does not trigger the trampoline again.
            programs.nushell.shellAliases.bashInteractive = "exec bash --norc -i";
          })

          (lib.mkIf cfg.trampoline.zsh.enable {
            programs.zsh = {
              enable = true;

              # initContent is written to .zshrc and therefore only runs
              # for interactive Zsh sessions.
              initContent = lib.mkOrder 200 ''
                if [[ -t 0 && -t 1 ]]; then
                  exec ${lib.getExe config.programs.nushell.package}
                fi
              '';
            };

            # Escape hatch that bypasses .zshrc and therefore the trampoline.
            programs.nushell.shellAliases.zshInteractive = "exec zsh --no-rcs -i";
          })

          # On Darwin, programs.man.package defaults to null, so the man cache
          # enabled by fish is a no-op that only produces a warning.
          (lib.mkIf pkgs.stdenv.isDarwin {
            programs.man.generateCaches = false;
          })
        ]
      );
    };
in
{
  flake.modules.homeManager.myCommon.imports = [
    homeManagerModule
  ];
}
