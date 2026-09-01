{ ... }:
let
  optionsModule =
    { lib, ... }:
    {
      key = "myCommon/home/options";

      options.myCommon.home.enableNushellIntegration = lib.mkEnableOption ''
        the common Nushell setup and its platform-specific dependencies
      '';
    };

  systemModule =
    {
      config,
      lib,
      ...
    }:
    {
      config = lib.mkIf config.myCommon.home.enableNushellIntegration {
        programs.fish.enable = true;
      };
    };

  homeManagerModule =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      config = lib.mkMerge [
        (lib.mkIf config.myCommon.home.enableNushellIntegration {
          home.shell.enableShellIntegration = lib.mkDefault true;

          programs = {
            bash = {
              enable = true;
              # Home Manager puts initExtra behind its interactive Bash guard.
              initExtra = lib.mkIf config.home.shell.enableNushellIntegration (
                lib.mkOrder 200 ''
                  if [[ -t 0 && -t 1 ]]; then
                    exec ${lib.getExe config.programs.nushell.package}
                  fi
                ''
              );
            };

            zsh = {
              enable = true;
              # Home Manager writes initContent to .zshrc, which runs only for
              # interactive sessions, so this is a safe interactive trampoline.
              initContent = lib.mkIf config.home.shell.enableNushellIntegration (
                lib.mkOrder 200 ''
                  if [[ -t 0 && -t 1 ]]; then
                    exec ${lib.getExe config.programs.nushell.package}
                  fi
                ''
              );
            };

            # Nushell uses fish program for external autocompletions.
            fish.enable = true;

            nushell = {
              enable = true;

              # Escape hatch: stay in Bash/Zsh instead of being re-exec'd into
              # Nushell by the interactive trampoline. `--norc` skips the
              # trampoline; `-i` keeps it interactive. Uses shellAliases (real
              # `alias` in config.nu), NOT settings (which flattens to
              # $env.config.* and has no aliases table).
              shellAliases = {
                bash = "exec bash --norc -i";
                zsh = "exec zsh --norc -i";
              };

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
        })

        # On Darwin, programs.man.package defaults to null (man is not a
        # separate package), so the man cache that programs.fish enables by
        # default is a no-op that only emits a warning. Disable it there; the
        # actual man-page -> fish completion generation (programs.fish
        # .generateCompletions) is a separate option and is left untouched.
        (lib.mkIf (pkgs.stdenv.isDarwin) {
          programs.man.generateCaches = false;
        })
      ];
    };
in
{
  flake = {
    nixosModules.myCommon.imports = [
      optionsModule
      systemModule
    ];

    darwinModules.myCommon.imports = [
      optionsModule
      systemModule
    ];

    homeManagerModules.myCommon.imports = [
      optionsModule
      homeManagerModule
    ];
  };
}
