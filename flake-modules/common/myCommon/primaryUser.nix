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
        if isNixOS then
          "/home/${config.myCommon.primaryUser.name}"
        else if isDarwin then
          "/Users/${config.myCommon.primaryUser.name}"
        else
          throw "Unsupported system";

      description = "Absolute path to the primary user's home directory.";
    };
  };

   # Suppress 'Error: HOME is set to "/Users/user" but we expect "/var/empty"'
  config = lib.optionalAttrs isDarwin {
    system.primaryUser = config.myCommon.primaryUser.name;
  };
}
