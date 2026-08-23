{ ... }:
let
  optionsModule =
    {
      lib,
      config,
      options,
      ...
    }:
    let
      inherit (lib) mkOption types;
      # Only NixOS has boot options, nix-darwin hasn't.
      isNixOS = lib.hasAttr "boot" options;
      isDarwin = lib.hasAttr "launchd" options;
    in
    {
      key = "myCommon/primaryUser/config";

      options.myCommon.primaryUser = {
        name = mkOption {
          type = types.str;
          description = "The username of the primary user.";
          default = null;
        };

        homeDirectory = mkOption {
          type = types.path;
          readOnly = true;
          default =
            if (config.myCommon.primaryUser.name == null) then
              null
            else if isNixOS then
              "/home/${config.myCommon.primaryUser.name}"
            else if isDarwin then
              "/Users/${config.myCommon.primaryUser.name}"
            else
              throw "Unsupported system";

          description = "Absolute path to the primary user's home directory.";
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
        users.users.${cfg.name}.home = cfg.homeDirectory;
      };
    };

in
{
  flake = {
    nixosModules.myCommon.imports = [
      optionsModule
    ];

    darwinModules.myCommon.imports = [
      optionsModule
      darwinModule
    ];

    homeManagerModules.myCommon.imports = [
      optionsModule
    ];
  };
}
