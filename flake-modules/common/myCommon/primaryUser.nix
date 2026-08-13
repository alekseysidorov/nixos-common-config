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
in
{
  options.myCommon.primaryUser = {
    name = mkOption {
      type = types.str;
      description = "The username of the primary user.";
    };

    homeDirectory = mkOption {
      type = types.path;
      readOnly = true;
      default =
        if isNixOS then
          "/home/${config.myCommon.primaryUser.name}"
        else
          "/Users/${config.myCommon.primaryUser.name}";

      description = "Absolute path to the primary user's home directory.";
    };
  };
}
