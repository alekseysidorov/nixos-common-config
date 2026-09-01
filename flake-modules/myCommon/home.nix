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
    { config, lib, ... }:
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
      config = lib.mkIf config.myCommon.home.enableNushellIntegration {
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
            # Home Manager puts initExtra behind its interactive Bash guard.
            initExtra = lib.mkIf config.home.shell.enableNushellIntegration (
              lib.mkOrder 200 ''
                if [[ -t 0 && -t 1 ]]; then
                  exec ${lib.getExe config.programs.nushell.package}
                fi
              ''
            );
          };

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
              source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/nix/nix-completions.nu
              source ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/just/just-completions.nu
            '';
          };

          nix-your-shell = {
            enable = true;
            enableNushellIntegration = true;
          };
        };
      };
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
