{ ... }:
let
  optionsModule =
    { lib, ... }:
    let
      inherit (lib) mkOption types;
    in
    {
      key = "myCommon/primaryUser/config";

      options.myCommon.primaryUser = {
        name = mkOption {
          type = types.str;
          description = "The username of the primary user.";
          default = null;
        };
      };
    };

  mkPathsModule =
    mkPaths:
    { lib, config, ... }:
    let
      inherit (lib) mkOption types;
      paths = mkPaths { inherit config; };
    in
    {
      key = "myCommon/primaryUser/paths";

      options.myCommon.primaryUser.paths = {
        homeDirectory = mkOption {
          type = types.path;
          readOnly = true;
          default = paths.homeDirectory;
        };

        sopsAgeKeyFile = mkOption {
          type = types.path;
          readOnly = true;
          default = paths.sopsAgeKeyFile;
        };
      };
    };

  darwinModule =
    {
      config,
      lib,
      ...
    }:
    let
      cfg = config.myCommon.primaryUser;
    in
    {
      # Suppress 'Error: HOME is set to "/Users/user" but we expect "/var/empty"'
      config = lib.mkIf (cfg.name != null) {
        system.primaryUser = cfg.name;
        users.users.${cfg.name}.home = cfg.paths.homeDirectory;
      };
    };

in
{
  flake = {
    nixosModules.myCommon.imports = [
      optionsModule
      (mkPathsModule (
        { config, ... }:
        rec {
          homeDirectory = "/home/${config.myCommon.primaryUser.name}";
          sopsAgeKeyFile = "${homeDirectory}/.config/sops/age/keys.txt";
        }
      ))
    ];

    darwinModules.myCommon.imports = [
      optionsModule
      darwinModule
      (mkPathsModule (
        { config, ... }:
        rec {
          homeDirectory = "/Users/${config.myCommon.primaryUser.name}";
          sopsAgeKeyFile = "${homeDirectory}/.config/sops/age/keys.txt";
        }
      ))
    ];

    homeManagerModules.myCommon.imports = [
      optionsModule
      (mkPathsModule (
        { config, ... }:
        rec {
          homeDirectory = config.home.homeDirectory;
          sopsAgeKeyFile = "${homeDirectory}/.config/sops/age/keys.txt";
        }
      ))
    ];
  };
}
