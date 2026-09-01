{ ... }:
let
  optionsModule =
    { lib, ... }:
    {
      key = "myCommon/home/options";

      options.myCommon.home.interactiveShell = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "nushell" ]);
        default = null;
        description = ''
          Selects the user's preferred interactive shell. This does not change
          the system login shell, which is configured separately. This option
          is intended for Home Manager configurations only.
        '';
      };
    };

  systemGuardModule =
    { config, lib, ... }:
    {
      assertions = lib.optional (config.myCommon.home.interactiveShell != null) {
        assertion = false;
        message = "myCommon.home.interactiveShell is a Home Manager-only option";
      };
    };

  homeManagerModule =
    { config, lib, ... }:
    let
      useNushell = config.myCommon.home.interactiveShell == "nushell";
    in
    {
      config = lib.mkIf useNushell {
        programs = {
          bash = {
            enable = true;
            # Home Manager puts initExtra behind its interactive Bash guard.
            initExtra = lib.mkIf config.home.shell.enableShellIntegration (
              lib.mkOrder 200 ''
                if [[ -t 0 && -t 1 ]]; then
                  exec ${lib.getExe config.programs.nushell.package}
                fi
              ''
            );
          };

          nushell.enable = true;
        };
      };
    };
in
{
  flake = {
    nixosModules.myCommon.imports = [
      optionsModule
      systemGuardModule
    ];

    darwinModules.myCommon.imports = [
      optionsModule
      systemGuardModule
    ];

    homeManagerModules.myCommon.imports = [
      optionsModule
      homeManagerModule
    ];
  };
}
